// lib/features/kanal/presentation/kanal_screen.dart
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
            onPressed: () => context.go('/home/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedCategory == null) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: Text('Kategori',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Pilih kategori berita yang Anda minati',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Wrap rata tengah ──
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: kCategories.map((cat) {
                            final catName = cat['name'] as String;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(
                                  () => _selectedCategory = catName),
                              child: Container(
                                width: 80,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1E1E)
                                      : const Color(0xFFF7F7F7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF2E2E2E)
                                        : Colors.grey.shade200,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(cat['icon'] as String,
                                        style: const TextStyle(
                                            fontSize: 22)),
                                    const SizedBox(height: 5),
                                    Text(
                                      catName,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Icon(Icons.touch_app_outlined,
                        size: 32, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text(
                      'Tap kategori untuk melihat berita',
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ] else ...[
            _CategoryChipBar(
              selected: _selectedCategory!,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
              onClear: () => setState(() => _selectedCategory = null),
              isDark: isDark,
            ),
            const Divider(height: 1),
            Expanded(
              child: articlesAsync!.when(
                loading: () => ListView.builder(
                  itemCount: 4,
                  itemBuilder: (_, __) => const ShimmerCard(),
                ),
                error: (e, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          '$e',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => ref.invalidate(
                              articlesByCategoryProvider(
                                  _selectedCategory!)),
                          child: const Text('Coba lagi',
                              style:
                                  TextStyle(color: AppTheme.primary)),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (articles) {
                  if (articles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.newspaper_outlined,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada berita $_selectedCategory',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(
                        articlesByCategoryProvider(_selectedCategory!)
                            .future),
                    color: AppTheme.primary,
                    child: ListView(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            _selectedCategory!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        ...articles.map((a) => ArticleCard(
                              article: a,
                              onTap: () =>
                                  context.go('/home/article/${a.id}'),
                              onBookmark: () async {
                                await toggleBookmark(
                                    a.id, a.isBookmarked);
                                ref.invalidate(
                                    articlesByCategoryProvider(
                                        _selectedCategory!));
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
        ],
      ),
    );
  }
}

// ── Widget chip navbar horizontal ────────────────────────────────────────────
class _CategoryChipBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;
  final bool isDark;

  const _CategoryChipBar({
    required this.selected,
    required this.onSelect,
    required this.onClear,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // Tombol kembali ke grid
          GestureDetector(
            onTap: onClear,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3A3A3A)
                      : Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: const Icon(Icons.grid_view_rounded, size: 16),
            ),
          ),
          // Chips semua kategori
          ...kCategories.map((cat) {
            final catName = cat['name'] as String;
            final isActive = catName == selected;
            return GestureDetector(
              onTap: () => onSelect(catName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primary
                      : (isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primary
                        : (isDark
                            ? const Color(0xFF3A3A3A)
                            : Colors.grey.shade300),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat['icon'] as String,
                        style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      catName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : null,
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