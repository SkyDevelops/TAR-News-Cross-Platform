import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class NewsImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const NewsImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  static const Map<String, String> _imageHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
  };

  @override
  Widget build(BuildContext context) {
    final imageUrl = _normalizeUrl(url);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null) {
      return _buildContainer(
        child: _NewsImagePlaceholder(
          isDark: isDark,
          icon: Icons.image_outlined,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);

        final displayWidth = _resolveDisplayWidth(context, constraints);
        final displayHeight = _resolveDisplayHeight(displayWidth, constraints);

        final memCacheWidth = (displayWidth * dpr)
            .round()
            .clamp(1, 1200)
            .toInt();

        final memCacheHeight = (displayHeight * dpr)
            .round()
            .clamp(1, 900)
            .toInt();

        return _buildContainer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            httpHeaders: _imageHeaders,
            width: _widgetWidth,
            height: _widgetHeight,
            fit: fit,

            // Pakai memory resize saja.
            // Jangan pakai maxWidthDiskCache dan maxHeightDiskCache dulu.
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,

            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,

            placeholder: (_, __) => _NewsImagePlaceholder(
              isDark: isDark,
              icon: Icons.image_outlined,
            ),

            errorWidget: (_, __, error) {
              assert(() {
                debugPrint('NewsImage gagal load: $imageUrl');
                debugPrint('Error: $error');
                return true;
              }());

              return _NewsImagePlaceholder(
                isDark: isDark,
                icon: Icons.broken_image_outlined,
              );
            },
          ),
        );
      },
    );
  }

  static String? _normalizeUrl(String? value) {
    final raw = value?.trim();

    if (raw == null || raw.isEmpty) return null;

    var cleanUrl = raw
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();

    if (cleanUrl.startsWith('//')) {
      cleanUrl = 'https:$cleanUrl';
    }

    final uri = Uri.tryParse(cleanUrl);
    if (uri == null) return null;

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }

    return cleanUrl;
  }

  double? get _widgetHeight {
    if (height == null) return null;
    if (!height!.isFinite) return double.infinity;
    return height;
  }

  double? get _widgetWidth {
    if (width == null) return double.infinity;
    if (!width!.isFinite) return double.infinity;
    return width;
  }

  Widget _buildContainer({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        width: _widgetWidth,
        height: _widgetHeight,
        child: child,
      ),
    );
  }

  double _resolveDisplayWidth(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (width != null && width!.isFinite && width! > 0) {
      return width!;
    }

    if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
      return constraints.maxWidth;
    }

    return MediaQuery.sizeOf(context).width;
  }

  double _resolveDisplayHeight(
    double displayWidth,
    BoxConstraints constraints,
  ) {
    if (height != null && height!.isFinite && height! > 0) {
      return height!;
    }

    if (constraints.maxHeight.isFinite && constraints.maxHeight > 0) {
      return constraints.maxHeight;
    }

    return displayWidth * 9 / 16;
  }
}

class _NewsImagePlaceholder extends StatelessWidget {
  final bool isDark;
  final IconData icon;

  const _NewsImagePlaceholder({
    required this.isDark,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: Colors.grey,
        size: 30,
      ),
    );
  }
}

class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookmark,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: _hover ? 0.10 : 0.05),
                  blurRadius: _hover ? 18 : 10,
                  offset: Offset(0, _hover ? 8 : 4),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NewsImage(
                      url: widget.article.imageUrl,
                      height: 145,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 10),
                    if (widget.article.category != null)
                      CategoryBadge(category: widget.article.category!),
                    const SizedBox(height: 7),
                    Text(
                      widget.article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF202020),
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if ((widget.article.summary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.article.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.article.timeAgo,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ),
                        if (widget.onBookmark != null)
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: Icon(
                                widget.article.isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
                                color: widget.article.isBookmarked
                                    ? AppTheme.primary
                                    : Colors.grey,
                              ),
                              onPressed: widget.onBookmark,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeroArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;

  const HeroArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 320,
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
                        Colors.black.withValues(alpha: 0.02),
                        Colors.black.withValues(alpha: 0.12),
                        Colors.black.withValues(alpha: 0.86),
                      ],
                    ),
                  ),
                ),
                if (onBookmark != null)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: InkWell(
                      onTap: onBookmark,
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.42),
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
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            article.category!.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
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
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
      highlightColor:
          isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
      child: Container(
        height: 260,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class TarNewsLogo extends StatelessWidget {
  const TarNewsLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'TAR',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'NEWS',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
