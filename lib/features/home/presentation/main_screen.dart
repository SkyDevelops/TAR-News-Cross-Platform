import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'feed_screen.dart';
import 'category_feed_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../bookmark/presentation/bookmark_screen.dart';
import '../../profile/presentation/profile_screen.dart';
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
                              constraints: const BoxConstraints(maxWidth: 420),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
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
                          isActive:
                              currentIndex == 0 && activeCategorySlug == null,
                          isDark: isDark,
                          onTap: () => onTap(0),
                        ),
                        ..._categoryItems.map((item) {
                          return _NavTextItem(
                            label: item.label,
                            isActive: activeCategorySlug == item.slug,
                            isDark: isDark,
                            onTap: () => onCategoryTap(item.slug),
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
