import '../../../core/constants/api_constants.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/product_sort.dart';
import '../services/product_service.dart';

/// The only data entry point that providers use for products.
///
/// It hides the service behind a small, UI-friendly interface, and is the
/// place to add caching later without touching any screen.
class ProductRepository {
  ProductRepository(this._service);

  final ProductService _service;

  Future<ProductPage> getProducts({
    int limit = ApiConstants.pageSize,
    int skip = 0,
    ProductSort sort = ProductSort.relevance,
    String? categorySlug,
    String? query,
  }) {
    return _service.fetchProducts(
      limit: limit,
      skip: skip,
      sort: sort,
      categorySlug: categorySlug,
      query: query,
    );
  }

  Future<List<ProductCategory>> getCategories() => _service.fetchCategories();

  Future<Product> getProductById(int id) => _service.fetchProductById(id);

  /// Loads the products for a list of saved favourite IDs.
  ///
  /// Requests run in parallel. An item that fails to load (for example
  /// removed from the server) is skipped instead of failing the whole list,
  /// unless every request fails, in which case the first error is rethrown so
  /// the UI can show a retry state.
  Future<List<Product>> getProductsByIds(List<int> ids) async {
    if (ids.isEmpty) return const <Product>[];

    Object? firstError;
    final List<Product?> results = await Future.wait<Product?>(
      ids.map((int id) async {
        try {
          return await _service.fetchProductById(id);
        } catch (error) {
          firstError ??= error;
          return null;
        }
      }),
    );

    final List<Product> products = results.whereType<Product>().toList();
    if (products.isEmpty && firstError != null) {
      throw firstError!;
    }
    return products;
  }
}
