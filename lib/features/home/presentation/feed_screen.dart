import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/news_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/theme/app_theme.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const TarNewsLogo(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/home/search'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/home/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(articlesProvider.future),
        color: AppTheme.primary,
        child: articlesAsync.when(
          loading: () => ListView.builder(
            itemCount: 5,
            itemBuilder: (_, __) => const ShimmerCard(),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_outlined,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Gagal memuat berita',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.refresh(articlesProvider),
                  child: const Text('Coba lagi',
                      style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            ),
          ),
          data: (articles) {
            if (articles.isEmpty) {
              return const Center(child: Text('Belum ada berita'));
            }
            final hero = articles.first;
            final rest = articles.skip(1).toList();
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BREAKING NEWS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── FIX: tambah onBookmark di HeroArticleCard ──
                HeroArticleCard(
                  article: hero,
                  onTap: () => context.go('/home/article/${hero.id}'),
                  onBookmark: () async {
                    await toggleBookmark(hero.id, hero.isBookmarked);
                    ref.invalidate(articlesProvider);
                    ref.invalidate(bookmarksProvider);
                  },
                ),

                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text('Berita Terkini',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                ...rest.map((article) => ArticleCard(
                      article: article,
                      onTap: () =>
                          context.go('/home/article/${article.id}'),
                      onBookmark: () async {
                        await toggleBookmark(
                            article.id, article.isBookmarked);
                        ref.invalidate(articlesProvider);
                        ref.invalidate(bookmarksProvider);
                      },
                    )),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}