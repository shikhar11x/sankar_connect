import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/product_sort.dart';

/// Raw DummyJSON calls. Returns parsed models and throws `ApiException`.
class ProductService {
  ProductService(this._client);

  final ApiClient _client;

  /// Fetches one page of products.
  ///
  /// Priority: a non-empty [query] searches the whole catalogue, otherwise a
  /// [categorySlug] filters by category, otherwise all products are returned.
  Future<ProductPage> fetchProducts({
    int limit = ApiConstants.pageSize,
    int skip = 0,
    ProductSort sort = ProductSort.relevance,
    String? categorySlug,
    String? query,
  }) async {
    final String trimmedQuery = query?.trim() ?? '';

    final String path;
    if (trimmedQuery.isNotEmpty) {
      path = ApiConstants.search;
    } else if (categorySlug != null && categorySlug.isNotEmpty) {
      path = ApiConstants.categoryProducts(categorySlug);
    } else {
      path = ApiConstants.products;
    }

    final Map<String, dynamic> params = <String, dynamic>{
      'limit': limit,
      'skip': skip,
      if (trimmedQuery.isNotEmpty) 'q': trimmedQuery,
      if (sort.sortBy != null) 'sortBy': sort.sortBy,
      if (sort.order != null) 'order': sort.order,
    };

    final Map<String, dynamic> json = await _client.get<Map<String, dynamic>>(
      path,
      query: params,
    );
    return ProductPage.fromJson(json);
  }

  Future<List<ProductCategory>> fetchCategories() async {
    final List<dynamic> json = await _client.get<List<dynamic>>(
      ApiConstants.categories,
    );
    return json.map(ProductCategory.fromJson).toList(growable: false);
  }

  Future<Product> fetchProductById(int id) async {
    final Map<String, dynamic> json = await _client.get<Map<String, dynamic>>(
      ApiConstants.productById(id),
    );
    return Product.fromJson(json);
  }
}
