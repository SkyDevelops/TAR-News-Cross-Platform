part of '../feed_screen.dart';

class _LoadingHome extends StatelessWidget {
  const _LoadingHome();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerCard(),
        SizedBox(height: 12),
        ShimmerCard(),
        SizedBox(height: 12),
        ShimmerCard(),
      ],
    );
  }
}

class _DesktopHeadlineLayout extends StatelessWidget {
  final Article hero;
  final List<Article> sideArticles;
  final List<Article> popularArticles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _DesktopHeadlineLayout({
    required this.hero,
    required this.sideArticles,
    required this.popularArticles,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final smallArticles = sideArticles.take(2).toList();

    return SizedBox(
      height: 430,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _HeroNewsCard(
              article: hero,
              onTap: () => onOpen(hero),
              onBookmark: () => onBookmark(hero),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              children: smallArticles.map((article) {
                final isLast = article == smallArticles.last;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: _MiniFeatureCard(
                      article: article,
                      onTap: () => onOpen(article),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            height: 430,
            child: _PopularPanel(
              title: 'Terpopuler',
              articles: popularArticles,
              onOpen: onOpen,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletHeadlineLayout extends StatelessWidget {
  final Article hero;
  final List<Article> sideArticles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _TabletHeadlineLayout({
    required this.hero,
    required this.sideArticles,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroNewsCard(
          article: hero,
          height: 360,
          onTap: () => onOpen(hero),
          onBookmark: () => onBookmark(hero),
        ),
        const SizedBox(height: 16),
        _ResponsiveGrid(
          articles: sideArticles,
          columns: 2,
          onOpen: onOpen,
          onBookmark: onBookmark,
        ),
      ],
    );
  }
}

class _MobileHeadlineLayout extends StatelessWidget {
  final Article hero;
  final List<Article> articles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _MobileHeadlineLayout({
    required this.hero,
    required this.articles,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileHeroNewsCard(
          article: hero,
          onTap: () => onOpen(hero),
          onBookmark: () => onBookmark(hero),
        ),
        const SizedBox(height: 12),
        _MobileArticleList(
          articles: articles,
          onOpen: onOpen,
          onBookmark: onBookmark,
        ),
      ],
    );
  }
}

class _MobileArticleList extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _MobileArticleList({
    required this.articles,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: articles.map((article) {
        return _MobileArticleTile(
          article: article,
          onTap: () => onOpen(article),
          onBookmark: () => onBookmark(article),
        );
      }).toList(),
    );
  }
}

class _MobileHeroNewsCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _MobileHeroNewsCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 260,
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
                        Colors.black.withValues(alpha: 0.02),
                        Colors.black.withValues(alpha: 0.22),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _MobileBookmarkButton(
                    isBookmarked: article.isBookmarked,
                    onPressed: onBookmark,
                    onDarkBackground: true,
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.category != null)
                        _MobileCategoryPill(
                          label: article.category!.toUpperCase(),
                          solid: true,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          height: 1.16,
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
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        article.timeAgo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                        ),
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

class _MobileArticleTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _MobileArticleTile({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth < 370 ? 104.0 : 118.0;
    final imageHeight = screenWidth < 370 ? 84.0 : 92.0;
    final borderColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE7E7E7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NewsImage(
                  url: article.imageUrl,
                  width: imageWidth,
                  height: imageHeight,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.category != null) ...[
                        _MobileCategoryPill(label: article.category!),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF202020),
                          fontSize: 15.5,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if ((article.summary ?? '').isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          article.summary!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 12.5,
                            height: 1.32,
                          ),
                        ),
                      ],
                      const SizedBox(height: 7),
                      Text(
                        article.timeAgo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _MobileBookmarkButton(
                  isBookmarked: article.isBookmarked,
                  onPressed: onBookmark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileCategoryPill extends StatelessWidget {
  final String label;
  final bool solid;

  const _MobileCategoryPill({
    required this.label,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        solid ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.1);
    final textColor = solid ? Colors.white : AppTheme.primary;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: solid ? 9 : 8,
            vertical: solid ? 5 : 4,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: solid ? 11 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileBookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback onPressed;
  final bool onDarkBackground;

  const _MobileBookmarkButton({
    required this.isBookmarked,
    required this.onPressed,
    this.onDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isBookmarked
        ? AppTheme.primary
        : onDarkBackground
            ? Colors.white
            : Colors.grey;

    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor:
              onDarkBackground ? Colors.black.withValues(alpha: 0.42) : null,
        ),
        icon: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
          color: iconColor,
          size: 23,
        ),
      ),
    );
  }
}

class _DesktopLatestLayout extends StatelessWidget {
  final List<Article> articles;
  final List<Article> popularArticles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _DesktopLatestLayout({
    required this.articles,
    required this.popularArticles,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final leftArticles = articles.take(8).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftArticles.map((article) {
              return _NewsListRow(
                article: article,
                onTap: () => onOpen(article),
                onBookmark: () => onBookmark(article),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 300,
          child: _PopularPanel(
            title: 'Rekomendasi',
            articles: popularArticles,
            onOpen: onOpen,
          ),
        ),
      ],
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _ResponsiveGrid({
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
        childAspectRatio: columns == 1 ? 1.65 : 1.08,
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
