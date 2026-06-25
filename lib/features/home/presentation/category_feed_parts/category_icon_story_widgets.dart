part of '../category_feed_screen.dart';

class _AutomotiveHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _AutomotiveHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryIconHeader(
      info: info,
      icon: Icons.directions_car_filled_rounded,
      chips: const ['Mobil', 'Motor', 'EV', 'Modifikasi'],
    );
  }
}

class _TravelHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _TravelHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryIconHeader(
      info: info,
      icon: Icons.flight_takeoff_rounded,
      chips: const ['Destinasi', 'Hotel', 'Kuliner', 'Tips'],
    );
  }
}

class _LifestyleHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _LifestyleHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryIconHeader(
      info: info,
      icon: Icons.spa_rounded,
      chips: const ['Wellness', 'Style', 'Hiburan', 'Inspirasi'],
    );
  }
}

class _CategoryIconHeader extends StatelessWidget {
  final _CategoryInfo info;
  final IconData icon;
  final List<String> chips;

  const _CategoryIconHeader({
    required this.info,
    required this.icon,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE7E7E7),
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
            child: Icon(icon, color: AppTheme.primary, size: 32),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chips.map((chip) => _TechPill(text: chip)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AutomotiveHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _AutomotiveHeroCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryOverlayHero(
      article: article,
      label: 'Garasi Utama',
      icon: Icons.speed_rounded,
      height: height,
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _TravelHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TravelHeroCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryOverlayHero(
      article: article,
      label: 'Destinasi Utama',
      icon: Icons.explore_rounded,
      height: height,
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _LifestyleSpotlight extends StatelessWidget {
  final Article article;
  final bool isDesktop;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _LifestyleSpotlight({
    required this.article,
    required this.isDesktop,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryOverlayHero(
      article: article,
      label: 'Sorotan Lifestyle',
      icon: Icons.auto_awesome_rounded,
      height: isDesktop ? 430 : 320,
      onTap: onTap,
      onBookmark: onBookmark,
    );
  }
}

class _CategoryOverlayHero extends StatelessWidget {
  final Article article;
  final String label;
  final IconData icon;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _CategoryOverlayHero({
    required this.article,
    required this.label,
    required this.icon,
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
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.90),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: const TextStyle(
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
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.44),
                  ),
                  icon: Icon(
                    article.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    color:
                        article.isBookmarked ? AppTheme.primary : Colors.white,
                    size: 22,
                  ),
                  onPressed: onBookmark,
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
                    Text(
                      article.timeAgo,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
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

class _AutomotivePitlanePanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _AutomotivePitlanePanel({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _NumberedArticlePanel(
      title: 'Pit Lane',
      icon: Icons.flag_rounded,
      articles: articles,
      onOpen: onOpen,
    );
  }
}

class _LifestyleEditorPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _LifestyleEditorPanel({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _NumberedArticlePanel(
      title: 'Pilihan Editor',
      icon: Icons.favorite_rounded,
      articles: articles,
      onOpen: onOpen,
    );
  }
}

class _NumberedArticlePanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _NumberedArticlePanel({
    required this.title,
    required this.icon,
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
              Icon(icon, color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
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
              final article = entry.value;

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onOpen(article),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == articles.length - 1 ? 0 : 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
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

class _AutomotiveMetricStrip extends StatelessWidget {
  const _AutomotiveMetricStrip();

  @override
  Widget build(BuildContext context) {
    const topics = [
      _CategoryTopic(label: 'Test Drive', icon: Icons.speed_rounded),
      _CategoryTopic(label: 'Motor', icon: Icons.two_wheeler_rounded),
      _CategoryTopic(label: 'EV', icon: Icons.electric_car_rounded),
      _CategoryTopic(label: 'Industri', icon: Icons.precision_manufacturing),
    ];

    return const _CategoryTopicStrip(topics: topics);
  }
}

class _TravelRouteStrip extends StatelessWidget {
  const _TravelRouteStrip();

  @override
  Widget build(BuildContext context) {
    const topics = [
      _CategoryTopic(label: 'Pantai', icon: Icons.beach_access_rounded),
      _CategoryTopic(label: 'Kota', icon: Icons.location_city_rounded),
      _CategoryTopic(label: 'Kuliner', icon: Icons.restaurant_rounded),
      _CategoryTopic(label: 'Panduan', icon: Icons.map_rounded),
    ];

    return const _CategoryTopicStrip(topics: topics);
  }
}

class _LifestyleMoodStrip extends StatelessWidget {
  const _LifestyleMoodStrip();

  @override
  Widget build(BuildContext context) {
    const topics = [
      _CategoryTopic(label: 'Wellness', icon: Icons.spa_rounded),
      _CategoryTopic(label: 'Fashion', icon: Icons.checkroom_rounded),
      _CategoryTopic(label: 'Hiburan', icon: Icons.movie_rounded),
      _CategoryTopic(label: 'Rumah', icon: Icons.weekend_rounded),
    ];

    return const _CategoryTopicStrip(topics: topics);
  }
}
