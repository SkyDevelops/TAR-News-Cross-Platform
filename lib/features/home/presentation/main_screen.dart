import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'feed_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../kanal/presentation/kanal_screen.dart';
import '../../bookmark/presentation/bookmark_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  int _locationToIndex(String location) {
    if (location.startsWith('/home/search')) return 1;
    if (location.startsWith('/home/kanal')) return 2;
    if (location.startsWith('/home/bookmark')) return 3;
    if (location.startsWith('/home/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/home/search'); break;
      case 2: context.go('/home/kanal'); break;
      case 3: context.go('/home/bookmark'); break;
      case 4: context.go('/home/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          FeedScreen(),
          SearchScreen(),
          KanalScreen(),
          BookmarkScreen(),
          ProfileScreen(),
        ],
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
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Kanal',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}