import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../models/product_category.dart';

/// Horizontally scrolling category filter. The first chip is "All".
///
/// [onSelected] receives the category slug, or `null` for "All".
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedSlug,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppTheme.spaceM),
  });

  final List<ProductCategory> categories;
  final String? selectedSlug;
  final ValueChanged<String?> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: categories.length + 1,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: AppTheme.spaceS);
        },
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All',
              selected: selectedSlug == null,
              onTap: () => onSelected(null),
            );
          }
          final ProductCategory category = categories[index - 1];
          return _CategoryChip(
            label: category.name,
            selected: selectedSlug == category.slug,
            onTap: () => onSelected(category.slug),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool value) => onTap(),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: selected ? primary : theme.colorScheme.onSurfaceVariant,
      ),
      side: BorderSide(color: selected ? primary : theme.colorScheme.outline),
    );
  }
}
