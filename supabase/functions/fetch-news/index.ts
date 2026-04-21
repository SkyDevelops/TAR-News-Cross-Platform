// supabase/functions/fetch-news/index.ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const RSS_SOURCES = [
  // ── DETIK.COM ──────────────────────────────────────────────
  { url: "https://news.detik.com/rss",         source: "Detik News",    category: "Nasional"   },
  { url: "https://finance.detik.com/rss",      source: "Detik Finance", category: "Finance"    },
  { url: "https://sport.detik.com/rss",        source: "Detik Sport",   category: "Sport"      },
  { url: "https://inet.detik.com/rss",         source: "Detik Inet",    category: "Teknologi"  },
  { url: "https://oto.detik.com/rss",          source: "Detik Oto",     category: "Otomotif"   },
  { url: "https://food.detik.com/rss",         source: "Detik Food",    category: "Lifestyle"  },
  { url: "https://travel.detik.com/rss",       source: "Detik Travel",  category: "Travel"     },
  { url: "https://health.detik.com/rss",       source: "Detik Health",  category: "Lifestyle"  },

  // ── KOMPAS.COM — URL diperbaiki ───────────────────────────
  { url: "https://rss.kompas.com/rss/nasional",        source: "Kompas", category: "Nasional"      },
  { url: "https://rss.kompas.com/rss/internasional",   source: "Kompas", category: "Internasional" },
  { url: "https://rss.kompas.com/rss/ekonomi",         source: "Kompas", category: "Finance"       },
  { url: "https://rss.kompas.com/rss/olahraga",        source: "Kompas", category: "Sport"         },
  { url: "https://rss.kompas.com/rss/tekno",           source: "Kompas", category: "Teknologi"     },
  { url: "https://rss.kompas.com/rss/travel",          source: "Kompas", category: "Travel"        },
  { url: "https://rss.kompas.com/rss/otomotif",        source: "Kompas", category: "Otomotif"      },

  // ── CNN INDONESIA ──────────────────────────────────────────
  { url: "https://www.cnnindonesia.com/nasional/rss",      source: "CNN Indonesia", category: "Nasional"      },
  { url: "https://www.cnnindonesia.com/internasional/rss", source: "CNN Indonesia", category: "Internasional" },
  { url: "https://www.cnnindonesia.com/ekonomi/rss",       source: "CNN Indonesia", category: "Finance"       },
  { url: "https://www.cnnindonesia.com/olahraga/rss",      source: "CNN Indonesia", category: "Sport"         },
  { url: "https://www.cnnindonesia.com/teknologi/rss",     source: "CNN Indonesia", category: "Teknologi"     },
  { url: "https://www.cnnindonesia.com/gaya-hidup/rss",    source: "CNN Indonesia", category: "Lifestyle"     },
  { url: "https://www.cnnindonesia.com/otomotif/rss",      source: "CNN Indonesia", category: "Otomotif"      },

  // ── ANTARA NEWS ────────────────────────────────────────────
  { url: "https://www.antaranews.com/rss/terkini.xml",       source: "Antara News", category: "Nasional"      },
  { url: "https://www.antaranews.com/rss/politik.xml",       source: "Antara News", category: "Nasional"      },
  { url: "https://www.antaranews.com/rss/ekonomi.xml",       source: "Antara News", category: "Finance"       },
  { url: "https://www.antaranews.com/rss/olahraga.xml",      source: "Antara News", category: "Sport"         },
  { url: "https://www.antaranews.com/rss/teknologi.xml",     source: "Antara News", category: "Teknologi"     },
  { url: "https://www.antaranews.com/rss/internasional.xml", source: "Antara News", category: "Internasional" },

  // ── TRIBUNNEWS ─────────────────────────────────────────────
  { url: "https://www.tribunnews.com/rss",          source: "Tribunnews", category: "Nasional"  },
  { url: "https://www.tribunnews.com/rss/nasional", source: "Tribunnews", category: "Nasional"  },
  { url: "https://www.tribunnews.com/rss/bisnis",   source: "Tribunnews", category: "Finance"   },
  { url: "https://www.tribunnews.com/rss/olahraga", source: "Tribunnews", category: "Sport"     },
  { url: "https://www.tribunnews.com/rss/techno",   source: "Tribunnews", category: "Teknologi" },
  { url: "https://www.tribunnews.com/rss/otomotif", source: "Tribunnews", category: "Otomotif"  },
  { url: "https://www.tribunnews.com/rss/travel",   source: "Tribunnews", category: "Travel"    },

  // ── LIPUTAN6 ───────────────────────────────────────────────
  { url: "https://feed.liputan6.com/rss/news",      source: "Liputan6", category: "Nasional"      },
  { url: "https://feed.liputan6.com/rss/bisnis",    source: "Liputan6", category: "Finance"       },
  { url: "https://feed.liputan6.com/rss/bola",      source: "Liputan6", category: "Sport"         },
  { url: "https://feed.liputan6.com/rss/tekno",     source: "Liputan6", category: "Teknologi"     },
  { url: "https://feed.liputan6.com/rss/otomotif",  source: "Liputan6", category: "Otomotif"      },
  { url: "https://feed.liputan6.com/rss/global",    source: "Liputan6", category: "Internasional" },
  { url: "https://feed.liputan6.com/rss/lifestyle", source: "Liputan6", category: "Lifestyle"     },

  // ── KONTAN ─────────────────────────────────────────────────
  { url: "https://rss.kontan.co.id/news/nasional",  source: "Kontan", category: "Nasional"  },
  { url: "https://rss.kontan.co.id/news/keuangan",  source: "Kontan", category: "Finance"   },
  { url: "https://rss.kontan.co.id/news/investasi", source: "Kontan", category: "Finance"   },
  { url: "https://rss.kontan.co.id/news/teknologi", source: "Kontan", category: "Teknologi" },

  // ── CNBC INDONESIA ─────────────────────────────────────────
  { url: "https://www.cnbcindonesia.com/rss",        source: "CNBC Indonesia", category: "Finance"       },
  { url: "https://www.cnbcindonesia.com/market/rss", source: "CNBC Indonesia", category: "Finance"       },
  { url: "https://www.cnbcindonesia.com/tech/rss",   source: "CNBC Indonesia", category: "Teknologi"     },
  { url: "https://www.cnbcindonesia.com/news/rss",   source: "CNBC Indonesia", category: "Internasional" },
];

