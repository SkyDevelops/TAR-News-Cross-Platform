import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/news_provider.dart';

class CategoryFeedScreen extends ConsumerWidget {
  final String slug;

  const CategoryFeedScreen({
    super.key,
    required this.slug,
  });

  _CategoryInfo get _info => _CategoryInfo.fromSlug(slug);

  Future<void> _bookmark(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) async {
    final saved = await toggleBookmark(article.id, article.isBookmarked);
    if (!saved) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login dulu untuk menyimpan bookmark')),
      );
      context.go(
        '/login?redirect=${Uri.encodeComponent('/home/category/$slug')}',
      );
      return;
    }
    ref.invalidate(articlesByCategoryProvider(_info.queryCategory));
    ref.invalidate(articlesProvider);
    ref.invalidate(bookmarksProvider);
  }

  void _openArticle(BuildContext context, Article article) {
    context.go('/home/article/${article.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = _info;
    final articlesAsync =
        ref.watch(articlesByCategoryProvider(info.queryCategory));

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111111)
          : const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => ref.refresh(
          articlesByCategoryProvider(info.queryCategory).future,
        ),
        child: articlesAsync.when(
          loading: () => const _CategoryLoading(),
          error: (e, _) => _CategoryError(
            title: info.title,
            onRetry: () => ref.invalidate(
              articlesByCategoryProvider(info.queryCategory),
            ),
          ),
          data: (articles) {
            if (articles.isEmpty) {
              return _CategoryEmpty(title: info.title);
            }

            if (info.slug == 'nasional') {
              return _NasionalCategoryPage(
                info: info,
                articles: articles,
                isDesktop: isDesktop,
                isTablet: isTablet,
                onOpen: (article) => _openArticle(context, article),
                onBookmark: (article) => _bookmark(context, ref, article),
              );
            }

            if (info.slug == 'internasional') {
              return _InternasionalCategoryPage(
                info: info,
                articles: articles,
                isDesktop: isDesktop,
                isTablet: isTablet,
                onOpen: (article) => _openArticle(context, article),
                onBookmark: (article) => _bookmark(context, ref, article),
              );
            }

            if (info.slug == 'sport') {
              return _SportCategoryPage(
                info: info,
                articles: articles,
                isDesktop: isDesktop,
                isTablet: isTablet,
                onOpen: (article) => _openArticle(context, article),
                onBookmark: (article) => _bookmark(context, ref, article),
              );
            }

            if (info.slug == 'finance') {
              return _FinanceCategoryPage(
                info: info,
                articles: articles,
                isDesktop: isDesktop,
                isTablet: isTablet,
                onOpen: (article) => _openArticle(context, article),
                onBookmark: (article) => _bookmark(context, ref, article),
              );
            }

            if (info.slug == 'teknologi') {
              return _TechnologyCategoryPage(
                info: info,
                articles: articles,
                isDesktop: isDesktop,
                isTablet: isTablet,
                onOpen: (article) => _openArticle(context, article),
                onBookmark: (article) => _bookmark(context, ref, article),
              );
            }

            if (info.slug == 'otomotif') {
              return _AutomotiveCategoryPage(
                info: info,
                articles: articles,
                isDesktop: isDesktop,
                isTablet: isTablet,
                onOpen: (article) => _openArticle(context, article),
                onBookmark: (article) => _bookmark(context, ref, article),
              );
            }

            if (info.slug == 'travel') {
              return _TravelCategoryPage(
                info: info,
                articles: articles,
                isDesktop: isDesktop,
                isTablet: isTablet,
                onOpen: (article) => _openArticle(context, article),
                onBookmark: (article) => _bookmark(context, ref, article),
              );
            }

            if (info.slug == 'lifestyle') {
              return _LifestyleCategoryPage(
                info: info,
                articles: articles,
                isDesktop: isDesktop,
                isTablet: isTablet,
                onOpen: (article) => _openArticle(context, article),
                onBookmark: (article) => _bookmark(context, ref, article),
              );
            }

            return _GenericCategoryPage(
              info: info,
              articles: articles,
              isDesktop: isDesktop,
              isTablet: isTablet,
              onOpen: (article) => _openArticle(context, article),
              onBookmark: (article) => _bookmark(context, ref, article),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryInfo {
  final String slug;
  final String title;
  final String queryCategory;
  final String subtitle;

  const _CategoryInfo({
    required this.slug,
    required this.title,
    required this.queryCategory,
    required this.subtitle,
  });

  factory _CategoryInfo.fromSlug(String rawSlug) {
    final slug = rawSlug.toLowerCase();

    switch (slug) {
      case 'nasional':
        return const _CategoryInfo(
          slug: 'nasional',
          title: 'Nasional',
          queryCategory: 'Nasional',
          subtitle:
              'Berita nasional terbaru, aktual, dan terpercaya dari seluruh Indonesia.',
        );
      case 'internasional':
        return const _CategoryInfo(
          slug: 'internasional',
          title: 'Internasional',
          queryCategory: 'Internasional',
          subtitle:
              'Kabar dunia terbaru, isu global, diplomasi, dan peristiwa internasional.',
        );
      case 'sport':
        return const _CategoryInfo(
          slug: 'sport',
          title: 'Sport',
          queryCategory: 'Sport',
          subtitle: 'Update olahraga, pertandingan, dan atlet terkini.',
        );
      case 'finance':
        return const _CategoryInfo(
          slug: 'finance',
          title: 'Finance',
          queryCategory: 'Finance',
          subtitle: 'Berita ekonomi, bisnis, pasar, dan keuangan.',
        );
      case 'teknologi':
        return const _CategoryInfo(
          slug: 'teknologi',
          title: 'Teknologi',
          queryCategory: 'Teknologi',
          subtitle: 'Informasi teknologi, digital, dan inovasi terbaru.',
        );
      case 'otomotif':
        return const _CategoryInfo(
          slug: 'otomotif',
          title: 'Otomotif',
          queryCategory: 'Otomotif',
          subtitle: 'Berita otomotif, kendaraan, dan industri mobilitas.',
        );
      case 'travel':
        return const _CategoryInfo(
          slug: 'travel',
          title: 'Travel',
          queryCategory: 'Travel',
          subtitle: 'Destinasi, perjalanan, dan inspirasi wisata.',
        );
      case 'lifestyle':
        return const _CategoryInfo(
          slug: 'lifestyle',
          title: 'Lifestyle',
          queryCategory: 'Lifestyle',
          subtitle: 'Tren gaya hidup, hiburan, dan inspirasi harian.',
        );
      default:
        return _CategoryInfo(
          slug: slug,
          title: 'Nasional',
          queryCategory: 'Nasional',
          subtitle:
              'Berita nasional terbaru, aktual, dan terpercaya dari seluruh Indonesia.',
        );
    }
  }
}

class _NasionalCategoryPage extends StatelessWidget {
  final _CategoryInfo info;
  final List<Article> articles;
  final bool isDesktop;
  final bool isTablet;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _NasionalCategoryPage({
    required this.info,
    required this.articles,
    required this.isDesktop,
    required this.isTablet,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hero = articles.first;
    final headlineSide = articles.skip(1).take(3).toList();
    final topStories = articles.skip(4).take(6).toList();
    final latest = articles.skip(10).isEmpty
        ? articles.skip(1).take(6).toList()
        : articles.skip(10).take(8).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 16,
                  24,
                  isDesktop ? 20 : 16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryHeader(info: info),
                    const SizedBox(height: 20),
                    if (isDesktop)
                      SizedBox(
                        height: 390,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _NasionalHeroCard(
                                article: hero,
                                onTap: () => onOpen(hero),
                                onBookmark: () => onBookmark(hero),
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              width: 340,
                              child: _NasionalSidePanel(
                                title: 'Headline Nasional',
                                articles: headlineSide,
                                onOpen: onOpen,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          _NasionalHeroCard(
                            article: hero,
                            height: isTablet ? 360 : 300,
                            onTap: () => onOpen(hero),
                            onBookmark: () => onBookmark(hero),
                          ),
                          const SizedBox(height: 16),
                          _NasionalSidePanel(
                            title: 'Headline Nasional',
                            articles: headlineSide,
                            onOpen: onOpen,
                          ),
                        ],
                      ),
                    const SizedBox(height: 34),
                    const _SectionTitle(title: 'Top Stories Nasional'),
                    const SizedBox(height: 14),
                    _CategoryGrid(
                      articles: topStories.isEmpty
                          ? articles.skip(1).take(6).toList()
                          : topStories,
                      columns: isDesktop
                          ? 3
                          : isTablet
                              ? 2
                              : 1,
                      onOpen: onOpen,
                      onBookmark: onBookmark,
                    ),
                    const SizedBox(height: 34),
                    const _SectionTitle(title: 'Berita Nasional Terkini'),
                    const SizedBox(height: 14),
                    Column(
                      children: latest.map((article) {
                        return _CategoryListTile(
                          article: article,
                          onTap: () => onOpen(article),
                          onBookmark: () => onBookmark(article),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InternasionalCategoryPage extends StatelessWidget {
  final _CategoryInfo info;
  final List<Article> articles;
  final bool isDesktop;
  final bool isTablet;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _InternasionalCategoryPage({
    required this.info,
    required this.articles,
    required this.isDesktop,
    required this.isTablet,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hero = articles.first;
    final globalBrief = articles.skip(1).take(4).toList();
    final worldHighlights = articles.skip(5).take(6).toList();
    final latest = articles.skip(11).isEmpty
        ? articles.skip(1).take(8).toList()
        : articles.skip(11).take(8).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 16,
                  24,
                  isDesktop ? 20 : 16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InternationalHeader(info: info),
                    const SizedBox(height: 20),
                    if (isDesktop)
                      SizedBox(
                        height: 420,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _InternationalHeroCard(
                                article: hero,
                                onTap: () => onOpen(hero),
                                onBookmark: () => onBookmark(hero),
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              width: 330,
                              child: _InternationalBriefPanel(
                                articles: globalBrief,
                                onOpen: onOpen,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          _InternationalHeroCard(
                            article: hero,
                            height: isTablet ? 370 : 310,
                            onTap: () => onOpen(hero),
                            onBookmark: () => onBookmark(hero),
                          ),
                          const SizedBox(height: 16),
                          _InternationalBriefPanel(
                            articles: globalBrief,
                            onOpen: onOpen,
                          ),
                        ],
                      ),
                    const SizedBox(height: 34),
                    const _SectionTitle(title: 'World Highlights'),
                    const SizedBox(height: 14),
                    _WorldHighlightStrip(
                      articles: worldHighlights.isEmpty
                          ? articles.skip(1).take(6).toList()
                          : worldHighlights,
                      onOpen: onOpen,
                    ),
                    const SizedBox(height: 34),
                    const _SectionTitle(title: 'Latest International News'),
                    const SizedBox(height: 14),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: latest.map((article) {
                                return _InternationalListTile(
                                  article: article,
                                  onTap: () => onOpen(article),
                                  onBookmark: () => onBookmark(article),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 22),
                          SizedBox(
                            width: 300,
                            child: _InternationalFactBox(
                              articles: globalBrief,
                              onOpen: onOpen,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: latest.map((article) {
                          return _InternationalListTile(
                            article: article,
                            onTap: () => onOpen(article),
                            onBookmark: () => onBookmark(article),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SportCategoryPage extends StatelessWidget {
  final _CategoryInfo info;
  final List<Article> articles;
  final bool isDesktop;
  final bool isTablet;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _SportCategoryPage({
    required this.info,
    required this.articles,
    required this.isDesktop,
    required this.isTablet,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hero = articles.first;
    final highlights = articles.skip(1).take(6).toList();
    final latest = articles.skip(7).isEmpty
        ? articles.skip(1).take(8).toList()
        : articles.skip(7).take(8).toList();
    final trending = articles.skip(2).take(5).toList();
    final moreStories = articles.skip(10).isEmpty
        ? articles.skip(1).take(6).toList()
        : articles.skip(10).take(6).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 16,
                  24,
                  isDesktop ? 20 : 16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SportHeader(info: info),
                    const SizedBox(height: 20),
                    _SportMainHero(
                      article: hero,
                      height: isDesktop
                          ? 430
                          : isTablet
                              ? 370
                              : 310,
                      onTap: () => onOpen(hero),
                      onBookmark: () => onBookmark(hero),
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle(title: 'Match Highlights'),
                    const SizedBox(height: 14),
                    _SportHorizontalHighlights(
                      articles: highlights,
                      onOpen: onOpen,
                      onBookmark: onBookmark,
                    ),
                    const SizedBox(height: 34),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                  title: 'Latest Sport News',
                                ),
                                const SizedBox(height: 14),
                                ...latest.map((article) {
                                  return _SportNewsRow(
                                    article: article,
                                    onTap: () => onOpen(article),
                                    onBookmark: () => onBookmark(article),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 330,
                            child: Column(
                              children: [
                                _SportUpdateBox(
                                  articles: trending.take(3).toList(),
                                  onOpen: onOpen,
                                ),
                                const SizedBox(height: 18),
                                _SportTrendingBox(
                                  articles: trending,
                                  onOpen: onOpen,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(title: 'Latest Sport News'),
                          const SizedBox(height: 14),
                          ...latest.map((article) {
                            return _SportNewsRow(
                              article: article,
                              onTap: () => onOpen(article),
                              onBookmark: () => onBookmark(article),
                            );
                          }),
                          const SizedBox(height: 20),
                          _SportUpdateBox(
                            articles: trending.take(3).toList(),
                            onOpen: onOpen,
                          ),
                        ],
                      ),
                    const SizedBox(height: 34),
                    const _SectionTitle(title: 'More Sport Stories'),
                    const SizedBox(height: 14),
                    _SportStoryGrid(
                      articles: moreStories,
                      columns: isDesktop
                          ? 3
                          : isTablet
                              ? 2
                              : 1,
                      onOpen: onOpen,
                      onBookmark: onBookmark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FinanceCategoryPage extends StatelessWidget {
  final _CategoryInfo info;
  final List<Article> articles;
  final bool isDesktop;
  final bool isTablet;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _FinanceCategoryPage({
    required this.info,
    required this.articles,
    required this.isDesktop,
    required this.isTablet,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hero = articles.first;
    final marketBrief = articles.skip(1).take(4).toList();
    final businessHeadlines = articles.skip(5).take(6).toList();
    final latest = articles.skip(11).isEmpty
        ? articles.skip(1).take(8).toList()
        : articles.skip(11).take(8).toList();
    final moreStories = articles.skip(8).isEmpty
        ? articles.skip(1).take(6).toList()
        : articles.skip(8).take(6).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 16,
                  24,
                  isDesktop ? 20 : 16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FinanceHeader(info: info),
                    const SizedBox(height: 18),
                    const _MarketSummaryStrip(),
                    const SizedBox(height: 22),
                    if (isDesktop)
                      SizedBox(
                        height: 420,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _FinanceHeroCard(
                                article: hero,
                                onTap: () => onOpen(hero),
                                onBookmark: () => onBookmark(hero),
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              width: 330,
                              child: _FinanceBriefPanel(
                                articles: marketBrief,
                                onOpen: onOpen,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          _FinanceHeroCard(
                            article: hero,
                            height: isTablet ? 370 : 310,
                            onTap: () => onOpen(hero),
                            onBookmark: () => onBookmark(hero),
                          ),
                          const SizedBox(height: 16),
                          _FinanceBriefPanel(
                            articles: marketBrief,
                            onOpen: onOpen,
                          ),
                        ],
                      ),
                    const SizedBox(height: 34),
                    const _SectionTitle(title: 'Business Headlines'),
                    const SizedBox(height: 14),
                    _FinanceHorizontalHeadlines(
                      articles: businessHeadlines.isEmpty
                          ? articles.skip(1).take(6).toList()
                          : businessHeadlines,
                      onOpen: onOpen,
                      onBookmark: onBookmark,
                    ),
                    const SizedBox(height: 34),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                  title: 'Latest Finance News',
                                ),
                                const SizedBox(height: 14),
                                ...latest.map((article) {
                                  return _FinanceNewsRow(
                                    article: article,
                                    onTap: () => onOpen(article),
                                    onBookmark: () => onBookmark(article),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 330,
                            child: _FinanceInsightPanel(
                              articles: marketBrief,
                              onOpen: onOpen,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(title: 'Latest Finance News'),
                          const SizedBox(height: 14),
                          ...latest.map((article) {
                            return _FinanceNewsRow(
                              article: article,
                              onTap: () => onOpen(article),
                              onBookmark: () => onBookmark(article),
                            );
                          }),
                          const SizedBox(height: 20),
                          _FinanceInsightPanel(
                            articles: marketBrief,
                            onOpen: onOpen,
                          ),
                        ],
                      ),
                    const SizedBox(height: 34),
                    const _SectionTitle(title: 'More Finance Stories'),
                    const SizedBox(height: 14),
                    _FinanceStoryGrid(
                      articles: moreStories,
                      columns: isDesktop
                          ? 3
                          : isTablet
                              ? 2
                              : 1,
                      onOpen: onOpen,
                      onBookmark: onBookmark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TechnologyCategoryPage extends StatelessWidget {
  final _CategoryInfo info;
  final List<Article> articles;
  final bool isDesktop;
  final bool isTablet;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _TechnologyCategoryPage({
    required this.info,
    required this.articles,
    required this.isDesktop,
    required this.isTablet,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hero = articles.first;
    final radarArticles = articles.skip(1).take(3).toList();
    final signalArticles = articles.skip(4).take(4).toList();
    final latest = articles.skip(8).isEmpty
        ? articles.skip(1).take(8).toList()
        : articles.skip(8).take(8).toList();
    final gridArticles = articles.skip(1).take(6).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 16,
                  24,
                  isDesktop ? 20 : 16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TechnologyHeader(info: info),
                    const SizedBox(height: 20),
                    if (isDesktop)
                      SizedBox(
                        height: 430,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _TechnologyHeroCard(
                                article: hero,
                                onTap: () => onOpen(hero),
                                onBookmark: () => onBookmark(hero),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: _TechnologyRadarPanel(
                                articles: radarArticles,
                                onOpen: onOpen,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          _TechnologyHeroCard(
                            article: hero,
                            height: isTablet ? 380 : 300,
                            onTap: () => onOpen(hero),
                            onBookmark: () => onBookmark(hero),
                          ),
                          const SizedBox(height: 14),
                          _TechnologyRadarPanel(
                            articles: radarArticles,
                            onOpen: onOpen,
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    const _TechTopicStrip(),
                    const SizedBox(height: 28),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(title: 'Sorotan Digital'),
                                const SizedBox(height: 14),
                                _TechnologyFeatureGrid(
                                  articles: gridArticles,
                                  columns: 2,
                                  onOpen: onOpen,
                                  onBookmark: onBookmark,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 4,
                            child: _TechnologySignalPanel(
                              articles: signalArticles,
                              onOpen: onOpen,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(title: 'Sorotan Digital'),
                          const SizedBox(height: 14),
                          _TechnologyFeatureGrid(
                            articles: gridArticles,
                            columns: isTablet ? 2 : 1,
                            onOpen: onOpen,
                            onBookmark: onBookmark,
                          ),
                          const SizedBox(height: 20),
                          _TechnologySignalPanel(
                            articles: signalArticles,
                            onOpen: onOpen,
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    const _SectionTitle(title: 'Update Teknologi'),
                    const SizedBox(height: 14),
                    ...latest.map((article) {
                      return _TechnologyNewsRow(
                        article: article,
                        onTap: () => onOpen(article),
                        onBookmark: () => onBookmark(article),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GenericCategoryPage extends StatelessWidget {
  final _CategoryInfo info;
  final List<Article> articles;
  final bool isDesktop;
  final bool isTablet;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _GenericCategoryPage({
    required this.info,
    required this.articles,
    required this.isDesktop,
    required this.isTablet,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final columns = isDesktop
        ? 3
        : isTablet
            ? 2
            : 1;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 16,
                  24,
                  isDesktop ? 20 : 16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryHeader(info: info),
                    const SizedBox(height: 20),
                    _CategoryGrid(
                      articles: articles,
                      columns: columns,
                      onOpen: onOpen,
                      onBookmark: onBookmark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _CategoryHeader({
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
            width: 5,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(99),
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

class _TechnologyHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _TechnologyHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.memory_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 5),
                Text(
                  info.subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TechPill(text: 'AI'),
                    _TechPill(text: 'Gadget'),
                    _TechPill(text: 'Startup'),
                    _TechPill(text: 'Cyber'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechPill extends StatelessWidget {
  final String text;

  const _TechPill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE3E3E3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF202020),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TechnologyHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TechnologyHeroCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
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
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.22),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Radar Teknologi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.44),
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
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          article.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
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
    );

    if (height != null) {
      return SizedBox(height: height, child: card);
    }

    return card;
  }
}

class _TechnologyRadarPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _TechnologyRadarPanel({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.radar_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Sinyal Terbaru',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF202020),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (articles.isNotEmpty)
            ...articles.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == articles.length - 1 ? 0 : 12,
                ),
                child: _TechnologyRadarTile(
                  article: entry.value,
                  index: entry.key + 1,
                  onTap: () => onOpen(entry.value),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _TechnologyRadarTile extends StatelessWidget {
  final Article article;
  final int index;
  final VoidCallback onTap;

  const _TechnologyRadarTile({
    required this.article,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 14,
                    height: 1.32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  article.timeAgo,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 11,
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

class _TechTopicStrip extends StatelessWidget {
  const _TechTopicStrip();

  @override
  Widget build(BuildContext context) {
    const topics = [
      _TechTopic(label: 'AI Watch', icon: Icons.auto_awesome_rounded),
      _TechTopic(label: 'Gadget Lab', icon: Icons.devices_other_rounded),
      _TechTopic(label: 'Cyber Desk', icon: Icons.security_rounded),
      _TechTopic(label: 'Startup', icon: Icons.rocket_launch_rounded),
    ];

    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _TechTopicCard(topic: topics[index]);
        },
      ),
    );
  }
}

class _TechTopic {
  final String label;
  final IconData icon;

  const _TechTopic({
    required this.label,
    required this.icon,
  });
}

class _TechTopicCard extends StatelessWidget {
  final _TechTopic topic;

  const _TechTopicCard({
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(topic.icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF202020),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnologyFeatureGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _TechnologyFeatureGrid({
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
        childAspectRatio: columns == 1 ? 1.14 : 0.98,
      ),
      itemBuilder: (_, index) {
        final article = articles[index];
        return _TechnologyFeatureCard(
          article: article,
          onTap: () => onOpen(article),
          onBookmark: () => onBookmark(article),
        );
      },
    );
  }
}

class _TechnologyFeatureCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TechnologyFeatureCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  NewsImage(
                    url: article.imageUrl,
                    width: double.infinity,
                    height: 155,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.44),
                      ),
                      icon: Icon(
                        article.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: article.isBookmarked
                            ? AppTheme.primary
                            : Colors.white,
                        size: 20,
                      ),
                      onPressed: onBookmark,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _OutlineLabel(text: 'Teknologi'),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
                        fontSize: 16,
                        height: 1.3,
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
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
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

class _TechnologySignalPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _TechnologySignalPanel({
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
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Sinyal Inovasi'),
          const SizedBox(height: 14),
          ...articles.take(4).map((article) {
            return InkWell(
              onTap: () => onOpen(article),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.hub_rounded,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
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

class _TechnologyNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TechnologyNewsRow({
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              NewsImage(
                url: article.imageUrl,
                width: 190,
                height: 112,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _OutlineLabel(text: 'Update Teknologi'),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
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

class _AutomotiveCategoryPage extends StatelessWidget {
  final _CategoryInfo info;
  final List<Article> articles;
  final bool isDesktop;
  final bool isTablet;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _AutomotiveCategoryPage({
    required this.info,
    required this.articles,
    required this.isDesktop,
    required this.isTablet,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hero = articles.first;
    final pitlane = articles.skip(1).take(4).toList();
    final review = articles.skip(5).take(6).toList();
    final latest = articles.skip(11).isEmpty
        ? articles.skip(1).take(8).toList()
        : articles.skip(11).take(8).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 16,
                  24,
                  isDesktop ? 20 : 16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AutomotiveHeader(info: info),
                    const SizedBox(height: 18),
                    if (isDesktop)
                      SizedBox(
                        height: 430,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _AutomotiveHeroCard(
                                article: hero,
                                onTap: () => onOpen(hero),
                                onBookmark: () => onBookmark(hero),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: _AutomotivePitlanePanel(
                                articles: pitlane,
                                onOpen: onOpen,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          _AutomotiveHeroCard(
                            article: hero,
                            height: isTablet ? 380 : 300,
                            onTap: () => onOpen(hero),
                            onBookmark: () => onBookmark(hero),
                          ),
                          const SizedBox(height: 14),
                          _AutomotivePitlanePanel(
                            articles: pitlane,
                            onOpen: onOpen,
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    const _AutomotiveMetricStrip(),
                    const SizedBox(height: 28),
                    const _SectionTitle(title: 'Ulasan Kendaraan'),
                    const SizedBox(height: 14),
                    _AutomotiveReviewGrid(
                      articles: review,
                      columns: isDesktop
                          ? 3
                          : isTablet
                              ? 2
                              : 1,
                      onOpen: onOpen,
                      onBookmark: onBookmark,
                    ),
                    const SizedBox(height: 30),
                    const _SectionTitle(title: 'Update Otomotif'),
                    const SizedBox(height: 14),
                    ...latest.map((article) {
                      return _AutomotiveNewsRow(
                        article: article,
                        onTap: () => onOpen(article),
                        onBookmark: () => onBookmark(article),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TravelCategoryPage extends StatelessWidget {
  final _CategoryInfo info;
  final List<Article> articles;
  final bool isDesktop;
  final bool isTablet;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _TravelCategoryPage({
    required this.info,
    required this.articles,
    required this.isDesktop,
    required this.isTablet,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hero = articles.first;
    final postcards = articles.skip(1).take(2).toList();
    final destinations = articles.skip(3).take(6).toList();
    final routes = articles.skip(9).isEmpty
        ? articles.skip(1).take(6).toList()
        : articles.skip(9).take(6).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 16,
                  24,
                  isDesktop ? 20 : 16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TravelHeader(info: info),
                    const SizedBox(height: 20),
                    if (isDesktop)
                      SizedBox(
                        height: 440,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _TravelHeroCard(
                                article: hero,
                                onTap: () => onOpen(hero),
                                onBookmark: () => onBookmark(hero),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: postcards.map((article) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            article == postcards.last ? 0 : 14,
                                      ),
                                      child: _TravelPostcard(
                                        article: article,
                                        onTap: () => onOpen(article),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          _TravelHeroCard(
                            article: hero,
                            height: isTablet ? 380 : 310,
                            onTap: () => onOpen(hero),
                            onBookmark: () => onBookmark(hero),
                          ),
                          const SizedBox(height: 14),
                          ...postcards.map((article) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _TravelPostcard(
                                article: article,
                                height: 180,
                                onTap: () => onOpen(article),
                              ),
                            );
                          }),
                        ],
                      ),
                    const SizedBox(height: 18),
                    const _TravelRouteStrip(),
                    const SizedBox(height: 28),
                    const _SectionTitle(title: 'Destinasi Pilihan'),
                    const SizedBox(height: 14),
                    _TravelDestinationGrid(
                      articles: destinations,
                      columns: isDesktop
                          ? 3
                          : isTablet
                              ? 2
                              : 1,
                      onOpen: onOpen,
                      onBookmark: onBookmark,
                    ),
                    const SizedBox(height: 30),
                    const _SectionTitle(title: 'Cerita Perjalanan'),
                    const SizedBox(height: 14),
                    ...routes.map((article) {
                      return _TravelStoryRow(
                        article: article,
                        onTap: () => onOpen(article),
                        onBookmark: () => onBookmark(article),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LifestyleCategoryPage extends StatelessWidget {
  final _CategoryInfo info;
  final List<Article> articles;
  final bool isDesktop;
  final bool isTablet;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _LifestyleCategoryPage({
    required this.info,
    required this.articles,
    required this.isDesktop,
    required this.isTablet,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final spotlight = articles.first;
    final editorsPick = articles.skip(1).take(4).toList();
    final journal = articles.skip(5).take(6).toList();
    final latest = articles.skip(11).isEmpty
        ? articles.skip(1).take(8).toList()
        : articles.skip(11).take(8).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 20 : 16,
                  24,
                  isDesktop ? 20 : 16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LifestyleHeader(info: info),
                    const SizedBox(height: 20),
                    _LifestyleSpotlight(
                      article: spotlight,
                      isDesktop: isDesktop,
                      onTap: () => onOpen(spotlight),
                      onBookmark: () => onBookmark(spotlight),
                    ),
                    const SizedBox(height: 18),
                    const _LifestyleMoodStrip(),
                    const SizedBox(height: 28),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(title: 'Living Journal'),
                                const SizedBox(height: 14),
                                _LifestyleJournalGrid(
                                  articles: journal,
                                  columns: 2,
                                  onOpen: onOpen,
                                  onBookmark: onBookmark,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 4,
                            child: _LifestyleEditorPanel(
                              articles: editorsPick,
                              onOpen: onOpen,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LifestyleEditorPanel(
                            articles: editorsPick,
                            onOpen: onOpen,
                          ),
                          const SizedBox(height: 22),
                          const _SectionTitle(title: 'Living Journal'),
                          const SizedBox(height: 14),
                          _LifestyleJournalGrid(
                            articles: journal,
                            columns: isTablet ? 2 : 1,
                            onOpen: onOpen,
                            onBookmark: onBookmark,
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    const _SectionTitle(title: 'Update Lifestyle'),
                    const SizedBox(height: 14),
                    ...latest.map((article) {
                      return _LifestyleListTile(
                        article: article,
                        onTap: () => onOpen(article),
                        onBookmark: () => onBookmark(article),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AutomotiveHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _AutomotiveHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryIconHeader(
      info: info,
      icon: Icons.directions_car_filled_rounded,
      chips: const ['Mobil', 'Motor', 'EV', 'Modifikasi'],
    );
  }
}

class _TravelHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _TravelHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryIconHeader(
      info: info,
      icon: Icons.flight_takeoff_rounded,
      chips: const ['Destinasi', 'Hotel', 'Kuliner', 'Tips'],
    );
  }
}

class _LifestyleHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _LifestyleHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryIconHeader(
      info: info,
      icon: Icons.spa_rounded,
      chips: const ['Wellness', 'Style', 'Hiburan', 'Inspirasi'],
    );
  }
}

class _CategoryIconHeader extends StatelessWidget {
  final _CategoryInfo info;
  final IconData icon;
  final List<String> chips;

  const _CategoryIconHeader({
    required this.info,
    required this.icon,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 32),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 5),
                Text(
                  info.subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chips.map((chip) => _TechPill(text: chip)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AutomotiveHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _AutomotiveHeroCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryOverlayHero(
      article: article,
      label: 'Garasi Utama',
      icon: Icons.speed_rounded,
      height: height,
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _TravelHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TravelHeroCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryOverlayHero(
      article: article,
      label: 'Destinasi Utama',
      icon: Icons.explore_rounded,
      height: height,
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _LifestyleSpotlight extends StatelessWidget {
  final Article article;
  final bool isDesktop;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _LifestyleSpotlight({
    required this.article,
    required this.isDesktop,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryOverlayHero(
      article: article,
      label: 'Sorotan Lifestyle',
      icon: Icons.auto_awesome_rounded,
      height: isDesktop ? 430 : 320,
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _CategoryOverlayHero extends StatelessWidget {
  final Article article;
  final String label;
  final IconData icon;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _CategoryOverlayHero({
    required this.article,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
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
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.90),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.44),
                  ),
                  icon: Icon(
                    article.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    color:
                        article.isBookmarked ? AppTheme.primary : Colors.white,
                    size: 22,
                  ),
                  onPressed: onBookmark,
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
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
                    const SizedBox(height: 12),
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

class _AutomotivePitlanePanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _AutomotivePitlanePanel({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _NumberedArticlePanel(
      title: 'Pit Lane',
      icon: Icons.flag_rounded,
      articles: articles,
      onOpen: onOpen,
    );
  }
}

class _LifestyleEditorPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _LifestyleEditorPanel({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _NumberedArticlePanel(
      title: 'Pilihan Editor',
      icon: Icons.favorite_rounded,
      articles: articles,
      onOpen: onOpen,
    );
  }
}

class _NumberedArticlePanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _NumberedArticlePanel({
    required this.title,
    required this.icon,
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF202020),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (articles.isNotEmpty)
            ...articles.asMap().entries.map((entry) {
              final article = entry.value;

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onOpen(article),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == articles.length - 1 ? 0 : 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}',
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

class _AutomotiveMetricStrip extends StatelessWidget {
  const _AutomotiveMetricStrip();

  @override
  Widget build(BuildContext context) {
    const topics = [
      _CategoryTopic(label: 'Test Drive', icon: Icons.speed_rounded),
      _CategoryTopic(label: 'Motor', icon: Icons.two_wheeler_rounded),
      _CategoryTopic(label: 'EV', icon: Icons.electric_car_rounded),
      _CategoryTopic(label: 'Industri', icon: Icons.precision_manufacturing),
    ];

    return const _CategoryTopicStrip(topics: topics);
  }
}

class _TravelRouteStrip extends StatelessWidget {
  const _TravelRouteStrip();

  @override
  Widget build(BuildContext context) {
    const topics = [
      _CategoryTopic(label: 'Pantai', icon: Icons.beach_access_rounded),
      _CategoryTopic(label: 'Kota', icon: Icons.location_city_rounded),
      _CategoryTopic(label: 'Kuliner', icon: Icons.restaurant_rounded),
      _CategoryTopic(label: 'Panduan', icon: Icons.map_rounded),
    ];

    return const _CategoryTopicStrip(topics: topics);
  }
}

class _LifestyleMoodStrip extends StatelessWidget {
  const _LifestyleMoodStrip();

  @override
  Widget build(BuildContext context) {
    const topics = [
      _CategoryTopic(label: 'Wellness', icon: Icons.spa_rounded),
      _CategoryTopic(label: 'Fashion', icon: Icons.checkroom_rounded),
      _CategoryTopic(label: 'Hiburan', icon: Icons.movie_rounded),
      _CategoryTopic(label: 'Rumah', icon: Icons.weekend_rounded),
    ];

    return const _CategoryTopicStrip(topics: topics);
  }
}

class _CategoryTopic {
  final String label;
  final IconData icon;

  const _CategoryTopic({
    required this.label,
    required this.icon,
  });
}

class _CategoryTopicStrip extends StatelessWidget {
  final List<_CategoryTopic> topics;

  const _CategoryTopicStrip({
    required this.topics,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _CategoryTopicCard(topic: topics[index]);
        },
      ),
    );
  }
}

class _CategoryTopicCard extends StatelessWidget {
  final _CategoryTopic topic;

  const _CategoryTopicCard({
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(topic.icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF202020),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutomotiveReviewGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _AutomotiveReviewGrid({
    required this.articles,
    required this.columns,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryVisualGrid(
      articles: articles,
      columns: columns,
      label: 'Otomotif',
      onOpen: onOpen,
      onBookmark: onBookmark,
    );
  }
}

class _TravelDestinationGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _TravelDestinationGrid({
    required this.articles,
    required this.columns,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryVisualGrid(
      articles: articles,
      columns: columns,
      label: 'Travel',
      onOpen: onOpen,
      onBookmark: onBookmark,
    );
  }
}

class _LifestyleJournalGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _LifestyleJournalGrid({
    required this.articles,
    required this.columns,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryVisualGrid(
      articles: articles,
      columns: columns,
      label: 'Lifestyle',
      onOpen: onOpen,
      onBookmark: onBookmark,
    );
  }
}

class _CategoryVisualGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final String label;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _CategoryVisualGrid({
    required this.articles,
    required this.columns,
    required this.label,
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
        childAspectRatio: columns == 1 ? 1.14 : 0.98,
      ),
      itemBuilder: (_, index) {
        final article = articles[index];

        return _CategoryVisualCard(
          article: article,
          label: label,
          onTap: () => onOpen(article),
          onBookmark: () => onBookmark(article),
        );
      },
    );
  }
}

class _CategoryVisualCard extends StatelessWidget {
  final Article article;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _CategoryVisualCard({
    required this.article,
    required this.label,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  NewsImage(
                    url: article.imageUrl,
                    width: double.infinity,
                    height: 155,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.44),
                      ),
                      icon: Icon(
                        article.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: article.isBookmarked
                            ? AppTheme.primary
                            : Colors.white,
                        size: 20,
                      ),
                      onPressed: onBookmark,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OutlineLabel(text: label),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
                        fontSize: 16,
                        height: 1.3,
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
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
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

class _TravelPostcard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;

  const _TravelPostcard({
    required this.article,
    required this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
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
                      Colors.black.withValues(alpha: 0.03),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SolidLabel(text: 'Travel'),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
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

class _AutomotiveNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _AutomotiveNewsRow({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryHorizontalRow(
      article: article,
      label: 'Update Otomotif',
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _TravelStoryRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TravelStoryRow({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryHorizontalRow(
      article: article,
      label: 'Cerita Travel',
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _LifestyleListTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _LifestyleListTile({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryHorizontalRow(
      article: article,
      label: 'Update Lifestyle',
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _CategoryHorizontalRow extends StatelessWidget {
  final Article article;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _CategoryHorizontalRow({
    required this.article,
    required this.label,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              NewsImage(
                url: article.imageUrl,
                width: 190,
                height: 112,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OutlineLabel(text: label),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
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

class _InternationalHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _InternationalHeader({
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
              Icons.public_rounded,
              color: AppTheme.primary,
              size: 30,
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
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(16),
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
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.20),
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
                    const _SolidLabel(text: 'Nasional'),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.18,
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
  Widget build(BuildContext context) {
    final card = ClipRRect(
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
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.92),
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
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
                left: 24,
                right: 180,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SolidLabel(text: 'Internasional'),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.18,
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

class _NasionalSidePanel extends StatelessWidget {
  final String title;
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _NasionalSidePanel({
    required this.title,
    required this.articles,
    required this.onOpen,
  });

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
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF),
          ),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: articles.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color:
                    isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF),
              ),
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
                          child: NewsImage(
                            url: article.imageUrl,
                            width: 92,
                            height: 64,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            article.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF202020),
                              fontSize: 13,
                              height: 1.3,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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

class _InternationalBriefPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _InternationalBriefPanel({
    required this.articles,
    required this.onOpen,
  });

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
                const Icon(
                  Icons.language_rounded,
                  color: AppTheme.primary,
                  size: 21,
                ),
                const SizedBox(width: 8),
                Text(
                  'Global Brief',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF),
          ),
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
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            article.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF202020),
                              fontSize: 13.5,
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFEFEFEF),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _WorldHighlightStrip extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _WorldHighlightStrip({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

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
                    NewsImage(
                      url: article.imageUrl,
                      width: 310,
                      height: 240,
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
                          const _SolidLabel(text: 'World'),
                          const SizedBox(height: 8),
                          Text(
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

class _InternationalFactBox extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _InternationalFactBox({
    required this.articles,
    required this.onOpen,
  });

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
                child: Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

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

class _FinanceHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _FinanceHeader({
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
              Icons.trending_up_rounded,
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

class _MarketSummaryStrip extends StatelessWidget {
  const _MarketSummaryStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      _FinanceMetric(
        title: 'Market',
        value: 'Update',
        icon: Icons.show_chart_rounded,
      ),
      _FinanceMetric(
        title: 'Rupiah',
        value: 'Finance',
        icon: Icons.currency_exchange_rounded,
      ),
      _FinanceMetric(
        title: 'IHSG',
        value: 'Business',
        icon: Icons.bar_chart_rounded,
      ),
      _FinanceMetric(
        title: 'Economy',
        value: 'Insight',
        icon: Icons.account_balance_rounded,
      ),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _MarketSummaryCard(metric: items[index]);
        },
      ),
    );
  }
}

class _FinanceMetric {
  final String title;
  final String value;
  final IconData icon;

  const _FinanceMetric({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _MarketSummaryCard extends StatelessWidget {
  final _FinanceMetric metric;

  const _MarketSummaryCard({
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 270,
      padding: const EdgeInsets.all(16),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              metric.icon,
              color: AppTheme.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.title,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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

class _FinanceHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _FinanceHeroCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
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
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
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
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'MARKET UPDATE',
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
                right: 80,
                bottom: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SolidLabel(text: 'Finance'),
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
    );

    if (height != null) {
      return SizedBox(height: height, child: card);
    }

    return card;
  }
}

class _FinanceBriefPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _FinanceBriefPanel({
    required this.articles,
    required this.onOpen,
  });

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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Market Brief',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF),
          ),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: articles.length,
              separatorBuilder: (_, __) {
                return Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFEFEFEF),
                );
              },
              itemBuilder: (context, index) {
                final article = articles[index];

                return InkWell(
                  onTap: () => onOpen(article),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.attach_money_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            article.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF202020),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceHorizontalHeadlines extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _FinanceHorizontalHeadlines({
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
            child: _FinanceHeadlineCard(
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

class _FinanceHeadlineCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _FinanceHeadlineCard({
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
                child: _SolidLabel(text: 'Business'),
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

class _FinanceNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _FinanceNewsRow({
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
                    const _OutlineLabel(text: 'Finance'),
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

class _FinanceInsightPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _FinanceInsightPanel({
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
          const _SectionTitle(title: 'Financial Insight'),
          const SizedBox(height: 14),
          ...articles.take(4).map((article) {
            return InkWell(
              onTap: () => onOpen(article),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
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

class _FinanceStoryGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _FinanceStoryGrid({
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

class _CategoryGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _CategoryGrid({
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
        childAspectRatio: columns == 1 ? 1.65 : 1.03,
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

class _CategoryListTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _CategoryListTile({
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
                    CategoryBadge(category: article.category ?? 'Nasional'),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
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

class _InternationalListTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _InternationalListTile({
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NewsImage(
                  url: article.imageUrl,
                  width: 180,
                  height: 112,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _OutlineLabel(text: 'International'),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 5,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF202020),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SolidLabel extends StatelessWidget {
  final String text;

  const _SolidLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _OutlineLabel extends StatelessWidget {
  final String text;

  const _OutlineLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppTheme.primary),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _CategoryLoading extends StatelessWidget {
  const _CategoryLoading();

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

class _CategoryError extends StatelessWidget {
  final String title;
  final VoidCallback onRetry;

  const _CategoryError({
    required this.title,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
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
              Text('Gagal memuat berita $title'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'Coba lagi',
                  style: TextStyle(color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryEmpty extends StatelessWidget {
  final String title;

  const _CategoryEmpty({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.article_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Belum ada berita di kategori $title',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
