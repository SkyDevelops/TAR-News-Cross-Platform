part of '../category_feed_screen.dart';

// --- SPORT CATEGORY WIDGETS ---
// Thin entry-point: config sport-specific + komponen unik.
// Widget struktural sudah dipindah ke shared_category_widgets.dart

// --- Sport header ---
class _SportHeader extends StatelessWidget {
  final _CategoryInfo info;
  const _SportHeader({required this.info});

  @override
  Widget build(BuildContext context) => _CategoryIconHeader(
        info: info,
        icon: Icons.sports_soccer_rounded,
      );
}

// --- Sport main hero ---
class _SportMainHero extends StatelessWidget {
  final Article article;
  final double height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  const _SportMainHero({
    required this.article,
    required this.height,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) => _CategoryHeroCard(
        article: article,
        onTap: onTap,
        onBookmark: onBookmark,
        badgeLabel: 'MATCH CENTER',
        badgeIcon: Icons.sports_soccer_rounded,
        height: height,
      );
}

// --- Sport horizontal highlights ---
class _SportHorizontalHighlights extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;
  const _SportHorizontalHighlights(
      {required this.articles, required this.onOpen, required this.onBookmark});

  @override
  Widget build(BuildContext context) => _CategoryHorizontalScroll(
        articles: articles,
        cardBuilder: (article) => _CategoryHorizontalCard(
          article: article,
          labelText: 'Highlight',
          onTap: () => onOpen(article),
          onBookmark: () => onBookmark(article),
        ),
      );
}

// --- Sport news row ---
class _SportNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  const _SportNewsRow(
      {required this.article, required this.onTap, required this.onBookmark});

  @override
  Widget build(BuildContext context) => _CategoryNewsRow(
        article: article,
        labelText: 'Sport News',
        onTap: onTap,
        onBookmark: onBookmark,
      );
}

// --- Sport update box ---
class _SportUpdateBox extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _SportUpdateBox({required this.articles, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Sport Updates'),
          const SizedBox(height: 14),
          ...articles.map((article) {
            return InkWell(
              onTap: () => onOpen(article),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_score_rounded,
                        color: AppTheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(article.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : const Color(0xFF202020),
                            fontSize: 13.5,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// --- Sport trending box ---
class _SportTrendingBox extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _SportTrendingBox({required this.articles, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Trending Sport'),
          const SizedBox(height: 14),
          ...articles.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final article = entry.value;
            return InkWell(
              onTap: () => onOpen(article),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$index',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(article.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : const Color(0xFF202020),
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// --- Sport story grid ---
class _SportStoryGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;
  const _SportStoryGrid(
      {required this.articles,
      required this.columns,
      required this.onOpen,
      required this.onBookmark});

  @override
  Widget build(BuildContext context) => _CategoryArticleGrid(
        articles: articles,
        columns: columns,
        onOpen: onOpen,
        onBookmark: onBookmark,
      );
}
