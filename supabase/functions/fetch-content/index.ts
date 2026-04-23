// supabase/functions/fetch-content/index.ts
Deno.serve(async (req: Request) => {
  const { url } = await req.json();
  if (!url) {
    return new Response(JSON.stringify({ error: "URL required" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const res = await fetch(url, {
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "id-ID,id;q=0.9,en;q=0.8",
        "Cache-Control": "no-cache",
      },
      signal: AbortSignal.timeout(15000),
    });

    if (!res.ok) {
      return new Response(
        JSON.stringify({ error: `HTTP ${res.status}`, content: null }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    const html = await res.text();

    // ── Coba berbagai selector konten berita Indonesia ──
    const contentSelectors = [
      // Antara News
      /class="[^"]*post-body[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
      /class="[^"]*content-article[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
      // Detik
      /class="[^"]*detail__body[^"]*"[^>]*>([\s\S]*?)<div class="[^"]*detail__body/i,
      // CNN Indonesia
      /class="[^"]*detail-text[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
      /class="[^"]*article__content[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
      // Okezone / Liputan6
      /class="[^"]*article-content[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
      /class="[^"]*read__content[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
      // Tempo
      /class="[^"]*detail-content[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
      // Republika
      /class="[^"]*artikel-konten[^"]*"[^>]*>([\s\S]*?)<\/div>/i,
      // Generic
      /<article[^>]*>([\s\S]*?)<\/article>/i,
      /<main[^>]*>([\s\S]*?)<\/main>/i,
    ];

    let rawContent = "";
    for (const selector of contentSelectors) {
      const match = html.match(selector);
      if (match && match[1] && match[1].length > 200) {
        rawContent = match[1];
        break;
      }
    }

    // Kalau tidak ada selector yang cocok, ambil semua <p> dari seluruh HTML
    const source = rawContent || html;

    const paragraphs: string[] = [];
    const pRegex = /<p[^>]*>([\s\S]*?)<\/p>/gi;
    let match;
    while ((match = pRegex.exec(source)) !== null) {
      const text = match[1]
        .replace(/<script[\s\S]*?<\/script>/gi, "")
        .replace(/<style[\s\S]*?<\/style>/gi, "")
        .replace(/<[^>]*>/g, "")
        .replace(/&amp;/g, "&")
        .replace(/&lt;/g, "<")
        .replace(/&gt;/g, ">")
        .replace(/&quot;/g, '"')
        .replace(/&#39;/g, "'")
        .replace(/&nbsp;/g, " ")
        .replace(/\s+/g, " ")
        .trim();

      if (text.length > 80) {
        paragraphs.push(text);
      }
    }

    // Deduplicate paragraf
    const seen = new Set<string>();
    const unique = paragraphs.filter((p) => {
      if (seen.has(p)) return false;
      seen.add(p);
      return true;
    });

    const content = unique.slice(0, 25).join("\n\n");

    // Debug info
    console.log(`URL: ${url}`);
    console.log(`HTML length: ${html.length}`);
    console.log(`Paragraphs found: ${paragraphs.length}`);
    console.log(`Content length: ${content.length}`);

    return new Response(
      JSON.stringify({
        content: content.length > 100 ? content : null,
        debug: {
          html_length: html.length,
          paragraphs_found: paragraphs.length,
          content_length: content.length,
        },
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    const errMsg = e instanceof Error ? e.message : String(e);
    console.error(`Error fetching ${url}: ${errMsg}`);
    return new Response(
      JSON.stringify({ error: errMsg, content: null }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }
});