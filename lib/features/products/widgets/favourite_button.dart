import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../favourites/providers/favourites_provider.dart';
import '../models/product.dart';

/// Round heart button that toggles a product in the favourites list.
///
/// It rebuilds only when this product's favourite state changes.
class FavouriteButton extends StatelessWidget {
  const FavouriteButton({super.key, required this.product, this.size = 38});

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isFavourite = context.select<FavouritesProvider, bool>(
      (FavouritesProvider provider) => provider.isFavourite(product.id),
    );

    return Tooltip(
      message: isFavourite ? 'Remove from favourites' : 'Add to favourites',
      child: Material(
        color: colors.surface.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.read<FavouritesProvider>().toggle(product),
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isFavourite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey<bool>(isFavourite),
                size: size * 0.55,
                color: isFavourite ? AppColors.error : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
