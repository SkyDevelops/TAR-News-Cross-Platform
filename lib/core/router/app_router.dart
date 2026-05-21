import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/main_screen.dart';
import '../../features/home/presentation/article_detail_screen.dart';
import '../../features/settings/presentation/setting_screen.dart';
import '../../features/about/presentation/about_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<bool>(false);

  final supabaseClient = Supabase.instance.client;
  supabaseClient.auth.onAuthStateChange.listen((_) {
    notifier.value = !notifier.value;
  });

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) {
      return null;
    },
    routes: [
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'search',
            builder: (_, __) => const MainScreen(),
          ),
          GoRoute(
            path: 'category/:category',
            builder: (_, __) => const MainScreen(),
          ),
          GoRoute(
            path: 'bookmark',
            builder: (_, __) => const MainScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (_, __) => const MainScreen(),
          ),
          GoRoute(
            path: 'article/:id',
            builder: (_, state) => ArticleDetailScreen(
              articleId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'settings',
            builder: (_, __) => const SettingScreen(),
          ),
          GoRoute(
            path: 'about',
            builder: (_, __) => const AboutScreen(),
          ),
        ],
      ),
    ],
  );
});
