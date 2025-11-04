import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Cached image widget for movie posters and backdrops
/// Uses CachedNetworkImage to improve performance by caching images
class CachedMovieImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedMovieImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle empty or invalid URLs
    if (imageUrl.isEmpty || imageUrl == 'null') {
      return _buildErrorWidget();
    }

    // Build full URL if needed
    final String fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : 'https://image.tmdb.org/t/p/w500$imageUrl';

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: fullUrl,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth ?? 500,
        memCacheHeight: memCacheHeight,
        placeholder: (context, url) =>
            placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A2332),
            const Color(0xFF0F1922),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan.shade300),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A2332),
            const Color(0xFF0F1922),
          ],
        ),
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            color: Colors.grey.shade600,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cached image for movie poster (vertical)
class CachedMoviePoster extends StatelessWidget {
  final String posterPath;
  final double? width;
  final double? height;

  const CachedMoviePoster({
    Key? key,
    required this.posterPath,
    this.width = 150,
    this.height = 225,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedMovieImage(
      imageUrl: posterPath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
      memCacheWidth: 300, // Smaller cache size for posters
    );
  }
}

/// Cached image for movie backdrop (horizontal)
class CachedMovieBackdrop extends StatelessWidget {
  final String backdropPath;
  final double? width;
  final double? height;

  const CachedMovieBackdrop({
    Key? key,
    required this.backdropPath,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedMovieImage(
      imageUrl: backdropPath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      memCacheWidth: 800, // Larger cache size for backdrops
    );
  }
}

/// Shimmer loading effect for images
class ShimmerLoading extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 - _controller.value * 2, 0.0),
              colors: [
                const Color(0xFF1A2332),
                const Color(0xFF2A3342),
                const Color(0xFF1A2332),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
