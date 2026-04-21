import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/news_provider.dart';

final articleDetailProvider =
    FutureProvider.family<Article?, String>((ref, id) async {
  final data = await Supabase.instance.client
      .from('articles')
      .select()
      .eq('id', id)
      .maybeSingle();

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

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(articleId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: articleAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
        error: (e, st) => Center(
          child: Text(
            'Terjadi kesalahan\n$e',
            textAlign: TextAlign.center,
          ),
        ),
        data: (article) {
          if (article == null) {
            return const Center(
              child: Text('Artikel tidak ditemukan'),
            );
          }

          return _DetailContent(
            article: article,
            articleId: articleId,
            ref: ref,
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  final Article article;
  final String articleId;
  final WidgetRef ref;

  const _DetailContent({
    required this.article,
    required this.articleId,
    required this.ref,
  });

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  late bool bookmarked;

  @override
  void initState() {
    super.initState();
    bookmarked = widget.article.isBookmarked;
  }

  Future<void> toggle() async {
    await toggleBookmark(widget.article.id, bookmarked);

    setState(() {
      bookmarked = !bookmarked;
    });

    widget.ref.invalidate(bookmarksProvider);
    widget.ref.invalidate(articleDetailProvider(widget.articleId));
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    final htmlContent =
        article.content != null && article.content!.trim().isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => context.go('/home'),
            icon: const CircleAvatar(
              backgroundColor: Colors.black54,
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: toggle,
              icon: CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(
                  bookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  color: bookmarked
                      ? AppTheme.primary
                      : Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                NewsImage(
                  url: article.imageUrl,
                ),
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

        /// CONTENT
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                if (article.category != null) ...[
                  CategoryBadge(
                    category: article.category!,
                  ),
                  const SizedBox(height: 14),
                ],

                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      article.timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.source,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        article.sourceName ??
                            'Unknown Source',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary
                        .withValues(alpha: 0.05),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    article.summary ??
                        'Ringkasan tidak tersedia',
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// HTML CONTENT FULL
                if (htmlContent)
                  Html(
                    data: article.content!,
                    onLinkTap:
                        (url, _, __) async {
                      if (url == null) return;

                      final uri = Uri.parse(url);

                      if (await canLaunchUrl(
                          uri)) {
                        await launchUrl(uri);
                      }
                    },
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding:
                            HtmlPaddings.zero,
                        fontSize:
                            FontSize(16),
                        lineHeight:
                            const LineHeight(
                                1.8),
                        color:
                            Colors.black87,
                      ),
                      "p": Style(
                        margin:
                            Margins.only(
                                bottom: 18),
                      ),
                      "img": Style(
                        width: Width(
                            MediaQuery.of(
                                        context)
                                    .size
                                    .width -
                                40),
                        margin:
                            Margins.only(
                                bottom: 18),
                      ),
                      "h1": Style(
                        fontSize:
                            FontSize(24),
                        fontWeight:
                            FontWeight.bold,
                      ),
                      "h2": Style(
                        fontSize:
                            FontSize(22),
                        fontWeight:
                            FontWeight.bold,
                      ),
                      "h3": Style(
                        fontSize:
                            FontSize(20),
                        fontWeight:
                            FontWeight.bold,
                      ),
                      "blockquote": Style(
                        padding:
                            HtmlPaddings.all(
                                14),
                        margin:
                            Margins.only(
                                bottom: 20),
                        backgroundColor:
                            Colors.grey
                                .withValues(
                                    alpha:
                                        0.08),
                      ),
                    },
                  )
                else
                  Text(
                    article.content ??
                        'Isi berita belum tersedia.',
                    style:
                        const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),

                const SizedBox(height: 40),

                const Divider(),

                const SizedBox(height: 20),

                const Text(
                  'Sumber Berita',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  article.sourceName ??
                      '-',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 14),

                if (article.sourceUrl != null)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(
                          article.sourceUrl!);

                      if (await canLaunchUrl(
                          uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode
                              .externalApplication,
                        );
                      }
                    },
                    icon: const Icon(
                        Icons.open_in_new),
                    label: const Text(
                        'Buka Sumber Asli'),
                  ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }
}