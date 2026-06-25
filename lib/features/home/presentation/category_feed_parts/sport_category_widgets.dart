part of '../category_feed_screen.dart';

class _SportHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _SportHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.sports_soccer_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.black,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NewsImage(
                  url: article.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.94),
                        Colors.black.withValues(alpha: 0.48),
                        Colors.black.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sports_soccer_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'MATCH CENTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: InkWell(
                    onTap: onBookmark,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        article.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: article.isBookmarked
                            ? AppTheme.primary
                            : Colors.white,
                        size: 23,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 26,
                  right: 220,
                  bottom: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SolidLabel(text: 'Sport'),
                      const SizedBox(height: 12),
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if ((article.summary ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          article.summary!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: Colors.white70,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            article.timeAgo,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.74),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SportHorizontalHighlights extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _SportHorizontalHighlights({
    required this.articles,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final article = articles[index];

          return SizedBox(
            width: 310,
            child: _SportHighlightHorizontalCard(
              article: article,
              onTap: () => onOpen(article),
              onBookmark: () => onBookmark(article),
            ),
          );
        },
      ),
    );
  }
}

class _SportHighlightHorizontalCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _SportHighlightHorizontalCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NewsImage(
                url: article.imageUrl,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: 10,
                left: 10,
                child: _SolidLabel(text: 'Highlight'),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: IconButton(
                  icon: Icon(
                    article.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    color:
                        article.isBookmarked ? AppTheme.primary : Colors.white,
                  ),
                  onPressed: onBookmark,
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _SportNewsRow({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: NewsImage(
                  url: article.imageUrl,
                  width: 210,
                  height: 124,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _OutlineLabel(text: 'Sport News'),
                    const SizedBox(height: 9),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
                        fontSize: 18,
                        height: 1.32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if ((article.summary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        article.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.timeAgo,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  article.isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  color: article.isBookmarked ? AppTheme.primary : Colors.grey,
                ),
                onPressed: onBookmark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportUpdateBox extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _SportUpdateBox({
    required this.articles,
    required this.onOpen,
  });

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
                    const Icon(
                      Icons.sports_score_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF202020),
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

class _SportTrendingBox extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _SportTrendingBox({
    required this.articles,
    required this.onOpen,
  });

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
                    Text(
                      '$index',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF202020),
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

class _SportStoryGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _SportStoryGrid({
    required this.articles,
    required this.columns,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      itemCount: articles.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: columns == 1 ? 1.65 : 1.02,
      ),
      itemBuilder: (_, index) {
        final article = articles[index];

        return ArticleCard(
          article: article,
          onTap: () => onOpen(article),
          onBookmark: () => onBookmark(article),
        );
      },
    );
  }
}
