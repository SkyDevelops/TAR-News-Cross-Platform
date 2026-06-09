-- ============================================================
-- Jalankan ini di Supabase → SQL Editor
-- ============================================================

-- 1. Buat tabel articles (kalau belum ada)
CREATE TABLE IF NOT EXISTS public.articles (
  id           TEXT PRIMARY KEY,
  title        TEXT NOT NULL,
  summary      TEXT,
  content      TEXT,
  image_url    TEXT,
  source_name  TEXT,
  source_url   TEXT,
  category     TEXT,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Index untuk query cepat berdasarkan kategori & waktu
CREATE INDEX IF NOT EXISTS idx_articles_category    ON public.articles (category);
CREATE INDEX IF NOT EXISTS idx_articles_published   ON public.articles (published_at DESC);
CREATE INDEX IF NOT EXISTS idx_articles_source      ON public.articles (source_name);

-- 3. Full-text search untuk fitur Search di TAR News
CREATE INDEX IF NOT EXISTS idx_articles_title_fts
  ON public.articles USING GIN (to_tsvector('indonesian', title));

-- 4. RLS — artikel bisa dibaca semua orang (public)
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "articles_public_read" ON public.articles;
CREATE POLICY "articles_public_read"
  ON public.articles FOR SELECT
  USING (true);

-- Hanya service role yang bisa insert/update (Edge Function pakai service key)
DROP POLICY IF EXISTS "articles_service_write" ON public.articles;
CREATE POLICY "articles_service_write"
  ON public.articles FOR ALL
  USING (auth.role() = 'service_role');

-- 5. Tabel profiles untuk halaman Profile
CREATE TABLE IF NOT EXISTS public.profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name  TEXT,
  username   TEXT UNIQUE,
  avatar_url TEXT,
  bio        TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_public_read" ON public.profiles;
CREATE POLICY "profiles_public_read"
  ON public.profiles FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "profiles_owner_insert" ON public.profiles;
CREATE POLICY "profiles_owner_insert"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_owner_update" ON public.profiles;
CREATE POLICY "profiles_owner_update"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 6. Tabel bookmarks untuk fitur simpan berita
CREATE TABLE IF NOT EXISTS public.bookmarks (
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  article_id TEXT NOT NULL REFERENCES public.articles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, article_id)
);

CREATE INDEX IF NOT EXISTS idx_bookmarks_user_created
  ON public.bookmarks (user_id, created_at DESC);

ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "bookmarks_owner_read" ON public.bookmarks;
CREATE POLICY "bookmarks_owner_read"
  ON public.bookmarks FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "bookmarks_owner_insert" ON public.bookmarks;
CREATE POLICY "bookmarks_owner_insert"
  ON public.bookmarks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "bookmarks_owner_delete" ON public.bookmarks;
CREATE POLICY "bookmarks_owner_delete"
  ON public.bookmarks FOR DELETE
  USING (auth.uid() = user_id);

-- 7. Auto-hapus berita lebih dari 30 hari (opsional, hemat storage)
-- Aktifkan pg_cron di Supabase → Extensions dulu
-- SELECT cron.schedule('delete-old-articles', '0 0 * * *',
--   $$DELETE FROM public.articles WHERE published_at < NOW() - INTERVAL '30 days'$$
-- );
