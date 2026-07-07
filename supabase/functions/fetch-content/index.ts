// supabase/functions/fetch-content/index.ts
// Menggunakan deno-dom (proper HTML parser) sebagai pengganti regex scraping.

// @ts-ignore
import { parseHTML } from "npm:linkedom@0.16.10";
// @ts-ignore
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

declare const Deno: any;

// ── Supabase client (service role) untuk caching ke tabel articles ───────────
const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// ── Selector per-domain berdasarkan RSS_SOURCES yang aktual di fetch-news ────
// Setiap domain mencoba selector dari indeks pertama ke terakhir (waterfall).
const SELECTOR_MAP: Record<string, string[]> = {
  "detik.com": [
    "div.detail__body-text",
    "div.itp_bodycontent",
    "div.detail__body",
  ],
  "cnnindonesia.com": [
    "div.detail-text",
    "div.detail_text",
    "section.detail__body",
  ],
  "antaranews.com": [
    "div.post-content",
    "div.wrap__article-detail-content",
    "div.article-body",
  ],
  "cnbcindonesia.com": [
    "div.detail-text",
    "div.article__content",
    "div.content-detail",
  ],
  "okezone.com": [
    "div#contentx",
    "div.content-detail",
    "div.read__content",
  ],
  "liputan6.com": [
    "div.article-content-body__item-content",
    "div.read__content",
    "div.article-content",
  ],
  "tempo.co": [
    "div.detail-konten",
    "div#isi",
    "div.article-body",
  ],
  "republika.co.id": [
    "div.article-konten",
    "div#article-detail",
    "div.content",
  ],
  "kompas.com": [
    "div.read__content",
    "div.artikel__content",
    "div.content",
  ],
  "tribunnews.com": [
    "div#article-2",
    "div.side-article",
    "div.content-article",
  ],
  "suara.com": [
    "div.detail-article",
    "div.detail-konten",
  ],
  "merdeka.com": [
    "div#article_content",
    "div.article-content",
  ],
  "jpnn.com": [
    "div.read-content",
    "div.article-content",
  ],
};

// ── Tipe error yang dikembalikan ke client ────────────────────────────────────
type FetchErrorCode =
  | "blocked"        // HTTP 403 / 429
  | "timeout"        // AbortSignal timeout / AbortError
  | "no_selector_match" // HTML berhasil diunduh tapi tidak ada selector match
  | "network_error"  // Fetch gagal (DNS, SSL, dll)
  | "parse_error";   // DOM parse gagal

interface FetchResult {
  content: string | null;
  error?: string;
  error_code?: FetchErrorCode;
  cached?: boolean;
  debug?: {
    domain: string;
    selector_used: string | null;
    html_length: number;
    paragraphs_found: number;
    content_length: number;
  };
}

// ── Ambil selector list untuk domain dari URL ─────────────────────────────────
function getSelectorsForUrl(url: string): string[] {
  try {
    const hostname = new URL(url).hostname.replace(/^www\./, "");
    // Coba exact match dulu, lalu partial match (subdomain)
    for (const [domain, selectors] of Object.entries(SELECTOR_MAP)) {
      if (hostname === domain || hostname.endsWith(`.${domain}`)) {
        return selectors;
      }
    }
  } catch {
    // URL parse error, akan fallback ke generic
  }
  // Fallback ke generic selector
  return ["article", "main", "div[class*='content']", "div[class*='article']"];
}

// ── Ekstrak teks paragraf bersih dari container node ─────────────────────────
function extractParagraphs(
  document: any,
  containerSelector: string,
): { paragraphs: string[]; selectorUsed: string } | null {
  const container = document.querySelector(containerSelector);
  if (!container) return null;

  const pNodes = container.querySelectorAll("p");
  const paragraphs: string[] = [];

  for (const p of pNodes) {
    // Buang script/style di dalam p (seharusnya tidak ada, tapi defensif)
    const text = (p.textContent ?? "")
      .replace(/\s+/g, " ")
      .trim();

    // Filter: panjang > 60 karakter, bukan "Baca juga:", "Advertisement", dll.
    if (
      text.length > 60 &&
      !text.match(/^(baca juga|advertisement|iklan|sponsored|related)/i) &&
      !text.match(/^Copyright|©/i)
    ) {
      paragraphs.push(text);
    }
  }

  // Kalau tidak ada <p> di container, coba ambil textContent langsung
  if (paragraphs.length === 0) {
    const fallbackText = (container.textContent ?? "")
      .replace(/\s+/g, " ")
      .trim();
    if (fallbackText.length > 200) {
      // Pecah per baris panjang sebagai paragraf
      const chunks = fallbackText
        .split(/\.\s+/)
        .filter((s: string) => s.length > 60)
        .map((s: string) => s.trim() + ".");
      paragraphs.push(...chunks.slice(0, 20));
    }
  }

  if (paragraphs.length === 0) return null;
  return { paragraphs, selectorUsed: containerSelector };
}

