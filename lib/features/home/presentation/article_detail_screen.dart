import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/news_provider.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/theme/app_theme.dart';

final articleDetailProvider =
    FutureProvider.family<Article?, String>((ref, id) async {
  final data = await Supabase.instance.client
      .from('articles')
      .select()
      .eq('id', id)
      .maybeSingle();
  if (data == null) return null;
  final article = Article.fromJson(data);
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    final bm = await Supabase.instance.client
        .from('bookmarks')
        .select()
        .eq('user_id', user.id)
        .eq('article_id', id)
        .maybeSingle();
    article.isBookmarked = bm != null;
  }
  return article;
});

class ArticleDetailScreen extends ConsumerWidget {
  final String articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(articleId));

    return Scaffold(
      body: articleAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Artikel tidak ditemukan'),
              TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Kembali')),
            ],
          ),
        ),
        data: (article) {
          if (article == null) {
            return const Center(child: Text('Artikel tidak ditemukan'));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.arrow_back,
                        color: Colors.white, size: 18),
                  ),
                  onPressed: () => context.go('/home'),
                ),
                actions: [
                  IconButton(
                    icon: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(
                        article.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: article.isBookmarked
                            ? AppTheme.primary
                            : Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () async {
                      await toggleBookmark(
                          article.id, article.isBookmarked);
                      // FIXED: use ref.invalidate() instead of ref.refresh()
                      // to avoid unused_result warning
                      ref.invalidate(articleDetailProvider(articleId));
                      ref.invalidate(bookmarksProvider);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      NewsImage(url: article.imageUrl),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              // FIXED: withOpacity(0.5) → .withValues(alpha: 0.5)
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.category != null) ...[
                        CategoryBadge(category: article.category!),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        article.title,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.35),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(article.timeAgo,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                          if (article.sourceName != null) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.source_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(article.sourceName!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ],
                      ),
                      const Divider(height: 28),
                      if (article.summary != null &&
                          article.summary!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            // FIXED: withOpacity(0.06) → .withValues(alpha: 0.06)
                            color: AppTheme.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(
                                  color: AppTheme.primary, width: 3),
                            ),
                          ),
                          child: Text(
                            article.summary!,
                            style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (article.content != null &&
                          article.content!.isNotEmpty)
                        Text(article.content!,
                            style: const TextStyle(
                                fontSize: 15, height: 1.8))
                      else
                        Text(
                            article.summary ??
                                'Konten artikel tidak tersedia.',
                            style: const TextStyle(
                                fontSize: 15, height: 1.8)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}