part of '../feed_screen.dart';

class _VideoSection extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article) onOpen;

  const _VideoSection({
    required this.articles,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFF151515),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Video Terbaru',
                  dark: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: articles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, index) {
                      final article = articles[index];

                      return _VideoCard(
                        article: article,
                        onTap: () => onOpen(article),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _VideoCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NewsImage(
                    url: article.imageUrl,
                    width: 280,
                    height: 156,
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool dark;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.dark = false,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        dark ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _SolidCategoryLabel extends StatelessWidget {
  final String label;
  final bool small;

  const _SolidCategoryLabel(
    this.label, {
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 9,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 60,
              runSpacing: 24,
              children: [
                _FooterColumn(
                  title: 'TAR News',
                  items: [
                    'Portal berita cepat dan terpercaya',
                    'Menyajikan berita terkini Indonesia',
                  ],
                ),
                _FooterColumn(
                  title: 'Menu',
                  items: [
                    'Beranda',
                    'Kategori',
                    'Bookmark',
                    'Profil',
                  ],
                ),
                _FooterColumn(
                  title: 'Follow Us',
                  items: [
                    'Instagram',
                    'Facebook',
                    'X',
                    'YouTube',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FooterColumn({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                item,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
