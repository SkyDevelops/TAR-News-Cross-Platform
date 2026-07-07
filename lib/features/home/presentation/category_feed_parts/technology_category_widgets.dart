part of '../category_feed_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// TECHNOLOGY CATEGORY WIDGETS
// Thin entry-point: config teknologi-specific + komponen unik.
// Widget struktural sudah dipindah ke shared_category_widgets.dart
// ════════════════════════════════════════════════════════════════════════════

// ── Technology header (punya fitur unik: tech pills di bawah subtitle) ────
class _TechnologyHeader extends StatelessWidget {
  final _CategoryInfo info;
  const _TechnologyHeader({required this.info});

  @override
  Widget build(BuildContext context) => _CategoryIconHeader(
        info: info,
        icon: Icons.memory_rounded,
        extraContent: const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TechPill(text: 'AI'),
            _TechPill(text: 'Gadget'),
            _TechPill(text: 'Startup'),
            _TechPill(text: 'Cyber'),
          ],
        ),
      );
}

// ── Tech pills (unik untuk Technology header) ─────────────────────────────
class _TechPill extends StatelessWidget {
  final String text;
  const _TechPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF3F3F3),
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

// ── Technology hero card (delegasi ke _CategoryHeroCard) ──────────────────
class _TechnologyHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  const _TechnologyHeroCard({required this.article, required this.onTap, required this.onBookmark, this.height});

  @override
  Widget build(BuildContext context) => _CategoryHeroCard(
        article: article,
        onTap: onTap,
        onBookmark: onBookmark,
        badgeLabel: 'Radar Teknologi',
        badgeIcon: Icons.bolt_rounded,
        height: height,
      );
}

// ── Technology radar panel (unik: side panel dengan nomor urut + chip warna) ─
class _TechnologyRadarPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _TechnologyRadarPanel({required this.articles, required this.onOpen});

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
              const Icon(Icons.radar_rounded, color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              Text('Sinyal Terbaru',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 20, fontWeight: FontWeight.w900,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          if (articles.isNotEmpty)
            ...articles.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: entry.key == articles.length - 1 ? 0 : 12),
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
  const _TechnologyRadarTile({required this.article, required this.index, required this.onTap});

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
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('$index',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 14, fontWeight: FontWeight.w900,
                  )),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF202020),
                      fontSize: 14, height: 1.32, fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 5),
                Text(article.timeAgo,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tech topic strip (unik untuk Technology: horizontal topic cards) ───────
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
        itemBuilder: (context, index) => _TechTopicCard(topic: topics[index]),
      ),
    );
  }
}

class _TechTopic {
  final String label;
  final IconData icon;
  const _TechTopic({required this.label, required this.icon});
}

class _TechTopicCard extends StatelessWidget {
  final _TechTopic topic;
  const _TechTopicCard({required this.topic});

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
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(topic.icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(topic.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF202020),
                  fontSize: 15, fontWeight: FontWeight.w900,
                )),
          ),
        ],
      ),
    );
  }
}

// ── Technology feature grid (delegasi ke _CategoryArticleGrid) ────────────
class _TechnologyFeatureGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;
  const _TechnologyFeatureGrid({required this.articles, required this.columns, required this.onOpen, required this.onBookmark});

  @override
  Widget build(BuildContext context) => _CategoryArticleGrid(
        articles: articles,
        columns: columns,
        onOpen: onOpen,
        onBookmark: onBookmark,
        childAspectRatio: columns == 1 ? 1.14 : 0.98,
      );
}

// ── Technology signal panel (unik: list dengan icon hub) ──────────────────
class _TechnologySignalPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _TechnologySignalPanel({required this.articles, required this.onOpen});

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
                    const Icon(Icons.hub_rounded, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(article.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF202020),
                            fontSize: 14, height: 1.35, fontWeight: FontWeight.w800,
                          )),
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

// ── Technology news row (delegasi ke _CategoryNewsRow) ────────────────────
class _TechnologyNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  const _TechnologyNewsRow({required this.article, required this.onTap, required this.onBookmark});

  @override
  Widget build(BuildContext context) => _CategoryNewsRow(
        article: article,
        labelText: 'Update Teknologi',
        onTap: onTap,
        onBookmark: onBookmark,
      );
}
