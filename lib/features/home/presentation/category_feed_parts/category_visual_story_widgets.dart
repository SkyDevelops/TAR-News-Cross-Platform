part of '../category_feed_screen.dart';

class _CategoryTopic {
  final String label;
  final IconData icon;

  const _CategoryTopic({
    required this.label,
    required this.icon,
  });
}

class _CategoryTopicStrip extends StatelessWidget {
  final List<_CategoryTopic> topics;

  const _CategoryTopicStrip({
    required this.topics,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _CategoryTopicCard(topic: topics[index]);
        },
      ),
    );
  }
}

class _CategoryTopicCard extends StatelessWidget {
  final _CategoryTopic topic;

  const _CategoryTopicCard({
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(topic.icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF202020),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutomotiveReviewGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _AutomotiveReviewGrid({
    required this.articles,
    required this.columns,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryVisualGrid(
      articles: articles,
      columns: columns,
      label: 'Otomotif',
      onOpen: onOpen,
      onBookmark: onBookmark,
    );
  }
}

class _TravelDestinationGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _TravelDestinationGrid({
    required this.articles,
    required this.columns,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryVisualGrid(
      articles: articles,
      columns: columns,
      label: 'Travel',
      onOpen: onOpen,
      onBookmark: onBookmark,
    );
  }
}

class _LifestyleJournalGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _LifestyleJournalGrid({
    required this.articles,
    required this.columns,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryVisualGrid(
      articles: articles,
      columns: columns,
      label: 'Lifestyle',
      onOpen: onOpen,
      onBookmark: onBookmark,
    );
  }
}

class _CategoryVisualGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final String label;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _CategoryVisualGrid({
    required this.articles,
    required this.columns,
    required this.label,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      itemCount: articles.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: columns == 1 ? 1.14 : 0.98,
      ),
      itemBuilder: (_, index) {
        final article = articles[index];

        return _CategoryVisualCard(
          article: article,
          label: label,
          onTap: () => onOpen(article),
          onBookmark: () => onBookmark(article),
        );
      },
    );
  }
}

class _CategoryVisualCard extends StatelessWidget {
  final Article article;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _CategoryVisualCard({
    required this.article,
    required this.label,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  NewsImage(
                    url: article.imageUrl,
                    width: double.infinity,
                    height: 155,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.44),
                      ),
                      icon: Icon(
                        article.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: article.isBookmarked
                            ? AppTheme.primary
                            : Colors.white,
                        size: 20,
                      ),
                      onPressed: onBookmark,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OutlineLabel(text: label),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if ((article.summary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        article.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TravelPostcard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;

  const _TravelPostcard({
    required this.article,
    required this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NewsImage(
                url: article.imageUrl,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.03),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SolidLabel(text: 'Travel'),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (height != null) {
      return SizedBox(height: height, child: card);
    }

    return card;
  }
}

class _AutomotiveNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _AutomotiveNewsRow({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryHorizontalRow(
      article: article,
      label: 'Update Otomotif',
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _TravelStoryRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TravelStoryRow({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryHorizontalRow(
      article: article,
      label: 'Cerita Travel',
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _LifestyleListTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _LifestyleListTile({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryHorizontalRow(
      article: article,
      label: 'Update Lifestyle',
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _CategoryHorizontalRow extends StatelessWidget {
  final Article article;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _CategoryHorizontalRow({
    required this.article,
    required this.label,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              NewsImage(
                url: article.imageUrl,
                width: 190,
                height: 112,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OutlineLabel(text: label),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
                        fontSize: 17,
                        height: 1.35,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if ((article.summary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        article.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      article.timeAgo,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  article.isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  color: article.isBookmarked ? AppTheme.primary : Colors.grey,
                ),
                onPressed: onBookmark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
