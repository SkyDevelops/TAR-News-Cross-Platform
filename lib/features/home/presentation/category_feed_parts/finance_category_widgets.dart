part of '../category_feed_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// FINANCE CATEGORY WIDGETS
// Thin entry-point: config finance-specific + komponen unik yang tidak bisa
// di-generalize. Widget struktural sudah dipindah
// ke shared_category_widgets.dart
// ════════════════════════════════════════════════════════════════════════════

// ── Finance-specific header (memakai _CategoryIconHeader dari shared) ─────
class _FinanceHeader extends StatelessWidget {
  final _CategoryInfo info;
  const _FinanceHeader({required this.info});

  @override
  Widget build(BuildContext context) => _CategoryIconHeader(
        info: info,
        icon: Icons.trending_up_rounded,
      );
}

// ── Market summary strip (unik untuk Finance, tidak ada di kategori lain) ──
class _MarketSummaryStrip extends StatelessWidget {
  const _MarketSummaryStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      _FinanceMetric(
          title: 'Market', value: 'Update', icon: Icons.show_chart_rounded),
      _FinanceMetric(
          title: 'Rupiah',
          value: 'Finance',
          icon: Icons.currency_exchange_rounded),
      _FinanceMetric(
          title: 'IHSG', value: 'Business', icon: Icons.bar_chart_rounded),
      _FinanceMetric(
          title: 'Economy',
          value: 'Insight',
          icon: Icons.account_balance_rounded),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _MarketSummaryCard(metric: items[index]),
      ),
    );
  }
}

class _FinanceMetric {
  final String title;
  final String value;
  final IconData icon;
  const _FinanceMetric(
      {required this.title, required this.value, required this.icon});
}

class _MarketSummaryCard extends StatelessWidget {
  final _FinanceMetric metric;
  const _MarketSummaryCard({required this.metric});

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
            child: Icon(metric.icon, color: AppTheme.primary, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metric.title,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 4),
                Text(metric.value,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF202020),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Finance hero card (delegasi ke _CategoryHeroCard) ─────────────────────
class _FinanceHeroCard extends StatelessWidget {
  final Article article;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  const _FinanceHeroCard(
      {required this.article,
      required this.onTap,
      required this.onBookmark,
      this.height});

  @override
  Widget build(BuildContext context) => _CategoryHeroCard(
        article: article,
        onTap: onTap,
        onBookmark: onBookmark,
        badgeLabel: 'MARKET UPDATE',
        badgeIcon: Icons.trending_up_rounded,
        height: height,
      );
}

// ── Finance brief panel (unik: daftar artikel vertikal dengan ikon money) ──
class _FinanceBriefPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _FinanceBriefPanel({required this.articles, required this.onOpen});

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
                const Icon(Icons.account_balance_wallet_rounded,
                    color: AppTheme.primary, size: 22),
                const SizedBox(width: 8),
                Text('Market Brief',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF202020),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    )),
              ],
            ),
          ),
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF)),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: articles.length,
              separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFEFEFEF)),
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
                          child: const Icon(Icons.attach_money_rounded,
                              color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(article.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF202020),
                                fontSize: 13.5,
                                height: 1.35,
                                fontWeight: FontWeight.w800,
                              )),
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

// ── Business headlines horizontal (delegasi ke _CategoryHorizontalScroll) ─
class _FinanceHorizontalHeadlines extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;
  const _FinanceHorizontalHeadlines(
      {required this.articles, required this.onOpen, required this.onBookmark});

  @override
  Widget build(BuildContext context) => _CategoryHorizontalScroll(
        articles: articles,
        cardBuilder: (article) => _CategoryHorizontalCard(
          article: article,
          labelText: 'Business',
          onTap: () => onOpen(article),
          onBookmark: () => onBookmark(article),
        ),
      );
}

// ── Finance news row (delegasi ke _CategoryNewsRow) ───────────────────────
class _FinanceNewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  const _FinanceNewsRow(
      {required this.article, required this.onTap, required this.onBookmark});

  @override
  Widget build(BuildContext context) => _CategoryNewsRow(
        article: article,
        labelText: 'Finance',
        onTap: onTap,
        onBookmark: onBookmark,
      );
}

// ── Finance insight panel (unik: daftar dengan icon insights) ─────────────
class _FinanceInsightPanel extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;
  const _FinanceInsightPanel({required this.articles, required this.onOpen});

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
                    const Icon(Icons.insights_rounded,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(article.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : const Color(0xFF202020),
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
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

// --- Finance story grid ---──
class _FinanceStoryGrid extends StatelessWidget {
  final List<Article> articles;
  final int columns;
  final void Function(Article article) onOpen;
  final Future<void> Function(Article article) onBookmark;
  const _FinanceStoryGrid(
      {required this.articles,
      required this.columns,
      required this.onOpen,
      required this.onBookmark});

  @override
  Widget build(BuildContext context) => _CategoryArticleGrid(
        articles: articles,
        columns: columns,
        onOpen: onOpen,
        onBookmark: onBookmark,
      );
}