// ── Main handler ──────────────────────────────────────────────────────────────
Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
      },
    });
  }

  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json",
  };

  try {

  let url = "";
  let articleId: string | undefined;

  try {
    const body = await req.json();
    url = body.url;
    articleId = body.article_id; // opsional, untuk caching
  } catch {
    return new Response(
      JSON.stringify({ error: "Request body invalid", content: null }),
      { status: 400, headers: corsHeaders },
    );
  }

  if (!url) {
    return new Response(
      JSON.stringify({ error: "URL required", content: null }),
      { status: 400, headers: corsHeaders },
    );
  }

  // ── 1. Cek apakah artikel sudah di-cache di DB ────────────────────────────
  if (articleId && supabaseServiceKey) {
    try {
      const supabase = createClient(supabaseUrl, supabaseServiceKey);
      const { data } = await supabase
        .from("articles")
        .select("content")
        .eq("id", articleId)
        .maybeSingle();

      if (data?.content && (data.content as string).length > 100) {
        console.log(`Cache hit for article ${articleId}`);
        return new Response(
          JSON.stringify({
            content: data.content,
            cached: true,
          }),
          { headers: corsHeaders },
        );
      }
    } catch (e) {
      // Cache check gagal → lanjut scrape
      console.warn("Cache check failed:", e);
    }
  }

  // ── 2. Fetch HTML dari sumber ─────────────────────────────────────────────
  let html = "";
  let domain = "";

  try {
    domain = new URL(url).hostname.replace(/^www\./, "");
  } catch {
    const result: FetchResult = {
      content: null,
      error: "URL tidak valid",
      error_code: "network_error",
    };
    console.error(`Invalid URL error: ${url}`);
    return new Response(JSON.stringify(result), { headers: corsHeaders });
  }

  try {
    const res = await fetch(url, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        Accept:
          "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "id-ID,id;q=0.9,en;q=0.8",
        "Cache-Control": "no-cache",
        Referer: `https://${domain}/`,
      },
      signal: AbortSignal.timeout(15000),
    });

    if (res.status === 403 || res.status === 429) {
      const result: FetchResult = {
        content: null,
        error: `Konten diblokir oleh sumber (HTTP ${res.status}). Gunakan tombol "Buka Sumber Asli".`,
        error_code: "blocked",
      };
      console.error(`Blocked by source: ${url} (HTTP ${res.status})`);
      return new Response(JSON.stringify(result), { headers: corsHeaders });
    }

    if (!res.ok) {
      const result: FetchResult = {
        content: null,
        error: `Sumber mengembalikan HTTP ${res.status}`,
        error_code: "network_error",
      };
      console.error(`Network error: ${url} (HTTP ${res.status})`);
      return new Response(JSON.stringify(result), { headers: corsHeaders });
    }

    html = await res.text();
    console.log(`Successfully fetched HTML from ${url}, length: ${html.length}`);
  } catch (e) {
    const isTimeout =
      e instanceof Error &&
      (e.name === "TimeoutError" || e.name === "AbortError");

    const result: FetchResult = {
      content: null,
      error: isTimeout
        ? "Waktu permintaan habis — sumber terlalu lama merespons."
        : `Gagal menghubungi sumber: ${e instanceof Error ? e.message : String(e)}`,
      error_code: isTimeout ? "timeout" : "network_error",
    };
    console.error(`Fetch exception for ${url}:`, e);
    return new Response(JSON.stringify(result), { headers: corsHeaders });
  }

  // ── 3. Parse HTML dengan linkedom ─────────────────────────────────────────
  let document: any = null;

  try {
    console.log(`Starting to parse HTML for ${url}...`);
    const parsed = parseHTML(html);
    document = parsed.document;
    console.log(`Successfully parsed HTML for ${url}`);
  } catch (e) {
    const result: FetchResult = {
      content: null,
      error: "Gagal mem-parse HTML dari sumber.",
      error_code: "parse_error",
    };
    console.error("DOM parse error:", e);
    return new Response(JSON.stringify(result), { headers: corsHeaders });
  }

  if (!document) {
    const result: FetchResult = {
      content: null,
      error: "Gagal mem-parse HTML.",
      error_code: "parse_error",
    };
    console.error(`Parsed document is null for ${url}`);
    return new Response(JSON.stringify(result), { headers: corsHeaders });
  }

  // ── 4. Coba selector per-domain (waterfall) ───────────────────────────────
  const selectors = getSelectorsForUrl(url);
  let extractResult: ReturnType<typeof extractParagraphs> = null;

  for (const selector of selectors) {
    extractResult = extractParagraphs(document, selector);
    if (extractResult && extractResult.paragraphs.length >= 2) {
      break;
    }
  }

  // ── 5. Fallback: generic <article> / <main> ───────────────────────────────
  if (!extractResult || extractResult.paragraphs.length < 2) {
    for (const genericSelector of ["article", "main", "[role='main']"]) {
      extractResult = extractParagraphs(document, genericSelector);
      if (extractResult && extractResult.paragraphs.length >= 2) break;
    }
  }

  // ── 6. Last resort: semua <p> di body (bukan seluruh HTML) ────────────────
  if (!extractResult || extractResult.paragraphs.length < 2) {
    const body = document.querySelector("body");
    if (body) {
      const allP = body.querySelectorAll("p");
      const paragraphs: string[] = [];
      for (const p of allP) {
        const text = (p.textContent ?? "").replace(/\s+/g, " ").trim();
        if (
          text.length > 80 &&
          !text.match(/^(baca juga|advertisement|iklan|sponsored)/i) &&
          !text.match(/^Copyright|©/i)
        ) {
          paragraphs.push(text);
        }
      }
      if (paragraphs.length > 0) {
        extractResult = { paragraphs, selectorUsed: "body > p (fallback)" };
      }
    }
  }

  // ── 7. Tidak ada konten sama sekali ───────────────────────────────────────
  if (!extractResult || extractResult.paragraphs.length === 0) {
    const result: FetchResult = {
      content: null,
      error:
        "Konten artikel tidak dapat diekstrak dari halaman ini. Kemungkinan situs menggunakan JavaScript rendering atau proteksi anti-bot.",
      error_code: "no_selector_match",
      debug: {
        domain,
        selector_used: null,
        html_length: html.length,
        paragraphs_found: 0,
        content_length: 0,
      },
    };
    console.log(`No selector match for ${url}`);
    return new Response(JSON.stringify(result), { headers: corsHeaders });
  }

  // ── 8. Deduplicate & join ─────────────────────────────────────────────────
  const seen = new Set<string>();
  const unique = extractResult.paragraphs.filter((p) => {
    if (seen.has(p)) return false;
    seen.add(p);
    return true;
  });

  const content = unique.slice(0, 30).join("\n\n");

  console.log(`URL: ${url}`);
  console.log(`Domain: ${domain}`);
  console.log(`Selector used: ${extractResult.selectorUsed}`);
  console.log(`HTML length: ${html.length}`);
  console.log(`Paragraphs found: ${unique.length}`);
  console.log(`Content length: ${content.length}`);

  // ── 9. Cache ke DB jika konten cukup panjang ─────────────────────────────
  if (content.length > 100 && supabaseServiceKey) {
    try {
      const supabase = createClient(supabaseUrl, supabaseServiceKey);

      // Update berdasarkan article_id jika tersedia, fallback ke source_url
      if (articleId) {
        await supabase
          .from("articles")
          .update({ content })
          .eq("id", articleId)
          .is("content", null); // hanya update jika masih null (tidak overwrite edit manual)
      } else {
        await supabase
          .from("articles")
          .update({ content })
          .eq("source_url", url)
          .is("content", null);
      }
      console.log(`Cached content to DB (${content.length} chars)`);
    } catch (e) {
      // Caching gagal tidak boleh membuat response gagal
      console.warn("Cache write failed:", e);
    }
  }

  // ── 10. Return hasil ──────────────────────────────────────────────────────
  const result: FetchResult = {
    content: content.length > 100 ? content : null,
    cached: false,
    debug: {
      domain,
      selector_used: extractResult.selectorUsed,
      html_length: html.length,
      paragraphs_found: unique.length,
      content_length: content.length,
    },
  };

  if (!result.content) {
    result.error =
      "Konten terlalu pendek untuk ditampilkan. Gunakan tombol Buka Sumber Asli.";
    result.error_code = "no_selector_match";
  }

  console.log(`Returning result for ${url}, error_code: ${result.error_code ?? 'none'}, cached: false`);
  return new Response(JSON.stringify(result), { headers: corsHeaders });
  } catch (error) {
    console.error("Fatal error in handler:", error);
    return new Response(
      JSON.stringify({
        content: null,
        error: "Terjadi kesalahan internal pada server.",
        error_code: "network_error",
      }),
      { status: 500, headers: corsHeaders }
    );
  }
});