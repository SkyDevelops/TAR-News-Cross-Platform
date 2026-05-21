import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'feed_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../bookmark/presentation/bookmark_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../providers/news_provider.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _locationToIndex(String location) {
    if (location.startsWith('/home/search')) return 1;
    if (location.startsWith('/home/bookmark')) return 2;
    if (location.startsWith('/home/profile')) return 3;
    if (location.startsWith('/home/category')) return 0;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/home/search');
        break;
      case 2:
        context.go('/home/bookmark');
        break;
      case 3:
        context.go('/home/profile');
        break;
    }
  }

  void _openCategory(BuildContext context, String category) {
    context.go('/home/category/${Uri.encodeComponent(category)}');
  }

  @override
  Widget build(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final location = routerState.matchedLocation;
    final currentIndex = _locationToIndex(location);
    final screenWidth = MediaQuery.of(context).size.width;

    final useTopNav = screenWidth >= 800;

    final selectedCategorySlug = routerState.pathParameters['category'];
    final selectedCategory = selectedCategorySlug == null
        ? null
        : Uri.decodeComponent(selectedCategorySlug);

    final pages = [
      selectedCategory == null
          ? const FeedScreen()
          : CategoryFeedScreen(category: selectedCategory),
      const SearchScreen(),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];

    if (useTopNav) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: _WebTopNavBar(
            currentIndex: currentIndex,
            activeCategory: selectedCategory,
            onTap: (i) => _onTap(context, i),
            onCategoryTap: (category) => _openCategory(context, category),
          ),
        ),
        endDrawer: _WebSideMenu(
          onHomeTap: () => context.go('/home'),
          onBookmarkTap: () => context.go('/home/bookmark'),
          onCategoryTap: (category) => _openCategory(context, category),
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
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
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

class _NewsCategory {
  final String label;
  final String value;

  const _NewsCategory({
    required this.label,
    required this.value,
  });
}

class _WebTopNavBar extends ConsumerWidget {
  final int currentIndex;
  final String? activeCategory;
  final void Function(int) onTap;
  final void Function(String category) onCategoryTap;

  const _WebTopNavBar({
    required this.currentIndex,
    required this.activeCategory,
    required this.onTap,
    required this.onCategoryTap,
  });

  static const List<_NewsCategory> categories = [
    _NewsCategory(label: 'Nasional', value: 'Nasional'),
    _NewsCategory(label: 'Internasional', value: 'Internasional'),
    _NewsCategory(label: 'Sport', value: 'Sport'),
    _NewsCategory(label: 'Finance', value: 'Finance'),
    _NewsCategory(label: 'Technology', value: 'Teknologi'),
    _NewsCategory(label: 'Automotive', value: 'Otomotif'),
    _NewsCategory(label: 'Travel', value: 'Travel'),
    _NewsCategory(label: 'Lifestyle', value: 'Lifestyle'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = ref.watch(themeModeProvider.notifier);

    return Material(
      color: isDark ? const Color(0xFF151515) : Colors.white,
      elevation: 0,
      child: Column(
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () => onTap(1),
                            child: Container(
                              height: 42,
                              constraints: const BoxConstraints(
                                maxWidth: 420,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF202020)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF333333)
                                      : const Color(0xFFDADADA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Search',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black45,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.search_rounded,
                                    color: AppTheme.primary,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
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
                                currentIndex == 3
                                    ? Icons.account_circle
                                    : Icons.account_circle_outlined,
                                color: AppTheme.primary,
                                size: 30,
                              ),
                              onPressed: () => onTap(3),
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
                          isActive: currentIndex == 0 && activeCategory == null,
                          isDark: isDark,
                          onTap: () => onTap(0),
                        ),
                        ...categories.map((category) {
                          return _NavTextItem(
                            label: category.label,
                            isActive: activeCategory == category.value,
                            isDark: isDark,
                            onTap: () => onCategoryTap(category.value),
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
  final void Function(String category) onCategoryTap;

  const _WebSideMenu({
    required this.onHomeTap,
    required this.onBookmarkTap,
    required this.onCategoryTap,
  });

  static const List<_NewsCategory> menuItems = [
    _NewsCategory(label: 'Nasional', value: 'Nasional'),
    _NewsCategory(label: 'Internasional', value: 'Internasional'),
    _NewsCategory(label: 'Sport', value: 'Sport'),
    _NewsCategory(label: 'Finance', value: 'Finance'),
    _NewsCategory(label: 'Technology', value: 'Teknologi'),
    _NewsCategory(label: 'Automotive', value: 'Otomotif'),
    _NewsCategory(label: 'Travel', value: 'Travel'),
    _NewsCategory(label: 'Lifestyle', value: 'Lifestyle'),
  ];

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
                  ...menuItems.map((item) {
                    return _DrawerMenuItem(
                      title: item.label,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        onCategoryTap(item.value);
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

class CategoryFeedScreen extends ConsumerWidget {
  final String category;

  const CategoryFeedScreen({
    super.key,
    required this.category,
  });

  Future<void> _bookmark(WidgetRef ref, Article article) async {
    await toggleBookmark(article.id, article.isBookmarked);
    ref.invalidate(articlesByCategoryProvider(category));
    ref.invalidate(articlesProvider);
    ref.invalidate(bookmarksProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesByCategoryProvider(category));
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;

    final columns = isDesktop
        ? 3
        : isTablet
            ? 2
            : 1;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111111)
          : const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => ref.refresh(
          articlesByCategoryProvider(category).future,
        ),
        child: articlesAsync.when(
          loading: () {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ShimmerCard(),
                SizedBox(height: 12),
                ShimmerCard(),
                SizedBox(height: 12),
                ShimmerCard(),
              ],
            );
          },
          error: (e, _) {
            return ListView(
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
                        'Gagal memuat kategori $category',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          articlesByCategoryProvider(category),
                        ),
                        child: const Text(
                          'Coba lagi',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          data: (articles) {
            if (articles.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada berita di kategori $category',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 20 : 16,
                          24,
                          isDesktop ? 20 : 16,
                          14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 20 : 16,
                          0,
                          isDesktop ? 20 : 16,
                          34,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: articles.length,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: columns == 1 ? 1.65 : 1.0,
                          ),
                          itemBuilder: (_, index) {
                            final article = articles[index];

                            return ArticleCard(
                              article: article,
                              onTap: () =>
                                  context.go('/home/article/${article.id}'),
                              onBookmark: () => _bookmark(ref, article),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
