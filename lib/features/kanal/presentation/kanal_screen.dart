import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/providers/news_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/theme/app_theme.dart';

class KanalScreen extends ConsumerStatefulWidget {
  const KanalScreen({super.key});

  @override
  ConsumerState<KanalScreen> createState() => _KanalScreenState();
}

class _KanalScreenState extends ConsumerState<KanalScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final articlesAsync = _selectedCategory != null
        ? ref.watch(articlesByCategoryProvider(_selectedCategory!))
        : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            child: Text('Kanal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text('Pilih kategori berita yang Anda minati',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: kCategories.length,
              itemBuilder: (context, index) {
                final cat = kCategories[index];
                final isSelected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory =
                        isSelected ? null : cat['name'] as String;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : (isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat['icon'] as String,
                            style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 4),
                        Text(
                          cat['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? Colors.white : null,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedCategory != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(_selectedCategory!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: articlesAsync!.when(
                loading: () => ListView.builder(
                  itemCount: 3,
                  itemBuilder: (_, __) => const ShimmerCard(),
                ),
                error: (_, __) =>
                    const Center(child: Text('Gagal memuat')),
                data: (articles) {
                  if (articles.isEmpty) {
                    return Center(
                      child: Text(
                          'Belum ada berita $_selectedCategory',
                          style:
                              const TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView(
                    children: [
                      ...articles.map((a) => ArticleCard(
                            article: a,
                            onTap: () =>
                                context.go('/home/article/${a.id}'),
                            onBookmark: () async {
                              await toggleBookmark(
                                  a.id, a.isBookmarked);
                              // FIXED: use ref.invalidate() instead of ref.refresh()
                              // to avoid unused_result warning
                              ref.invalidate(articlesByCategoryProvider(
                                  _selectedCategory!));
                            },
                          )),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Pilih kategori di atas',
                        style:
                            TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}