function parseRSS(xml: string, sourceName: string, category: string) {
  const articles: {
    id: string;
    title: string;
    summary: string;
    content: null;
    image_url: string | null;
    source_name: string;
    source_url: string;
    category: string;
    published_at: string;
  }[] = [];

  const itemRegex = /<item>([\s\S]*?)<\/item>/g;
  let match;
  while ((match = itemRegex.exec(xml)) !== null) {
    const item     = match[1];
    const title    = extractTag(item, "title");
    const link     = extractTag(item, "link") || extractTag(item, "guid");
    const pubDate  = extractTag(item, "pubDate") || extractTag(item, "dc:date");
    const summary  = stripHtml(extractTag(item, "description") || extractTag(item, "content:encoded") || "").slice(0, 500);
    const imageUrl = extractImage(item);
    if (!title || !link) continue;
    articles.push({
      id:           hashString(link),
      title:        cleanText(title),
      summary,
      content:      null,
      image_url:    imageUrl,
      source_name:  sourceName,
      source_url:   link,
      category,
      published_at: pubDate ? new Date(pubDate).toISOString() : new Date().toISOString(),
    });
  }
  return articles;
}

function extractTag(xml: string, tag: string): string {
  const re = new RegExp(`<${tag}[^>]*><!\\[CDATA\\[([\\s\\S]*?)\\]\\]><\\/${tag}>|<${tag}[^>]*>([\\s\\S]*?)<\\/${tag}>`, "i");
  const m  = xml.match(re);
  return m ? (m[1] || m[2] || "").trim() : "";
}

function extractImage(item: string): string | null {
  let m = item.match(/<media:content[^>]+url=["']([^"']+)["']/i);
  if (m) return m[1];
  m = item.match(/<media:thumbnail[^>]+url=["']([^"']+)["']/i);
  if (m) return m[1];
  m = item.match(/<enclosure[^>]+url=["']([^"']+)["'][^>]+type=["']image/i);
  if (m) return m[1];
  m = item.match(/src=["']([^"']+\.(?:jpg|jpeg|png|webp))["']/i);
  if (m) return m[1];
  return null;
}

function stripHtml(html: string): string {
  return html.replace(/<[^>]*>/g, " ").replace(/\s+/g, " ").trim();
}

function cleanText(text: string): string {
  return text
    .replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&nbsp;/g, " ")
    .trim();
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

// ── FIX: tambah tipe Request ──────────────────────────────────
Deno.serve(async (req: Request) => {
  const url    = new URL(req.url);
  const filter = url.searchParams.get("category");
  const sources = filter ? RSS_SOURCES.filter((s) => s.category === filter) : RSS_SOURCES;

  let totalInserted = 0;
  let totalSkipped  = 0;
  const errors: string[] = [];

  for (const source of sources) {
    try {
      const res = await fetch(source.url, {
        headers: { "User-Agent": "TARNews/1.0 RSS Reader" },
        signal:  AbortSignal.timeout(8000),
      });
      if (!res.ok) { errors.push(`${source.source} (${source.url}): HTTP ${res.status}`); continue; }

      const xml      = await res.text();
      const articles = parseRSS(xml, source.source, source.category);
      if (articles.length === 0) continue;

      const { data, error } = await supabase
        .from("articles")
        .upsert(articles, { onConflict: "id", ignoreDuplicates: true })
        .select("id");

      if (error) { errors.push(`${source.source}: ${error.message}`); }
      else {
        totalInserted += data?.length ?? 0;
        totalSkipped  += articles.length - (data?.length ?? 0);
      }
      await new Promise((r) => setTimeout(r, 300));

    // ── FIX: tipe 'e' unknown ────────────────────────────────
    } catch (e) {
      errors.push(`${source.source}: ${e instanceof Error ? e.message : String(e)}`);
    }
  }

  return new Response(
    JSON.stringify({ success: true, total_inserted: totalInserted, total_skipped: totalSkipped, sources_count: sources.length, errors }),
    { headers: { "Content-Type": "application/json" } }
  );
});