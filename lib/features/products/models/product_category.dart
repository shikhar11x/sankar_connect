import '../../../core/utils/formatters.dart';

/// A product category such as "smartphones" or "mens-shirts".
class ProductCategory {
  const ProductCategory({required this.slug, required this.name});

  /// URL-safe identifier used in API calls.
  final String slug;

  /// Human readable name.
  final String name;

  factory ProductCategory.fromJson(Object? json) {
    if (json is Map<String, dynamic>) {
      final String slug = json['slug'] as String? ?? '';
      final String name = json['name'] as String? ?? '';
      return ProductCategory(
        slug: slug,
        name: name.isEmpty ? Formatters.categoryLabel(slug) : name,
      );
    }
    final String slug = '$json';
    return ProductCategory(slug: slug, name: Formatters.categoryLabel(slug));
  }
}
