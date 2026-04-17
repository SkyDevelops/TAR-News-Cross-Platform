import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/providers/news_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/theme/app_theme.dart';

class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const TarNewsLogo(),
        actions: [
          IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.go('/home/profile')),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Bookmark',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: bookmarksAsync.when(
              loading: () => ListView.builder(
                itemCount: 4,
                itemBuilder: (_, __) => const ShimmerCard(),
              ),
              error: (_, __) =>
                  const Center(child: Text('Gagal memuat bookmark')),
              data: (articles) {
                if (articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_outline,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Belum ada berita yang di-bookmark',
                            style:
                                TextStyle(color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Text(
                            'Tap ikon bookmark pada berita\nuntuk menyimpannya',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(bookmarksProvider.future),
                  color: AppTheme.primary,
                  child: ListView(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                            '${articles.length} berita tersimpan',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13)),
                      ),
                      ...articles.map((a) => ArticleCard(
                            article: a,
                            onTap: () => context
                                .go('/home/article/${a.id}'),
                            onBookmark: () async {
                              await toggleBookmark(a.id, true);
                              // FIXED: use ref.invalidate() instead of ref.refresh()
                              // to avoid unused_result warning
                              ref.invalidate(bookmarksProvider);
                            },
                          )),
                      const SizedBox(height: 16),
                    ],
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