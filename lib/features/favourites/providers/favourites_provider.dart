import 'package:flutter/foundation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_storage.dart';
import '../../products/models/product.dart';
import '../../products/repositories/product_repository.dart';

/// Tracks favourite products.
///
/// Only the product IDs are persisted (SharedPreferences). The full products
/// are fetched from the API when the Favourites screen opens, so prices and
/// stock are always fresh. IDs are stored newest first.
class FavouritesProvider extends ChangeNotifier {
  FavouritesProvider(this._storage, this._repository)
    : _ids = _readIds(_storage);

  final LocalStorage _storage;
  final ProductRepository _repository;

  final List<int> _ids;
  List<Product> _loaded = <Product>[];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<int> get ids => List<int>.unmodifiable(_ids);

  int get count => _ids.length;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  /// Favourite products, in the same order as [ids].
  List<Product> get products {
    final Map<int, Product> byId = <int, Product>{
      for (final Product product in _loaded) product.id: product,
    };
    return <Product>[
      for (final int id in _ids)
        if (byId[id] != null) byId[id]!,
    ];
  }

  bool isFavourite(int productId) => _ids.contains(productId);

  /// Adds or removes [product] and saves the change immediately.
  Future<void> toggle(Product product) async {
    if (_ids.contains(product.id)) {
      _ids.remove(product.id);
      _loaded = _loaded.where((Product p) => p.id != product.id).toList();
    } else {
      _ids.insert(0, product.id);
      _loaded = <Product>[product, ..._loaded];
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(int productId) async {
    if (!_ids.contains(productId)) return;
    _ids.remove(productId);
    _loaded = _loaded.where((Product p) => p.id != productId).toList();
    notifyListeners();
    await _persist();
  }

  /// Loads products once. Call from the Favourites screen.
  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) return;
    await loadProducts();
  }

  /// Fetches the saved products from the API (also used for retry).
  Future<void> loadProducts() async {
    if (_ids.isEmpty) {
      _loaded = <Product>[];
      _errorMessage = null;
      _hasLoaded = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<int> requested = List<int>.of(_ids);
      final List<Product> fetched = await _repository.getProductsByIds(
        requested,
      );
      _loaded = fetched;
      _hasLoaded = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Could not load your favourites. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() {
    return _storage.setStringList(
      StorageKeys.favouriteIds,
      _ids.map((int id) => id.toString()).toList(),
    );
  }

  static List<int> _readIds(LocalStorage storage) {
    return storage
        .getStringList(StorageKeys.favouriteIds)
        .map(int.tryParse)
        .whereType<int>()
        .toList();
  }
}