part of '../category_feed_screen.dart';

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
