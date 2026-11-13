/// Display helpers for prices, labels, greetings and names.
abstract final class Formatters {
  /// 12.5 -> $12.50
  static String price(double value) => '\$${value.toStringAsFixed(2)}';

  /// 12.4 -> 12% OFF
  static String discount(double percentage) => '${percentage.round()}% OFF';

  /// Price after applying a percentage discount.
  static double discountedPrice(double price, double percentage) {
    return price - (price * percentage / 100);
  }

  /// "mens-shirts" -> "Mens Shirts"
  static String categoryLabel(String slug) {
    if (slug.isEmpty) return slug;
    return slug
        .split('-')
        .where((String word) => word.isNotEmpty)
        .map((String word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Time-of-day greeting for the home screen.
  static String greeting([DateTime? now]) {
    final int hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// "Sankar Kumar" -> "SK", "Sankar" -> "S"
  static String initials(String fullName) {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// 4.5678 -> 4.6
  static String rating(double value) => value.toStringAsFixed(1);
}
