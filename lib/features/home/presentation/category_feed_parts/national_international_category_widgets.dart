part of '../category_feed_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// NATIONAL & INTERNATIONAL CATEGORY WIDGETS
// Thin entry-point: config specific + komponen unik.
// Widget struktural sudah dipindah ke shared_category_widgets.dart
// ════════════════════════════════════════════════════════════════════════════

// ── International header (memakai _CategoryIconHeader dari shared) ─────────
class _InternationalHeader extends StatelessWidget {
  final _CategoryInfo info;
  const _InternationalHeader({required this.info});

  @override
  Widget build(BuildContext context) => _CategoryIconHeader(
        info: info,
        icon: Icons.public_rounded,
      );
}

// ── Nasional hero card (delegasi ke _CategoryHeroCard) ────────────────────
class _NasionalHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  const _NasionalHeroCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) => _CategoryHeroCard(
        article: article,
        onTap: onTap,
        onBookmark: onBookmark,
        badgeLabel: 'NASIONAL',
        badgeIcon: Icons.flag_rounded,
        height: height,
      );
}

// ── International hero card (delegasi ke _CategoryHeroCard) ───────────────
class _InternationalHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  const _InternationalHeroCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) => _CategoryHeroCard(
        article: article,
        onTap: onTap,
        onBookmark: onBookmark,
        badgeLabel: 'INTERNASIONAL',
        badgeIcon: Icons.language_rounded,
        height: height,
      );
}

// ── Nasional side panel (unik: panel judul + thumbnail kecil) ─────────────
class _NasionalSidePanel extends StatelessWidget {
  final String title;
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _NasionalSidePanel({required this.title, required this.articles, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 4, height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF202020),
                      fontSize: 18, fontWeight: FontWeight.w900,
                    )),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF)),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: articles.length,
              separatorBuilder: (_, __) => Divider(
                  height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF)),
              itemBuilder: (context, index) {
                final article = articles[index];
                return InkWell(
                  onTap: () => onOpen(article),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: NewsImage(url: article.imageUrl, width: 92, height: 64),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(article.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF202020),
                                fontSize: 13, height: 1.3, fontWeight: FontWeight.w800,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── International brief panel (unik: bullet list global) ──────────────────
class _InternationalBriefPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _InternationalBriefPanel({required this.articles, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.language_rounded, color: AppTheme.primary, size: 21),
                const SizedBox(width: 8),
                Text('Global Brief',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF202020),
                      fontSize: 18, fontWeight: FontWeight.w900,
                    )),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF)),
          ...articles.map((article) {
            final isLast = article == articles.last;
            return Column(
              children: [
                InkWell(
                  onTap: () => onOpen(article),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      children: [
                        Container(
                          width: 9, height: 9,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(article.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF202020),
                                fontSize: 13.5, height: 1.35, fontWeight: FontWeight.w800,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── World highlight strip (unik: horizontal card dengan label 'World') ────
class _WorldHighlightStrip extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _WorldHighlightStrip({required this.articles, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final article = articles[index];
          return SizedBox(
            width: 310,
            child: InkWell(
              onTap: () => onOpen(article),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NewsImage(url: article.imageUrl, width: 310, height: 240),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.86),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14, right: 14, bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SolidLabel(text: 'World'),
                          const SizedBox(height: 8),
                          Text(article.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17, height: 1.25, fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── International fact box (unik: side panel text-only) ───────────────────
class _InternationalFactBox extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _InternationalFactBox({required this.articles, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Global Focus'),
          const SizedBox(height: 14),
          ...articles.take(4).map((article) {
            return InkWell(
              onTap: () => onOpen(article),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF202020),
                      fontSize: 14, height: 1.35, fontWeight: FontWeight.w800,
                    )),
              ),
            );
          }),
        ],
      ),
    );
  }
}
