import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

/// Editable search field with a clear button. Used on the Listing screen.
class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'Search products...',
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue value, Widget? _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                controller.clear();
                onChanged('');
                onClear?.call();
              },
            );
          },
        ),
      ),
    );
  }
}

/// Look-alike search bar that does not take input. Tapping it opens the
/// Listing screen. Used on the Home dashboard.
class TappableSearchBar extends StatelessWidget {
  const TappableSearchBar({
    super.key,
    required this.onTap,
    this.hintText = 'Search products...',
  });

  final VoidCallback onTap;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceM,
            vertical: 17,
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hintText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.tune_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
