import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/models.dart';

final _supabase = Supabase.instance.client;

// ── Helper: tandai artikel mana saja yang sudah di-bookmark ──────────────────
Future<List<Article>> _withBookmarkStatus(List<Article> articles) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return articles;

  final data = await _supabase
      .from('bookmarks')
      .select('article_id')
      .eq('user_id', user.id);

  final bookmarkedIds =
      (data as List).map((e) => e['article_id'] as String).toSet();

  return articles.map((a) {
    a.isBookmarked = bookmarkedIds.contains(a.id);
    return a;
  }).toList();
}

// ── All articles ──────────────────────────────────────────────────────────────
final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final data = await _supabase
      .from('articles')
      .select()
      .order('published_at', ascending: false)
      .limit(30);
  final articles = (data as List).map((e) => Article.fromJson(e)).toList();
  return _withBookmarkStatus(articles);
});

// ── Articles by category ──────────────────────────────────────────────────────
final articlesByCategoryProvider =
    FutureProvider.family<List<Article>, String>((ref, category) async {
  final data = await _supabase
      .from('articles')
      .select()
      .eq('category', category)
      .order('published_at', ascending: false)
      .limit(20);
  final articles = (data as List).map((e) => Article.fromJson(e)).toList();
  return _withBookmarkStatus(articles);
});

// ── Search ────────────────────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Article>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final data = await _supabase
      .from('articles')
      .select()
      .ilike('title', '%$query%')
      .order('published_at', ascending: false)
      .limit(20);
  final articles = (data as List).map((e) => Article.fromJson(e)).toList();
  return _withBookmarkStatus(articles);
});

// ── Bookmarks ─────────────────────────────────────────────────────────────────
final bookmarksProvider = FutureProvider<List<Article>>((ref) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return [];

  // Step 1: ambil article_id dari bookmarks
  final bmData = await _supabase
      .from('bookmarks')
      .select('article_id')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

  final ids = (bmData as List)
      .map((e) => e['article_id'] as String)
      .toList();

  if (ids.isEmpty) return [];

  // Step 2: ambil artikel berdasarkan id
  final articleData = await _supabase
      .from('articles')
      .select()
      .inFilter('id', ids);

  // Step 3: urutkan sesuai urutan bookmark (terbaru dulu)
  final articlesMap = {
    for (final e in articleData as List)
      (e['id'] as String): Article.fromJson(e as Map<String, dynamic>)
        ..isBookmarked = true
  };

  return ids
      .where((id) => articlesMap.containsKey(id))
      .map((id) => articlesMap[id]!)
      .toList();
});

// ── Toggle bookmark ───────────────────────────────────────────────────────────
Future<void> toggleBookmark(String articleId, bool isCurrentlyBookmarked) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return;
  if (isCurrentlyBookmarked) {
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

// ── Profile ───────────────────────────────────────────────────────────────────
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

// ── Categories ────────────────────────────────────────────────────────────────
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