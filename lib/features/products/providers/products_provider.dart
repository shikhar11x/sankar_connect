import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/product_sort.dart';
import '../repositories/product_repository.dart';

/// State for the Listing screen: search, category filter, sorting,
/// pagination, pull-to-refresh and retry.
class ProductsProvider extends ChangeNotifier {
  ProductsProvider(this._repository);

  static const Duration _searchDelay = Duration(milliseconds: 450);

  final ProductRepository _repository;

  final List<Product> _items = <Product>[];
  List<ProductCategory> _categories = const <ProductCategory>[];

  String? _selectedCategory;
  String _query = '';
  ProductSort _sort = ProductSort.relevance;

  bool _initialized = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _nextSkip = 0;
  String? _errorMessage;
  String? _loadMoreError;

  /// Incremented for every fresh query so late responses can be discarded.
  int _requestId = 0;
  Timer? _debounce;

  List<Product> get items => List<Product>.unmodifiable(_items);
  List<ProductCategory> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  String get query => _query;
  ProductSort get sort => _sort;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String? get loadMoreError => _loadMoreError;

  /// True when the first load finished successfully with no results.
  bool get isEmpty => !_isLoading && _errorMessage == null && _items.isEmpty;

  /// Loads categories and the first page. Safe to call many times.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await Future.wait<void>(<Future<void>>[
      _loadCategories(),
      _loadFirstPage(),
    ]);
  }

  /// Pull-to-refresh: keeps the current list visible while reloading.
  Future<void> refresh() async {
    _initialized = true;
    await Future.wait<void>(<Future<void>>[
      if (_categories.isEmpty) _loadCategories(),
      _loadFirstPage(showLoader: false),
    ]);
  }

  /// Retry after an error.
  Future<void> retry() async {
    _initialized = true;
    await Future.wait<void>(<Future<void>>[
      if (_categories.isEmpty) _loadCategories(),
      _loadFirstPage(),
    ]);
  }

  /// Selects a category; `null` means "All". Clears any search text.
  Future<void> setCategory(String? slug) async {
    if (_initialized && slug == _selectedCategory && _query.isEmpty) return;
    _debounce?.cancel();
    _selectedCategory = slug;
    _query = '';
    await _startFresh();
  }

  /// Called on every keystroke. The request fires after a short pause.
  void onQueryChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, () => applyQuery(text));
  }

  /// Runs a search immediately (also used by the Home search bar).
  Future<void> applyQuery(String text) async {
    final String trimmed = text.trim();
    if (_initialized && trimmed == _query) return;
    _debounce?.cancel();
    _query = trimmed;
    // The search endpoint covers the whole catalogue, so the category
    // filter is cleared while searching.
    if (trimmed.isNotEmpty) _selectedCategory = null;
    await _startFresh();
  }

  Future<void> setSort(ProductSort value) async {
    if (value == _sort) return;
    _sort = value;
    await _startFresh();
  }

  /// Loads the next page. Called when the user scrolls near the end.
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    final int requestId = _requestId;
    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final ProductPage page = await _repository.getProducts(
        skip: _nextSkip,
        sort: _sort,
        categorySlug: _selectedCategory,
        query: _query,
      );
      if (requestId != _requestId) return;
      _items.addAll(page.products);
      _nextSkip = page.nextSkip;
      _hasMore = page.hasMore;
    } on ApiException catch (error) {
      if (requestId != _requestId) return;
      _loadMoreError = error.message;
    } catch (_) {
      if (requestId != _requestId) return;
      _loadMoreError = 'Could not load more items.';
    }

    if (requestId == _requestId) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> _startFresh() async {
    _initialized = true;
    if (_categories.isEmpty) unawaited(_loadCategories());
    await _loadFirstPage();
  }

  Future<void> _loadFirstPage({bool showLoader = true}) async {
    final int requestId = ++_requestId;

    _isLoadingMore = false;
    _loadMoreError = null;
    _errorMessage = null;
    if (showLoader) {
      _isLoading = true;
      _items.clear();
      _hasMore = false;
    }
    notifyListeners();

    try {
      final ProductPage page = await _repository.getProducts(
        skip: 0,
        sort: _sort,
        categorySlug: _selectedCategory,
        query: _query,
      );
      if (requestId != _requestId) return;
      _items
        ..clear()
        ..addAll(page.products);
      _nextSkip = page.nextSkip;
      _hasMore = page.hasMore;
    } on ApiException catch (error) {
      if (requestId != _requestId) return;
      _errorMessage = error.message;
    } catch (_) {
      if (requestId != _requestId) return;
      _errorMessage = 'Something unexpected happened. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (_) {
      // Categories are optional UI: the list still works without them and
      // they are requested again on refresh or retry.
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
