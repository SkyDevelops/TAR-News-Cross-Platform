import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import 'feed_screen.dart';
import 'category_feed_screen.dart';
import '../../bookmark/presentation/bookmark_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/news_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _locationToIndex(String location) {
    if (location.startsWith('/home/bookmark')) return 1;
    if (location.startsWith('/home/profile')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/home/bookmark');
        break;
      case 2:
        context.go('/home/profile');
        break;
    }
  }

  void _openCategory(BuildContext context, String slug) {
    context.go('/home/category/$slug');
  }

  String? _getCategorySlugFromPath(Uri uri) {
    final segments = uri.pathSegments;

    if (segments.length >= 3 &&
        segments[0] == 'home' &&
        segments[1] == 'category') {
      return segments[2];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final uri = routerState.uri;
    final location = uri.path;
    final currentIndex = _locationToIndex(location);
    final screenWidth = MediaQuery.of(context).size.width;
    final useTopNav = screenWidth >= 800;

    final activeCategorySlug = _getCategorySlugFromPath(uri);

    final pages = [
      activeCategorySlug == null
          ? const FeedScreen()
          : CategoryFeedScreen(slug: activeCategorySlug),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];

    if (useTopNav) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: _WebTopNavBar(
            currentIndex: currentIndex,
            activeCategorySlug: activeCategorySlug,
            onTap: (i) => _onTap(context, i),
            onCategoryTap: (slug) => _openCategory(context, slug),
          ),
        ),
        endDrawer: _WebSideMenu(
          onHomeTap: () => context.go('/home'),
          onBookmarkTap: () => context.go('/home/bookmark'),
          onCategoryTap: (slug) => _openCategory(context, slug),
        ),
        body: pages[currentIndex],
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CategoryNavItem {
  final String label;
  final String slug;

  const _CategoryNavItem({
    required this.label,
    required this.slug,
  });
}

const List<_CategoryNavItem> _categoryItems = [
  _CategoryNavItem(label: 'Nasional', slug: 'nasional'),
  _CategoryNavItem(label: 'Internasional', slug: 'internasional'),
  _CategoryNavItem(label: 'Sport', slug: 'sport'),
  _CategoryNavItem(label: 'Finance', slug: 'finance'),
  _CategoryNavItem(label: 'Teknologi', slug: 'teknologi'),
  _CategoryNavItem(label: 'Otomotif', slug: 'otomotif'),
  _CategoryNavItem(label: 'Travel', slug: 'travel'),
  _CategoryNavItem(label: 'Lifestyle', slug: 'lifestyle'),
];

class _WebTopNavBar extends ConsumerWidget {
  final int currentIndex;
  final String? activeCategorySlug;
  final void Function(int) onTap;
  final void Function(String slug) onCategoryTap;

  const _WebTopNavBar({
    required this.currentIndex,
    required this.activeCategorySlug,
    required this.onTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _WebTopNavBarContent(
      currentIndex: currentIndex,
      activeCategorySlug: activeCategorySlug,
      onTap: onTap,
      onCategoryTap: onCategoryTap,
    );
  }
}

class _WebTopNavBarContent extends ConsumerStatefulWidget {
  final int currentIndex;
  final String? activeCategorySlug;
  final void Function(int) onTap;
  final void Function(String slug) onCategoryTap;

  const _WebTopNavBarContent({
    required this.currentIndex,
    required this.activeCategorySlug,
    required this.onTap,
    required this.onCategoryTap,
  });

  @override
  ConsumerState<_WebTopNavBarContent> createState() =>
      _WebTopNavBarContentState();
}

class _WebTopNavBarContentState extends ConsumerState<_WebTopNavBarContent> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() => _isSearchOpen = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _setSearchQuery(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  void _selectKeyword(String keyword) {
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    _setSearchQuery(keyword);
    _searchFocusNode.requestFocus();
    setState(() => _isSearchOpen = true);
  }

  void _clearSearch() {
    _searchController.clear();
    _setSearchQuery('');
    _searchFocusNode.requestFocus();
    setState(() => _isSearchOpen = true);
  }

  Future<void> _toggleBookmark(Article article) async {
    await toggleBookmark(article.id, article.isBookmarked);
    ref.invalidate(searchResultsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = ref.watch(themeModeProvider.notifier);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final showSearchPanel = _isSearchOpen || searchQuery.trim().isNotEmpty;

    return Material(
      color: isDark ? const Color(0xFF151515) : Colors.white,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              SizedBox(
                height: 68,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 230,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TarNewsLogo(),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: _WebHeaderSearchField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                query: searchQuery,
                                isDark: isDark,
                                onChanged: _setSearchQuery,
                                onClear: _clearSearch,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 230,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isDark
                                        ? Icons.light_mode_outlined
                                        : Icons.dark_mode_outlined,
                                    color: AppTheme.primary,
                                    size: 25,
                                  ),
                                  onPressed: () => themeNotifier.toggle(),
                                  tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(
                                    widget.currentIndex == 2
                                        ? Icons.account_circle
                                        : Icons.account_circle_outlined,
                                    color: AppTheme.primary,
                                    size: 30,
                                  ),
                                  onPressed: () => widget.onTap(2),
                                  tooltip: 'Profile',
                                ),
                                const SizedBox(width: 4),
                                Builder(
                                  builder: (context) {
                                    return IconButton(
                                      icon: const Icon(
                                        Icons.menu_rounded,
                                        color: AppTheme.primary,
                                        size: 31,
                                      ),
                                      onPressed: () {
                                        Scaffold.of(context).openEndDrawer();
                                      },
                                      tooltip: 'Menu',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151515) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? const Color(0xFF252525)
                          : const Color(0xFFEFEFEF),
                    ),
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF252525)
                          : const Color(0xFFEFEFEF),
                    ),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _NavTextItem(
                              label: 'Home',
                              isActive: widget.currentIndex == 0 &&
                                  widget.activeCategorySlug == null,
                              isDark: isDark,
                              onTap: () => widget.onTap(0),
                            ),
                            ..._categoryItems.map((item) {
                              return _NavTextItem(
                                label: item.label,
                                isActive:
                                    widget.activeCategorySlug == item.slug,
                                isDark: isDark,
                                onTap: () => widget.onCategoryTap(item.slug),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showSearchPanel)
            Positioned(
              top: 58,
              left: 0,
              right: 0,
              child: Center(
                child: _WebSearchPanel(
                  query: searchQuery,
                  results: searchResults,
                  isDark: isDark,
                  onKeywordTap: _selectKeyword,
                  onArticleTap: (article) {
                    setState(() => _isSearchOpen = false);
                    _searchFocusNode.unfocus();
                    context.go('/home/article/${article.id}');
                  },
                  onBookmark: _toggleBookmark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const List<String> _searchKeywords = [
  'Nasional',
  'Internasional',
  'Sport',
  'Finance',
  'Teknologi',
  'Otomotif',
  'Travel',
  'Lifestyle',
];

class _WebHeaderSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _WebHeaderSearchField({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.isDark,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      width: 420,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF202020),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: query.trim().isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: isDark ? Colors.white54 : Colors.grey,
                  iconSize: 20,
                  onPressed: onClear,
                )
              : const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
          filled: true,
          fillColor: isDark ? const Color(0xFF202020) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFDADADA),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.3),
          ),
        ),
      ),
    );
  }
}

class _WebSearchPanel extends StatelessWidget {
  final String query;
  final AsyncValue<List<Article>> results;
  final bool isDark;
  final ValueChanged<String> onKeywordTap;
  final void Function(Article article) onArticleTap;
  final Future<void> Function(Article article) onBookmark;

  const _WebSearchPanel({
    required this.query,
    required this.results,
    required this.isDark,
    required this.onKeywordTap,
    required this.onArticleTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;

    return Container(
      width: 420,
      constraints: const BoxConstraints(maxHeight: 360),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202020) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: hasQuery ? _buildResults() : _buildKeywords(),
    );
  }

  Widget _buildKeywords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Kata Kunci',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF202020),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _searchKeywords.map((keyword) {
            return _KeywordChip(
              label: keyword,
              isDark: isDark,
              onTap: () => onKeywordTap(keyword),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return results.when(
      loading: () => const SizedBox(
        height: 96,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      ),
      error: (_, __) => SizedBox(
        height: 96,
        child: Center(
          child: Text(
            'Gagal mencari berita',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
      data: (articles) {
        if (articles.isEmpty) {
          return SizedBox(
            height: 96,
            child: Center(
              child: Text(
                'Tidak ada hasil untuk "$query"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          );
        }

        final visibleArticles = articles.take(4).toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hasil Pencarian',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF202020),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: visibleArticles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final article = visibleArticles[index];
                  return _HeaderSearchResultTile(
                    article: article,
                    isDark: isDark,
                    onTap: () => onArticleTap(article),
                    onBookmark: () => onBookmark(article),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _KeywordChip({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white24 : const Color(0xFF222222),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF202020),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HeaderSearchResultTile extends StatelessWidget {
  final Article article;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _HeaderSearchResultTile({
    required this.article,
    required this.isDark,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            NewsImage(
              url: article.imageUrl,
              width: 72,
              height: 48,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF202020),
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.timeAgo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                article.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                color: article.isBookmarked ? AppTheme.primary : Colors.grey,
                size: 20,
              ),
              onPressed: onBookmark,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTextItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavTextItem({
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppTheme.primary
                      : isDark
                          ? Colors.white
                          : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 4,
                width: isActive ? 58 : 0,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebSideMenu extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onBookmarkTap;
  final void Function(String slug) onCategoryTap;

  const _WebSideMenu({
    required this.onHomeTap,
    required this.onBookmarkTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: 320,
      backgroundColor: isDark ? const Color(0xFF151515) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFEFEFEF),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const TarNewsLogo(),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _DrawerMenuItem(
                    title: 'Home',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      onHomeTap();
                    },
                  ),
                  ..._categoryItems.map((item) {
                    return _DrawerMenuItem(
                      title: item.label,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        onCategoryTap(item.slug);
                      },
                    );
                  }),
                  _DrawerMenuItem(
                    title: 'Bookmark',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      onBookmarkTap();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.title,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF202020),
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.primary,
      ),
      onTap: onTap,
    );
  }
}
