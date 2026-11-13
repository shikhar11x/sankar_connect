import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network image with a soft placeholder, fade-in and an error fallback.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    Widget fallback(IconData icon) {
      return ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: Icon(icon, color: colors.onSurfaceVariant, size: 32),
        ),
      );
    }

    if (url.isEmpty) return fallback(Icons.image_not_supported_outlined);

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (BuildContext context, String imageUrl) {
        return ColoredBox(color: colors.surfaceContainerHighest);
      },
      errorWidget: (BuildContext context, String imageUrl, Object error) {
        return fallback(Icons.broken_image_outlined);
      },
    );
  }
}
