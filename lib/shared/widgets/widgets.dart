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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final placeholder = Container(
      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );

    if (url == null || url!.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: SizedBox(
          height: height,
          width: width,
          child: placeholder,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: url!,
        height: height,
        width: width,
        fit: fit,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
          highlightColor:
              isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
          child: Container(
            color: Colors.white,
            height: height,
            width: width,
          ),
        ),
        errorWidget: (_, __, ___) => SizedBox(
          height: height,
          width: width,
          child: placeholder,
        ),
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
