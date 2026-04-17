import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/models.dart';

final _supabase = Supabase.instance.client;

// All articles
final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final data = await _supabase
      .from('articles')
      .select()
      .order('published_at', ascending: false)
      .limit(30);
  return (data as List).map((e) => Article.fromJson(e)).toList();
});

// Articles by category
final articlesByCategoryProvider =
    FutureProvider.family<List<Article>, String>((ref, category) async {
  final data = await _supabase
      .from('articles')
      .select()
      .eq('category', category)
      .order('published_at', ascending: false)
      .limit(20);
  return (data as List).map((e) => Article.fromJson(e)).toList();
});

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search results
final searchResultsProvider = FutureProvider<List<Article>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final data = await _supabase
      .from('articles')
      .select()
      .ilike('title', '%$query%')
      .order('published_at', ascending: false)
      .limit(20);
  return (data as List).map((e) => Article.fromJson(e)).toList();
});

// Bookmarks from Supabase
final bookmarksProvider = FutureProvider<List<Article>>((ref) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return [];
  final data = await _supabase
      .from('bookmarks')
      .select('article_id, articles(*)')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);
  return (data as List)
      .map((e) =>
          Article.fromJson(e['articles'] as Map<String, dynamic>)
            ..isBookmarked = true)
      .toList();
});

final bookmarkedIdsProvider = FutureProvider<Set<String>>((ref) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return {};
  final data = await _supabase
      .from('bookmarks')
      .select('article_id')
      .eq('user_id', user.id);
  return (data as List).map((e) => e['article_id'] as String).toSet();
});

// Toggle bookmark
Future<void> toggleBookmark(String articleId, bool isBookmarked) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return;
  if (isBookmarked) {
    await _supabase
        .from('bookmarks')
        .delete()
        .eq('user_id', user.id)
        .eq('article_id', articleId);
  } else {
    await _supabase.from('bookmarks').insert({
      'user_id': user.id,
      'article_id': articleId,
    });
  }
}

// Profile
final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;
  final data = await _supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();
  if (data == null) return null;
  return UserProfile.fromJson(data);
});

Future<void> updateProfile(Map<String, dynamic> data) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return;
  await _supabase.from('profiles').upsert({'id': user.id, ...data});
}

// Categories
const List<Map<String, dynamic>> kCategories = [
  {'name': 'Nasional', 'icon': '🇮🇩'},
  {'name': 'Internasional', 'icon': '🌍'},
  {'name': 'Sport', 'icon': '⚽'},
  {'name': 'Finance', 'icon': '💰'},
  {'name': 'Teknologi', 'icon': '💻'},
  {'name': 'Otomotif', 'icon': '🚗'},
  {'name': 'Travel', 'icon': '✈️'},
  {'name': 'Lifestyle', 'icon': '🎯'},
];