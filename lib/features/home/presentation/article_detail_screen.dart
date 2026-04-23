import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart'
    if (dart.library.html) 'webview_stub.dart';
import '../providers/news_provider.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/theme/app_theme.dart';

final articleDetailProvider =
    FutureProvider.family<Article?, String>((ref, id) async {
  debugPrint('>>> articleDetailProvider id: "$id"');

  final data = await Supabase.instance.client
      .from('articles')
      .select()
      .eq('id', id)
      .maybeSingle();

  debugPrint('>>> query result: $data');
  if (data == null) return null;

  final article = Article.fromJson(data);
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    final bm = await Supabase.instance.client
        .from('bookmarks')
        .select()
        .eq('user_id', user.id)
        .eq('article_id', id)
        .maybeSingle();
    article.isBookmarked = bm != null;
  }
  return article;
});

class ArticleDetailScreen extends ConsumerWidget {
  final String articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(articleId));

    return Scaffold(
      body: articleAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, st) {
          debugPrint('>>> error: $e\n$st');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Terjadi kesalahan'),
                const SizedBox(height: 4),
                Text('$e',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center),
                TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Kembali')),
              ],
            ),
          );
        },
        data: (article) {
          if (article == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Artikel tidak ditemukan\nID: $articleId',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Kembali')),
                ],
              ),
            );
          }

          final hasUrl =
              article.sourceUrl != null && article.sourceUrl!.isNotEmpty;

          // Flutter Web → tidak support WebView
          if (kIsWeb) {
            return _ArticleWebFallback(
                article: article, ref: ref, articleId: articleId);
          }

          // Mobile/Desktop dengan URL → buka WebView
          if (hasUrl) {
            return _ArticleWebView(
                article: article, ref: ref, articleId: articleId);
          }

          // Tidak ada URL → tampilkan teks
          return _ArticleTextView(
              article: article, ref: ref, articleId: articleId);
        },
      ),
    );
  }
}

// ── Flutter Web: fetch content via Supabase Edge Function ────────────────────
class _ArticleWebFallback extends StatefulWidget {
  final Article article;
  final WidgetRef ref;
  final String articleId;
  const _ArticleWebFallback(
      {required this.article, required this.ref, required this.articleId});

  @override
  State<_ArticleWebFallback> createState() => _ArticleWebFallbackState();
}

class _ArticleWebFallbackState extends State<_ArticleWebFallback> {
  late bool _isBookmarked;
  String? _content;
  bool _isLoadingContent = false;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.article.isBookmarked;
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    final url = widget.article.sourceUrl;
    if (url == null || url.isEmpty) return;

    setState(() {
      _isLoadingContent = true;
      _contentError = null;
    });

