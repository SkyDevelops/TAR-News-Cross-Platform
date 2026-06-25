import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/news_provider.dart';

part 'feed_parts/feed_layout_widgets.dart';
part 'feed_parts/feed_news_widgets.dart';
part 'feed_parts/feed_misc_widgets.dart';


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
    final saved = await toggleBookmark(article.id, article.isBookmarked);
    if (!saved) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login dulu untuk menyimpan bookmark')),
      );
      context.go('/login?redirect=${Uri.encodeComponent('/home')}');
      return;
    }
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
