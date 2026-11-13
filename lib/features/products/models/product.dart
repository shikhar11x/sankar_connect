/// A single customer review attached to a product.
class ProductReview {
  const ProductReview({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    this.date,
  });

  final int rating;
  final String comment;
  final String reviewerName;
  final DateTime? date;

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      reviewerName: json['reviewerName'] as String? ?? 'Anonymous',
      date: DateTime.tryParse(json['date'] as String? ?? ''),
    );
  }
}

/// A product from the DummyJSON catalogue.
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
    required this.tags,
    required this.reviews,
    this.brand,
    this.availabilityStatus,
    this.warrantyInformation,
    this.shippingInformation,
    this.returnPolicy,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;
  final List<ProductReview> reviews;
  final String? brand;
  final String? availabilityStatus;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? returnPolicy;

  bool get hasDiscount => discountPercentage >= 1;

  bool get inStock => stock > 0;

  /// Price after the discount is applied.
  double get discountedPrice {
    return price - (price * discountPercentage / 100);
  }

  /// Gallery images, falling back to the thumbnail if none are provided.
  List<String> get imageUrls {
    if (images.isNotEmpty) return images;
    return thumbnail.isEmpty ? const <String>[] : <String>[thumbnail];
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: _toDouble(json['price']),
      discountPercentage: _toDouble(json['discountPercentage']),
      rating: _toDouble(json['rating']),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: _toStringList(json['images']),
      tags: _toStringList(json['tags']),
      reviews: _toReviews(json['reviews']),
      brand: json['brand'] as String?,
      availabilityStatus: json['availabilityStatus'] as String?,
      warrantyInformation: json['warrantyInformation'] as String?,
      shippingInformation: json['shippingInformation'] as String?,
      returnPolicy: json['returnPolicy'] as String?,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static List<String> _toStringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const <String>[];
  }

  static List<ProductReview> _toReviews(Object? value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(ProductReview.fromJson)
          .toList(growable: false);
    }
    return const <ProductReview>[];
  }
}

/// One page of products plus the metadata needed for pagination.
class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
  });

  final List<Product> products;

  /// Total number of products matching the query on the server.
  final int total;

  /// Offset this page started at.
  final int skip;

  /// Offset to use when requesting the next page.
  int get nextSkip => skip + products.length;

  bool get hasMore => products.isNotEmpty && nextSkip < total;

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final Object? rawProducts = json['products'];
    final List<Product> products = rawProducts is List
        ? rawProducts
              .whereType<Map<String, dynamic>>()
              .map(Product.fromJson)
              .toList(growable: false)
        : const <Product>[];
    return ProductPage(
      products: products,
      total: (json['total'] as num?)?.toInt() ?? products.length,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
    );
  }
}
