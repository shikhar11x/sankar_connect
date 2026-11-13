import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/product_sort.dart';
import '../repositories/product_repository.dart';

/// State for the Home dashboard: featured items, recently added items and
/// category shortcuts.
class HomeProvider extends ChangeNotifier {
  HomeProvider(this._repository);

  static const int _featuredCount = 8;
  static const int _recentCount = 10;

  final ProductRepository _repository;

  List<Product> _featured = const <Product>[];
  List<Product> _recent = const <Product>[];
  List<ProductCategory> _categories = const <ProductCategory>[];

  bool _isLoading = false;
  bool _initialized = false;
  String? _errorMessage;

  List<Product> get featured => _featured;
  List<Product> get recent => _recent;
  List<ProductCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads the dashboard once. Safe to call from `initState`.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await load();
  }

  /// Loads everything (also used for pull-to-refresh and retry).
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _repository.getProducts(
          limit: _featuredCount,
          sort: ProductSort.topRated,
        ),
        _loadRecent(),
        _repository.getCategories(),
      ]);

      _featured = (results[0] as ProductPage).products;
      _recent = results[1] as List<Product>;
      _categories = results[2] as List<ProductCategory>;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something unexpected happened. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// The API has no reliable "created date" sort, so the newest products are
  /// taken from the end of the catalogue: one request finds the total, a
  /// second fetches the last [_recentCount] items, newest first.
  Future<List<Product>> _loadRecent() async {
    final ProductPage probe = await _repository.getProducts(limit: 1);
    final int skip = probe.total > _recentCount ? probe.total - _recentCount : 0;
    final ProductPage page = await _repository.getProducts(
      limit: _recentCount,
      skip: skip,
    );
    return page.products.reversed.toList(growable: false);
  }
}