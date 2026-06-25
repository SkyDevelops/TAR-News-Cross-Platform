import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type RssSource = {
  url: string;
  source: string;
  category: string;
};

type ArticleInput = {
  id: string;
  title: string;
  summary: string;
  content: null;
  image_url: string | null;
  source_name: string;
  source_url: string;
  category: string;
  published_at: string;
};

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Content-Type": "application/json",
};

const requestHeaders = {
  "User-Agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
    "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Accept":
    "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
  "Accept-Language": "id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7",
  "Cache-Control": "no-cache",
};

const RSS_TIMEOUT_MS = 9000;
const ARTICLE_PAGE_TIMEOUT_MS = 8000;
const SOURCE_DELAY_MS = 300;

// Batasi scraping halaman artikel agar Edge Function tidak terlalu berat.
const MAX_ARTICLES_PER_SOURCE = 20;
const MAX_PAGE_IMAGE_FALLBACK_PER_SOURCE = 6;

const RSS_SOURCES: RssSource[] = [
  // Detik
  {
    url: "https://news.detik.com/rss",
    source: "Detik News",
    category: "Nasional",
  },
  {
    url: "https://finance.detik.com/rss",
    source: "Detik Finance",
    category: "Finance",
  },
  {
    url: "https://sport.detik.com/rss",
    source: "Detik Sport",
    category: "Sport",
  },
  {
    url: "https://inet.detik.com/rss",
    source: "Detik Inet",
    category: "Teknologi",
  },
  {
    url: "https://oto.detik.com/rss",
    source: "Detik Oto",
    category: "Otomotif",
  },
  {
    url: "https://food.detik.com/rss",
    source: "Detik Food",
    category: "Lifestyle",
  },
  {
    url: "https://travel.detik.com/rss",
    source: "Detik Travel",
    category: "Travel",
  },
  {
    url: "https://health.detik.com/rss",
    source: "Detik Health",
    category: "Lifestyle",
  },

  // CNN Indonesia
  {
    url: "https://www.cnnindonesia.com/nasional/rss",
    source: "CNN Indonesia",
    category: "Nasional",
  },
  {
    url: "https://www.cnnindonesia.com/internasional/rss",
    source: "CNN Indonesia",
    category: "Internasional",
  },
  {
    url: "https://www.cnnindonesia.com/ekonomi/rss",
    source: "CNN Indonesia",
    category: "Finance",
  },
  {
    url: "https://www.cnnindonesia.com/olahraga/rss",
    source: "CNN Indonesia",
    category: "Sport",
  },
  {
    url: "https://www.cnnindonesia.com/teknologi/rss",
    source: "CNN Indonesia",
    category: "Teknologi",
  },
  {
    url: "https://www.cnnindonesia.com/gaya-hidup/rss",
    source: "CNN Indonesia",
    category: "Lifestyle",
  },
  {
    url: "https://www.cnnindonesia.com/otomotif/rss",
    source: "CNN Indonesia",
    category: "Otomotif",
  },

  // Antara News
  {
    url: "https://www.antaranews.com/rss/terkini.xml",
    source: "Antara News",
    category: "Nasional",
  },
  {
    url: "https://www.antaranews.com/rss/top-news.xml",
    source: "Antara News",
    category: "Nasional",
  },
  {
    url: "https://www.antaranews.com/rss/politik.xml",
    source: "Antara News",
    category: "Nasional",
  },
  {
    url: "https://www.antaranews.com/rss/ekonomi.xml",
    source: "Antara News",
    category: "Finance",
  },
  {
    url: "https://www.antaranews.com/rss/olahraga.xml",
    source: "Antara News",
    category: "Sport",
  },
  {
    url: "https://www.antaranews.com/rss/tekno.xml",
    source: "Antara News",
    category: "Teknologi",
  },
  {
    url: "https://www.antaranews.com/rss/otomotif.xml",
    source: "Antara News",
    category: "Otomotif",
  },

  // CNBC Indonesia
  {
    url: "https://www.cnbcindonesia.com/rss",
    source: "CNBC Indonesia",
    category: "Finance",
  },
  {
    url: "https://www.cnbcindonesia.com/market/rss",
    source: "CNBC Indonesia",
    category: "Finance",
  },
  {
    url: "https://www.cnbcindonesia.com/tech/rss",
    source: "CNBC Indonesia",
    category: "Teknologi",
  },
  {
    url: "https://www.cnbcindonesia.com/news/rss",
    source: "CNBC Indonesia",
    category: "Internasional",
  },

  // Okezone
  {
    url: "https://sindikasi.okezone.com/index.php/okezone/RSS2.0",
    source: "Okezone",
    category: "Nasional",
  },
  {
    url: "https://sindikasi.okezone.com/index.php/news/RSS2.0",
    source: "Okezone",
    category: "Nasional",
  },
  {
    url: "https://sindikasi.okezone.com/index.php/economy/RSS2.0",
    source: "Okezone",
    category: "Finance",
  },
  {
    url: "https://sindikasi.okezone.com/index.php/sports/RSS2.0",
    source: "Okezone",
    category: "Sport",
  },
  {
    url: "https://sindikasi.okezone.com/index.php/techno/RSS2.0",
    source: "Okezone",
    category: "Teknologi",
  },
  {
    url: "https://sindikasi.okezone.com/index.php/autos/RSS2.0",
    source: "Okezone",
    category: "Otomotif",
  },
  {
    url: "https://sindikasi.okezone.com/index.php/lifestyle/RSS2.0",
    source: "Okezone",
    category: "Lifestyle",
  },
  {
    url: "https://sindikasi.okezone.com/index.php/international/RSS2.0",
    source: "Okezone",
    category: "Internasional",
  },

  // Tempo
  {
    url: "https://rss.tempo.co/nasional",
    source: "Tempo",
    category: "Nasional",
  },
  {
    url: "https://rss.tempo.co/bisnis",
    source: "Tempo",
    category: "Finance",
  },
  {
    url: "https://rss.tempo.co/olahraga",
    source: "Tempo",
    category: "Sport",
  },
  {
    url: "https://rss.tempo.co/tekno",
    source: "Tempo",
    category: "Teknologi",
  },
  {
    url: "https://rss.tempo.co/otomotif",
    source: "Tempo",
    category: "Otomotif",
  },
  {
    url: "https://rss.tempo.co/dunia",
    source: "Tempo",
    category: "Internasional",
  },
  {
    url: "https://rss.tempo.co/gaya-hidup",
    source: "Tempo",
    category: "Lifestyle",
  },

  // Republika
  {
    url: "https://www.republika.co.id/rss/nasional/umum",
    source: "Republika",
    category: "Nasional",
  },
  {
    url: "https://www.republika.co.id/rss/ekonomi/keuangan",
    source: "Republika",
    category: "Finance",
  },
  {
    url: "https://www.republika.co.id/rss/olahraga/umum",
    source: "Republika",
    category: "Sport",
  },
  {
    url: "https://www.republika.co.id/rss/internasional",
    source: "Republika",
    category: "Internasional",
  },
  {
    url: "https://www.republika.co.id/rss/teknologi",
    source: "Republika",
    category: "Teknologi",
  },
  {
    url: "https://www.republika.co.id/rss/gaya-hidup",
    source: "Republika",
    category: "Lifestyle",
  },

  // BBC Indonesia
  {
    url: "https://feeds.bbci.co.uk/indonesian/rss.xml",
    source: "BBC Indonesia",
    category: "Internasional",
  },
  {
    url: "https://feeds.bbci.co.uk/indonesian/dunia/rss.xml",
    source: "BBC Indonesia",
    category: "Internasional",
  },
  {
    url: "https://feeds.bbci.co.uk/indonesian/sport/rss.xml",
    source: "BBC Indonesia",
    category: "Sport",
  },
];

