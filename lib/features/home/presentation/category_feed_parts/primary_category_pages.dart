part of '../category_feed_screen.dart';

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
