import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/news_provider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(articlesProvider);
    }
  }

  Future<void> _bookmark(Article article) async {
    await toggleBookmark(article.id, article.isBookmarked);
    ref.invalidate(articlesProvider);
    ref.invalidate(bookmarksProvider);
  }

  void _openArticle(BuildContext context, Article article) {
    context.go('/home/article/${article.id}');
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(articlesProvider);
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;

    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;
    final isMobile = !isDesktop && !isTablet;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111111)
          : const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => ref.refresh(articlesProvider.future),
        child: articlesAsync.when(
          loading: () => const _LoadingHome(),
          error: (e, _) => ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.wifi_off_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat berita',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref.invalidate(articlesProvider),
                      child: const Text(
                        'Coba lagi',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          data: (articles) {
            if (articles.isEmpty) {
              return const Center(child: Text('Belum ada berita'));
            }

            final hero = articles.first;
            final sideArticles = articles.skip(1).take(4).toList();
            final latest = articles.skip(5).toList();
            final gridArticles = latest.take(6).toList();
            final videoArticles = articles.skip(2).take(8).toList();
            final popularArticles = articles.skip(1).take(5).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 20 : 16,
                          isMobile ? mediaQuery.padding.top + 12 : 0,
                          isDesktop ? 20 : 16,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isDesktop)
                              _DesktopHeadlineLayout(
                                hero: hero,
                                sideArticles: sideArticles,
                                popularArticles: popularArticles,
                                onOpen: (article) =>
                                    _openArticle(context, article),
                                onBookmark: _bookmark,
                              )
                            else if (isTablet)
                              _TabletHeadlineLayout(
                                hero: hero,
                                sideArticles: sideArticles,
                                onOpen: (article) =>
                                    _openArticle(context, article),
                                onBookmark: _bookmark,
                              )
                            else
                              _MobileHeadlineLayout(
                                hero: hero,
                                articles: sideArticles,
                                onOpen: (article) =>
                                    _openArticle(context, article),
                                onBookmark: _bookmark,
                              ),
                            const SizedBox(height: 30),
                            _SectionHeader(
                              title: 'Berita Terkini',
                              onSeeAll: () => context.go('/home'),
                            ),
                            const SizedBox(height: 14),
                            if (isDesktop)
                              _DesktopLatestLayout(
                                articles: latest,
                                popularArticles: popularArticles,
                                onOpen: (article) =>
                                    _openArticle(context, article),
                                onBookmark: _bookmark,
                              )
                            else if (isMobile)
                              _MobileArticleList(
                                articles: gridArticles.isEmpty
                                    ? sideArticles
                                    : gridArticles,
                                onOpen: (article) =>
                                    _openArticle(context, article),
                                onBookmark: _bookmark,
                              )
                            else
                              _ResponsiveGrid(
                                articles: gridArticles.isEmpty
                                    ? sideArticles
                                    : gridArticles,
                                columns: isTablet ? 2 : 1,
                                onOpen: (article) =>
                                    _openArticle(context, article),
                                onBookmark: _bookmark,
                              ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _VideoSection(
                    articles: videoArticles,
                    onOpen: (article) => _openArticle(context, article),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 20 : 16,
                          30,
                          isDesktop ? 20 : 16,
                          34,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionHeader(title: 'Latest News'),
                            const SizedBox(height: 14),
                            if (isMobile)
                              _MobileArticleList(
                                articles: latest.take(6).toList(),
                                onOpen: (article) =>
                                    _openArticle(context, article),
                                onBookmark: _bookmark,
                              )
                            else
                              Column(
                                children: latest.take(6).map((article) {
                                  return _NewsListRow(
                                    article: article,
                                    onTap: () => _openArticle(context, article),
                                    onBookmark: () => _bookmark(article),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: _HomeFooter(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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

class _HeroNewsCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _HeroNewsCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(14),
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
                      Colors.black.withValues(alpha: 0.02),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: InkWell(
                  onTap: onBookmark,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.42),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      article.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: article.isBookmarked
                          ? AppTheme.primary
                          : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.category != null)
                      _SolidCategoryLabel(article.category!),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if ((article.summary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
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
                    const SizedBox(height: 8),
                    Text(
                      article.timeAgo,
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
    );

    if (height != null) {
      return SizedBox(height: height, child: card);
    }

    return card;
  }
}

class _MiniFeatureCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _MiniFeatureCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
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
                      Colors.black.withValues(alpha: 0.86),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.category != null)
                      _SolidCategoryLabel(article.category!, small: true),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularPanel extends StatelessWidget {
  final String title;
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _PopularPanel({
    required this.title,
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleArticles = articles.take(5).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFixedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;

        final borderColor =
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);

        const headerHeight = 54.0;
        const dividerHeight = 1.0;

        double? itemHeight;

        if (hasFixedHeight && visibleArticles.isNotEmpty) {
          final availableHeight =
              constraints.maxHeight - headerHeight - dividerHeight;

          itemHeight = availableHeight / visibleArticles.length;
        }

        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: hasFixedHeight ? MainAxisSize.max : MainAxisSize.min,
            children: [
              SizedBox(
                height: headerHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF202020),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: dividerHeight,
                thickness: dividerHeight,
                color: borderColor,
              ),
              ...visibleArticles.map((article) {
                return _PopularTile(
                  article: article,
                  height: itemHeight ?? 68,
                  onTap: () => onOpen(article),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _PopularTile extends StatelessWidget {
  final Article article;
  final double height;
  final VoidCallback onTap;

  const _PopularTile({
    required this.article,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageHeight = height <= 62 ? 46.0 : 52.0;
    final imageWidth = height <= 62 ? 64.0 : 72.0;
    final fontSize = height <= 62 ? 12.0 : 12.5;

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NewsImage(
                    url: article.imageUrl,
                    width: imageWidth,
                    height: imageHeight,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF202020),
                      fontSize: fontSize,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                    ),
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

class _NewsListRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _NewsListRow({
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: NewsImage(
                    url: article.imageUrl,
                    width: 190,
                    height: 112,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.category != null)
                        CategoryBadge(category: article.category!),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF202020),
                          fontSize: 17,
                          height: 1.35,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if ((article.summary ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
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
                      const SizedBox(height: 8),
                      Text(
                        article.timeAgo,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontSize: 12,
                        ),
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
                    color:
                        article.isBookmarked ? AppTheme.primary : Colors.grey,
                  ),
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

class _VideoSection extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _VideoSection({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFF151515),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Video Terbaru',
                  dark: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: articles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, index) {
                      final article = articles[index];

                      return _VideoCard(
                        article: article,
                        onTap: () => onOpen(article),
                      );
                    },
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

class _VideoCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _VideoCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NewsImage(
                    url: article.imageUrl,
                    width: 280,
                    height: 156,
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool dark;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.dark = false,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        dark ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _SolidCategoryLabel extends StatelessWidget {
  final String label;
  final bool small;

  const _SolidCategoryLabel(
    this.label, {
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 9,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 60,
              runSpacing: 24,
              children: [
                _FooterColumn(
                  title: 'TAR News',
                  items: [
                    'Portal berita cepat dan terpercaya',
                    'Menyajikan berita terkini Indonesia',
                  ],
                ),
                _FooterColumn(
                  title: 'Menu',
                  items: [
                    'Beranda',
                    'Kategori',
                    'Bookmark',
                    'Profil',
                  ],
                ),
                _FooterColumn(
                  title: 'Follow Us',
                  items: [
                    'Instagram',
                    'Facebook',
                    'X',
                    'YouTube',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FooterColumn({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                item,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
