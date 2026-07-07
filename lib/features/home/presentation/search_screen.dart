import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/news_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleBookmark(Article article) async {
    final saved = await toggleBookmark(article.id, article.isBookmarked);
    if (!mounted) return;

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login dulu untuk menyimpan bookmark')),
      );
      context.go('/login?redirect=${Uri.encodeComponent('/home/search')}');
      return;
    }

    ref.invalidate(searchResultsProvider);
    ref.invalidate(bookmarksProvider);
    ref.invalidate(articlesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          decoration: InputDecoration(
            hintText: 'Cari berita',
            border: InputBorder.none,
            suffixIcon: query.trim().isEmpty
                ? const Icon(Icons.search_rounded)
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  ),
          ),
        ),
      ),
      body: results.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Gagal mencari berita'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(searchResultsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (articles) {
          if (query.trim().isEmpty) {
            return const Center(child: Text('Ketik kata kunci berita'));
          }

          if (articles.isEmpty) {
            return Center(child: Text('Tidak ada berita tentang "$query"'));
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => ref.refresh(searchResultsProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${articles.length} berita tentang "$query"',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
                ...articles.map(
                  (article) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: 400,
                      child: ArticleCard(
                        article: article,
                        onTap: () => context.go('/home/article/${article.id}'),
                        onBookmark: () => _toggleBookmark(article),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
