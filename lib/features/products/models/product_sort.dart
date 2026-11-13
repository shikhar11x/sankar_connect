/// Sorting choices offered on the listing screen.
enum ProductSort {
  relevance('Relevance', null, null),
  priceLowToHigh('Price: Low to High', 'price', 'asc'),
  priceHighToLow('Price: High to Low', 'price', 'desc'),
  topRated('Top Rated', 'rating', 'desc'),
  titleAZ('Name: A to Z', 'title', 'asc');

  const ProductSort(this.label, this.sortBy, this.order);

  final String label;

  /// Value for the `sortBy` query parameter, or `null` for default order.
  final String? sortBy;

  /// Value for the `order` query parameter, or `null` for default order.
  final String? order;
}
