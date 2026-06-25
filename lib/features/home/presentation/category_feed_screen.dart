import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/news_provider.dart';

part 'category_feed_parts/primary_category_pages.dart';
part 'category_feed_parts/special_category_pages.dart';
part 'category_feed_parts/shared_category_widgets.dart';
part 'category_feed_parts/technology_category_widgets.dart';
part 'category_feed_parts/category_icon_story_widgets.dart';
part 'category_feed_parts/category_visual_story_widgets.dart';
part 'category_feed_parts/national_international_category_widgets.dart';
part 'category_feed_parts/sport_category_widgets.dart';
part 'category_feed_parts/finance_category_widgets.dart';

typedef _CategoryPageFactory = Widget Function({
  required _CategoryInfo info,
  required List<Article> articles,
  required bool isDesktop,
  required bool isTablet,
  required void Function(Article article) onOpen,
  required Future<void> Function(Article article) onBookmark,
});

final Map<String, _CategoryPageFactory> _pageFactories = {
  'nasional': _NasionalCategoryPage.new,
  'internasional': _InternasionalCategoryPage.new,
  'sport': _SportCategoryPage.new,
  'finance': _FinanceCategoryPage.new,
  'teknologi': _TechnologyCategoryPage.new,
  'otomotif': _AutomotiveCategoryPage.new,
  'travel': _TravelCategoryPage.new,
  'lifestyle': _LifestyleCategoryPage.new,
};

class CategoryFeedScreen extends ConsumerWidget {
  final String slug;

  const CategoryFeedScreen({
    super.key,
    required this.slug,
  });

  _CategoryInfo get _info => _CategoryInfo.fromSlug(slug);

  Future<void> _bookmark(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) async {
    final saved = await toggleBookmark(article.id, article.isBookmarked);
    if (!saved) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login dulu untuk menyimpan bookmark')),
      );
      context.go(
        '/login?redirect=${Uri.encodeComponent('/home/category/$slug')}',
      );
      return;
    }
    ref.invalidate(articlesByCategoryProvider(_info.queryCategory));
    ref.invalidate(articlesProvider);
    ref.invalidate(bookmarksProvider);
  }

  void _openArticle(BuildContext context, Article article) {
    context.go('/home/article/${article.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = _info;
    final articlesAsync =
        ref.watch(articlesByCategoryProvider(info.queryCategory));

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111111)
          : const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => ref.refresh(
          articlesByCategoryProvider(info.queryCategory).future,
        ),
        child: articlesAsync.when(
          loading: () => const _CategoryLoading(),
          error: (e, _) => _CategoryError(
            title: info.title,
            onRetry: () => ref.invalidate(
              articlesByCategoryProvider(info.queryCategory),
            ),
          ),
          data: (articles) {
            if (articles.isEmpty) {
              return _CategoryEmpty(title: info.title);
            }

            final pageFactory =
                _pageFactories[info.slug] ?? _GenericCategoryPage.new;

            return pageFactory(
              info: info,
              articles: articles,
              isDesktop: isDesktop,
              isTablet: isTablet,
              onOpen: (article) => _openArticle(context, article),
              onBookmark: (article) => _bookmark(context, ref, article),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryInfo {
  final String slug;
  final String title;
  final String queryCategory;
  final String subtitle;

  const _CategoryInfo({
    required this.slug,
    required this.title,
    required this.queryCategory,
    required this.subtitle,
  });

  factory _CategoryInfo.fromSlug(String rawSlug) {
    final slug = rawSlug.toLowerCase();

    switch (slug) {
      case 'nasional':
        return const _CategoryInfo(
          slug: 'nasional',
          title: 'Nasional',
          queryCategory: 'Nasional',
          subtitle:
              'Berita nasional terbaru, aktual, dan terpercaya dari seluruh Indonesia.',
        );
      case 'internasional':
        return const _CategoryInfo(
          slug: 'internasional',
          title: 'Internasional',
          queryCategory: 'Internasional',
          subtitle:
              'Kabar dunia terbaru, isu global, diplomasi, dan peristiwa internasional.',
        );
      case 'sport':
        return const _CategoryInfo(
          slug: 'sport',
          title: 'Sport',
          queryCategory: 'Sport',
          subtitle: 'Update olahraga, pertandingan, dan atlet terkini.',
        );
      case 'finance':
        return const _CategoryInfo(
          slug: 'finance',
          title: 'Finance',
          queryCategory: 'Finance',
          subtitle: 'Berita ekonomi, bisnis, pasar, dan keuangan.',
        );
      case 'teknologi':
        return const _CategoryInfo(
          slug: 'teknologi',
          title: 'Teknologi',
          queryCategory: 'Teknologi',
          subtitle: 'Informasi teknologi, digital, dan inovasi terbaru.',
        );
      case 'otomotif':
        return const _CategoryInfo(
          slug: 'otomotif',
          title: 'Otomotif',
          queryCategory: 'Otomotif',
          subtitle: 'Berita otomotif, kendaraan, dan industri mobilitas.',
        );
      case 'travel':
        return const _CategoryInfo(
          slug: 'travel',
          title: 'Travel',
          queryCategory: 'Travel',
          subtitle: 'Destinasi, perjalanan, dan inspirasi wisata.',
        );
      case 'lifestyle':
        return const _CategoryInfo(
          slug: 'lifestyle',
          title: 'Lifestyle',
          queryCategory: 'Lifestyle',
          subtitle: 'Tren gaya hidup, hiburan, dan inspirasi harian.',
        );
      default:
        return _CategoryInfo(
          slug: slug,
          title: 'Nasional',
          queryCategory: 'Nasional',
          subtitle:
              'Berita nasional terbaru, aktual, dan terpercaya dari seluruh Indonesia.',
        );
    }
  }
}