async function parseRSS(
  xml: string,
  sourceName: string,
  category: string,
): Promise<ArticleInput[]> {
  const articles: ArticleInput[] = [];
  const itemRegex = /<item\b[^>]*>([\s\S]*?)<\/item>/gi;

  let match;
  let fallbackCount = 0;

  while ((match = itemRegex.exec(xml)) !== null) {
    if (articles.length >= MAX_ARTICLES_PER_SOURCE) break;

    const item = match[1];

    const rawTitle = extractTag(item, "title");
    const rawLink = extractTag(item, "link") || extractTag(item, "guid");
    const rawPubDate = extractTag(item, "pubDate") || extractTag(item, "dc:date");

    const title = cleanText(rawTitle);
    const link = normalizeArticleUrl(rawLink);

    if (!title || !link) continue;

    const rawSummary =
      extractTag(item, "description") ||
      extractTag(item, "content:encoded") ||
      "";

    const summary = stripHtml(cleanText(rawSummary)).slice(0, 500);

    let imageUrl = extractImage(item);

    if (!imageUrl && fallbackCount < MAX_PAGE_IMAGE_FALLBACK_PER_SOURCE) {
      fallbackCount++;
      imageUrl = await extractImageFromArticlePage(link);
    }

    articles.push({
      id: hashString(link),
      title,
      summary,
      content: null,
      image_url: imageUrl,
      source_name: sourceName,
      source_url: link,
      category,
      published_at: parseDateOrNow(rawPubDate),
    });
  }

  return articles;
}

