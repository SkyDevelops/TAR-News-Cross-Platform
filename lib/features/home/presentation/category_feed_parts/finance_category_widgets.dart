part of '../category_feed_screen.dart';

class _FinanceHeader extends StatelessWidget {
  final _CategoryInfo info;

  const _FinanceHeader({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 4),
                Text(
                  info.subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 14,
                    height: 1.45,
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

class _MarketSummaryStrip extends StatelessWidget {
  const _MarketSummaryStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      _FinanceMetric(
        title: 'Market',
        value: 'Update',
        icon: Icons.show_chart_rounded,
      ),
      _FinanceMetric(
        title: 'Rupiah',
        value: 'Finance',
        icon: Icons.currency_exchange_rounded,
      ),
      _FinanceMetric(
        title: 'IHSG',
        value: 'Business',
        icon: Icons.bar_chart_rounded,
      ),
      _FinanceMetric(
        title: 'Economy',
        value: 'Insight',
        icon: Icons.account_balance_rounded,
      ),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _MarketSummaryCard(metric: items[index]);
        },
      ),
    );
  }
}

class _FinanceMetric {
  final String title;
  final String value;
  final IconData icon;

  const _FinanceMetric({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _MarketSummaryCard extends StatelessWidget {
  final _FinanceMetric metric;

  const _MarketSummaryCard({
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              metric.icon,
              color: AppTheme.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.title,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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

class _FinanceHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _FinanceHeroCard({
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
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.94),
                      Colors.black.withValues(alpha: 0.48),
                      Colors.black.withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 18,
                left: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'MARKET UPDATE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 18,
                right: 18,
                child: InkWell(
                  onTap: onBookmark,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      article.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: article.isBookmarked
                          ? AppTheme.primary
                          : Colors.white,
                      size: 23,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 26,
                right: 80,
                bottom: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SolidLabel(text: 'Finance'),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white70,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          article.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.74),
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

class _FinanceBriefPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _FinanceBriefPanel({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Market Brief',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF202020),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF),
          ),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: articles.length,
              separatorBuilder: (_, __) {
                return Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFEFEFEF),
                );
              },
              itemBuilder: (context, index) {
                final article = articles[index];

                return InkWell(
                  onTap: () => onOpen(article),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.attach_money_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            article.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF202020),
                              fontSize: 13.5,
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceHorizontalHeadlines extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _FinanceHorizontalHeadlines({
    required this.articles,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final article = articles[index];

          return SizedBox(
            width: 310,
            child: _FinanceHeadlineCard(
              article: article,
              onTap: () => onOpen(article),
              onBookmark: () => onBookmark(article),
            ),
          );
        },
      ),
    );
  }
}

class _FinanceHeadlineCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _FinanceHeadlineCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: 10,
                left: 10,
                child: _SolidLabel(text: 'Business'),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: IconButton(
                  icon: Icon(
                    article.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    color:
                        article.isBookmarked ? AppTheme.primary : Colors.white,
                  ),
                  onPressed: onBookmark,
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _FinanceNewsRow({
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: NewsImage(
                  url: article.imageUrl,
                  width: 210,
                  height: 124,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _OutlineLabel(text: 'Finance'),
                    const SizedBox(height: 9),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
                        fontSize: 18,
                        height: 1.32,
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
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.timeAgo,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

class _FinanceInsightPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _FinanceInsightPanel({
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
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Financial Insight'),
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
                      Icons.insights_rounded,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
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

class _FinanceStoryGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;

  const _FinanceStoryGrid({
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
        childAspectRatio: columns == 1 ? 1.65 : 1.02,
      ),
      itemBuilder: (_, index) {
        final article = articles[index];

        return ArticleCard(
          article: article,
          onTap: () => onOpen(article),
          onBookmark: () => onBookmark(article),
        );
      },
    );
  }
}
