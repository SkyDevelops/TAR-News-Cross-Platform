import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/providers/news_provider.dart';
import '../../../shared/widgets/widgets.dart';
// FIXED: removed unused import '../../../core/theme/app_theme.dart'

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Cari berita...',
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          ref
                              .read(searchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (val) =>
                  ref.read(searchQueryProvider.notifier).state = val,
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Ketik untuk mencari berita',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 15)),
                      ],
                    ),
                  )
                : resultsAsync.when(
                    loading: () => ListView.builder(
                      itemCount: 4,
                      itemBuilder: (_, __) => const ShimmerCard(),
                    ),
                    error: (_, __) => const Center(
                        child: Text('Gagal mencari berita')),
                    data: (articles) {
                      if (articles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text(
                                  'Tidak ada hasil untuk "$query"',
                                  style: TextStyle(
                                      color: Colors.grey[500])),
                            ],
                          ),
                        );
                      }
                      return ListView(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Text(
                              '${articles.length} hasil untuk "$query"',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13),
                            ),
                          ),
                          ...articles.map((a) => ArticleCard(
                                article: a,
                                onTap: () => context
                                    .go('/home/article/${a.id}'),
                                onBookmark: () async {
                                  await toggleBookmark(
                                      a.id, a.isBookmarked);
                                  // FIXED: use ref.invalidate() instead of ref.refresh()
                                  // to avoid unused_result warning
                                  ref.invalidate(searchResultsProvider);
                                },
                              )),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}