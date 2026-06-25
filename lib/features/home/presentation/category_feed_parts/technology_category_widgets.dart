part of '../category_feed_screen.dart';

class _TechnologyHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _TechnologyHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.memory_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  info.subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TechPill(text: 'AI'),
                    _TechPill(text: 'Gadget'),
                    _TechPill(text: 'Startup'),
                    _TechPill(text: 'Cyber'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechPill extends StatelessWidget {
  final String text;

  const _TechPill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE3E3E3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF202020),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TechnologyHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TechnologyHeroCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
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
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.22),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Radar Teknologi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: InkWell(
                  onTap: onBookmark,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.44),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      article.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: article.isBookmarked
                          ? AppTheme.primary
                          : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if ((article.summary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        article.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          article.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12,
                          ),
                        ),
                      ],
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

class _TechnologyRadarPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _TechnologyRadarPanel({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.radar_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Sinyal Terbaru',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF202020),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (articles.isNotEmpty)
            ...articles.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == articles.length - 1 ? 0 : 12,
                ),
                child: _TechnologyRadarTile(
                  article: entry.value,
                  index: entry.key + 1,
                  onTap: () => onOpen(entry.value),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _TechnologyRadarTile extends StatelessWidget {
  final Article article;
  final int index;
  final VoidCallback onTap;

  const _TechnologyRadarTile({
    required this.article,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 14,
                    height: 1.32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  article.timeAgo,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechTopicStrip extends StatelessWidget {
  const _TechTopicStrip();

  @override
  Widget build(BuildContext context) {
    const topics = [
      _TechTopic(label: 'AI Watch', icon: Icons.auto_awesome_rounded),
      _TechTopic(label: 'Gadget Lab', icon: Icons.devices_other_rounded),
      _TechTopic(label: 'Cyber Desk', icon: Icons.security_rounded),
      _TechTopic(label: 'Startup', icon: Icons.rocket_launch_rounded),
    ];

    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _TechTopicCard(topic: topics[index]);
        },
      ),
    );
  }
}

class _TechTopic {
  final String label;
  final IconData icon;

  const _TechTopic({
    required this.label,
    required this.icon,
  });
}

class _TechTopicCard extends StatelessWidget {
  final _TechTopic topic;

  const _TechTopicCard({
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

class _TechnologyFeatureGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _TechnologyFeatureGrid({
    required this.articles,
    required this.columns,
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
        return _TechnologyFeatureCard(
          article: article,
          onTap: () => onOpen(article),
          onBookmark: () => onBookmark(article),
        );
      },
    );
  }
}

class _TechnologyFeatureCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TechnologyFeatureCard({
    required this.article,
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
                    const _OutlineLabel(text: 'Teknologi'),
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

class _TechnologySignalPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _TechnologySignalPanel({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Sinyal Inovasi'),
          const SizedBox(height: 14),
          ...articles.take(4).map((article) {
            return InkWell(
              onTap: () => onOpen(article),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.hub_rounded,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF202020),
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TechnologyNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TechnologyNewsRow({
    required this.article,
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
                    const _OutlineLabel(text: 'Update Teknologi'),
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
