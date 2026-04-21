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

-- 5. Auto-hapus berita lebih dari 30 hari (opsional, hemat storage)
-- Aktifkan pg_cron di Supabase → Extensions dulu
-- SELECT cron.schedule('delete-old-articles', '0 0 * * *',
--   $$DELETE FROM public.articles WHERE published_at < NOW() - INTERVAL '30 days'$$
-- );