    try {
      final res = await Supabase.instance.client.functions.invoke(
        'fetch-content',
        body: {'url': url},
      );
      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['content'] != null) {
        final content = data['content'] as String;
        if (content.isNotEmpty) {
          setState(() => _content = content);
        } else {
          setState(() => _contentError = 'Konten kosong dari sumber.');
        }
      } else if (data != null && data['error'] != null) {
        setState(() => _contentError = 'Gagal memuat: ${data['error']}');
      }
    } catch (e) {
      debugPrint('fetch-content error: $e');
      setState(() => _contentError = 'Konten tidak dapat dimuat.');
    } finally {
      if (mounted) setState(() => _isLoadingContent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(article.sourceName ?? 'Artikel',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? AppTheme.primary : null,
            ),
            onPressed: () async {
              await toggleBookmark(article.id, _isBookmarked);
              setState(() => _isBookmarked = !_isBookmarked);
              article.isBookmarked = _isBookmarked;
              widget.ref
                  .invalidate(articleDetailProvider(widget.articleId));
              widget.ref.invalidate(bookmarksProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar ──
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NewsImage(url: article.imageUrl, height: 220),
              ),
            const SizedBox(height: 16),

            // ── Kategori ──
            if (article.category != null) ...[
              CategoryBadge(category: article.category!),
              const SizedBox(height: 10),
            ],

            // ── Judul ──
            Text(article.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.35)),
            const SizedBox(height: 10),

            // ── Meta info ──
            Row(children: [
              const Icon(Icons.access_time, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(article.timeAgo,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
              if (article.sourceName != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.source_outlined,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(article.sourceName!,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
              ],
            ]),
            const Divider(height: 28),

            // ── Summary (ringkasan) ──
            if (article.summary != null &&
                article.summary!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                      left: BorderSide(
                          color: AppTheme.primary, width: 3)),
                ),
                child: Text(article.summary!,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 20),
            ],

            // ── Content: loading / error / teks ──
            if (_isLoadingContent)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.primary),
                      SizedBox(height: 12),
                      Text('Memuat isi berita...',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else if (_content != null && _content!.isNotEmpty)
              Text(_content!,
                  style:
                      const TextStyle(fontSize: 15, height: 1.8))
            else ...[
              Text(
                _contentError ??
                    'Isi berita tidak tersedia. Buka sumber asli untuk membaca lengkap.',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14, height: 1.6),
              ),
            ],

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),

            // ── Sumber berita ──
            const Text('Sumber Berita',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Text(article.sourceName ?? '',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13)),

            // ── Tombol buka sumber asli ──
            if (article.sourceUrl != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Buka Sumber Asli'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side:
                        const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    final uri = Uri.parse(article.sourceUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Mobile WebView ────────────────────────────────────────────────────────────
class _ArticleWebView extends StatefulWidget {
  final Article article;
  final WidgetRef ref;
  final String articleId;
  const _ArticleWebView(
      {required this.article, required this.ref, required this.articleId});

  @override
  State<_ArticleWebView> createState() => _ArticleWebViewState();
}

class _ArticleWebViewState extends State<_ArticleWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.article.isBookmarked;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onProgress: (p) => setState(() => _loadingProgress = p),
      ))
      ..loadRequest(Uri.parse(widget.article.sourceUrl!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(widget.article.sourceName ?? 'Artikel',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? AppTheme.primary : null,
            ),
            onPressed: () async {
              await toggleBookmark(
                  widget.article.id, _isBookmarked);
              setState(() => _isBookmarked = !_isBookmarked);
              widget.article.isBookmarked = _isBookmarked;
              widget.ref
                  .invalidate(articleDetailProvider(widget.articleId));
              widget.ref.invalidate(bookmarksProvider);
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  color: AppTheme.primary,
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

// ── Fallback Text View (no URL) ───────────────────────────────────────────────
class _ArticleTextView extends StatefulWidget {
  final Article article;
  final WidgetRef ref;
  final String articleId;
  const _ArticleTextView(
      {required this.article, required this.ref, required this.articleId});

  @override
  State<_ArticleTextView> createState() => _ArticleTextViewState();
}

class _ArticleTextViewState extends State<_ArticleTextView> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.article.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          leading: IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.black54,
              child: Icon(Icons.arrow_back,
                  color: Colors.white, size: 18),
            ),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(
                  _isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  color: _isBookmarked
                      ? AppTheme.primary
                      : Colors.white,
                  size: 18,
                ),
              ),
              onPressed: () async {
                await toggleBookmark(article.id, _isBookmarked);
                setState(() => _isBookmarked = !_isBookmarked);
                article.isBookmarked = _isBookmarked;
                widget.ref
                    .invalidate(articleDetailProvider(widget.articleId));
                widget.ref.invalidate(bookmarksProvider);
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                NewsImage(url: article.imageUrl),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.category != null) ...[
                  CategoryBadge(category: article.category!),
                  const SizedBox(height: 12),
                ],
                Text(article.title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.35)),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.access_time,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(article.timeAgo,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                  if (article.sourceName != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.source_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(article.sourceName!,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ]),
                const Divider(height: 28),
                if (article.summary != null &&
                    article.summary!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                          left: BorderSide(
                              color: AppTheme.primary, width: 3)),
                    ),
                    child: Text(article.summary!,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            fontStyle: FontStyle.italic)),
                  ),
                  const SizedBox(height: 20),
                ],
                if (article.content != null &&
                    article.content!.isNotEmpty)
                  Text(article.content!,
                      style: const TextStyle(
                          fontSize: 15, height: 1.8))
                else
                  Text(
                      article.summary ??
                          'Konten artikel tidak tersedia.',
                      style: const TextStyle(
                          fontSize: 15, height: 1.8)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}