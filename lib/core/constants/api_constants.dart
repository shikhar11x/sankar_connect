/// Endpoints and network settings for the DummyJSON Products API.
///
/// API docs: https://dummyjson.com/docs/products
abstract final class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';

  static const String products = '/products';
  static const String search = '/products/search';
  static const String categories = '/products/categories';

  static String categoryProducts(String slug) => '/products/category/$slug';

  static String productById(int id) => '/products/$id';

  /// Number of items requested per page for pagination.
  static const int pageSize = 20;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