function extractTag(xml: string, tag: string): string {
  const re = new RegExp(
    `<${tag}[^>]*><!\\[CDATA\\[([\\s\\S]*?)\\]\\]><\\/${tag}>|<${tag}[^>]*>([\\s\\S]*?)<\\/${tag}>`,
    "i",
  );

  const match = xml.match(re);
  return match ? (match[1] || match[2] || "").trim() : "";
}

function extractImage(item: string): string | null {
  const patterns = [
    /<media:content\b[^>]*\burl=["']([^"']+)["'][^>]*>/i,
    /<media:thumbnail\b[^>]*\burl=["']([^"']+)["'][^>]*>/i,
    /<enclosure\b[^>]*\burl=["']([^"']+)["'][^>]*>/i,
    /<image\b[^>]*>\s*<url>([\s\S]*?)<\/url>\s*<\/image>/i,
    /<img\b[^>]*\bsrc=["']([^"']+)["'][^>]*>/i,
    /<meta\b[^>]*property=["']og:image["'][^>]*content=["']([^"']+)["'][^>]*>/i,
    /<meta\b[^>]*content=["']([^"']+)["'][^>]*property=["']og:image["'][^>]*>/i,
    /<meta\b[^>]*name=["']twitter:image["'][^>]*content=["']([^"']+)["'][^>]*>/i,
    /<meta\b[^>]*content=["']([^"']+)["'][^>]*name=["']twitter:image["'][^>]*>/i,
    /(https?:\/\/[^\s"'<>]+?\.(?:jpg|jpeg|png|webp)(?:\?[^\s"'<>]*)?)/i,
  ];

  for (const pattern of patterns) {
    const match = item.match(pattern);
    if (!match) continue;

    const imageUrl = normalizeImageUrl(match[1]);
    if (imageUrl) return imageUrl;
  }

  return null;
}

async function extractImageFromArticlePage(
  url: string,
): Promise<string | null> {
  try {
    const res = await fetch(url, {
      headers: requestHeaders,
      signal: AbortSignal.timeout(ARTICLE_PAGE_TIMEOUT_MS),
    });

    if (!res.ok) return null;

    const html = await res.text();

    const patterns = [
      /<meta\b[^>]*property=["']og:image["'][^>]*content=["']([^"']+)["'][^>]*>/i,
      /<meta\b[^>]*content=["']([^"']+)["'][^>]*property=["']og:image["'][^>]*>/i,
      /<meta\b[^>]*name=["']twitter:image["'][^>]*content=["']([^"']+)["'][^>]*>/i,
      /<meta\b[^>]*content=["']([^"']+)["'][^>]*name=["']twitter:image["'][^>]*>/i,
      /<link\b[^>]*rel=["']image_src["'][^>]*href=["']([^"']+)["'][^>]*>/i,
      /<link\b[^>]*href=["']([^"']+)["'][^>]*rel=["']image_src["'][^>]*>/i,
    ];

    for (const pattern of patterns) {
      const match = html.match(pattern);
      if (!match) continue;

      const imageUrl = normalizeImageUrl(match[1]);
      if (imageUrl) return imageUrl;
    }

    return null;
  } catch {
    return null;
  }
}

function normalizeArticleUrl(value: string): string | null {
  const cleanUrl = cleanText(value);

  if (!cleanUrl) return null;

  if (cleanUrl.startsWith("//")) {
    return `https:${cleanUrl}`;
  }

  if (!/^https?:\/\//i.test(cleanUrl)) {
    return null;
  }

  return cleanUrl;
}

function normalizeImageUrl(value: string): string | null {
  let url = cleanText(value);

  if (!url) return null;

  if (url.startsWith("//")) {
    url = `https:${url}`;
  }

  if (!/^https?:\/\//i.test(url)) {
    return null;
  }

  if (!/\.(jpg|jpeg|png|webp)(\?|$)/i.test(url)) {
    const looksLikeImageCdn =
      url.includes("images") ||
      url.includes("image") ||
      url.includes("img") ||
      url.includes("cdn") ||
      url.includes("asset");

    if (!looksLikeImageCdn) return null;
  }

  return url;
}

function stripHtml(html: string): string {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]*>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function cleanText(text: string): string {
  return text
    .replace(/<!\[CDATA\[/g, "")
    .replace(/\]\]>/g, "")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&apos;/g, "'")
    .replace(/&nbsp;/g, " ")
    .trim();
}

function parseDateOrNow(value: string): string {
  if (!value) return new Date().toISOString();

  const parsed = new Date(cleanText(value));

  if (Number.isNaN(parsed.getTime())) {
    return new Date().toISOString();
  }

  return parsed.toISOString();
}

function hashString(str: string): string {
  let hash = 0;

  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash = hash & hash;
  }

  return Math.abs(hash).toString(36) + str.length.toString(36);
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  const url = new URL(req.url);
  const filter = url.searchParams.get("category");

  const sources = filter
    ? RSS_SOURCES.filter((source) => source.category === filter)
    : RSS_SOURCES;

  let totalSaved = 0;
  let totalFetched = 0;
  let totalWithImage = 0;
  let totalWithoutImage = 0;

  const errors: string[] = [];

  for (const source of sources) {
    try {
      const res = await fetch(source.url, {
        headers: requestHeaders,
        signal: AbortSignal.timeout(RSS_TIMEOUT_MS),
      });

      if (!res.ok) {
        errors.push(`${source.source} (${source.url}): HTTP ${res.status}`);
        continue;
      }

      const xml = await res.text();
      const articles = await parseRSS(xml, source.source, source.category);

      if (articles.length === 0) {
        errors.push(`${source.source} (${source.url}): no articles parsed`);
        continue;
      }

      totalFetched += articles.length;
      totalWithImage += articles.filter((article) => article.image_url).length;
      totalWithoutImage += articles.filter((article) => !article.image_url).length;

      const { data, error } = await supabase
        .from("articles")
        .upsert(articles, { onConflict: "id" })
        .select("id");

      if (error) {
        errors.push(`${source.source}: ${error.message}`);
      } else {
        totalSaved += data?.length ?? 0;
      }

      await delay(SOURCE_DELAY_MS);
    } catch (error) {
      errors.push(
        `${source.source}: ${
          error instanceof Error ? error.message : String(error)
        }`,
      );
    }
  }

  return new Response(
    JSON.stringify({
      success: true,
      sources_count: sources.length,
      total_fetched: totalFetched,
      total_saved: totalSaved,
      total_inserted: totalSaved,
      total_with_image: totalWithImage,
      total_without_image: totalWithoutImage,
      errors,
    }),
    {
      headers: corsHeaders,
    },
  );
});