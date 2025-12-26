
import 'package:laza/models/product.dart';

class SearchService {
List<Product> searchProducts({
required List<Product> products,
required String query,
double? minPrice,
double? maxPrice,
String? category,
String sortBy = 'Relevance',
}) {
// Filter by search query
List<Product> filtered = products.where((product) {
final matchesQuery = product.title.toLowerCase().contains(query.toLowerCase()) ||
product.description.toLowerCase().contains(query.toLowerCase());

// Filter by price if provided
final priceMatch = _matchesPrice(product, minPrice, maxPrice);

// Filter by category if provided (note: API doesn't have categories, so we'll simulate)
final categoryMatch = _matchesCategory(product, category);

return matchesQuery && priceMatch && categoryMatch;
}).toList();

// Sort results
return _sortProducts(filtered, sortBy);
}

bool _matchesPrice(Product product, double? minPrice, double? maxPrice) {
if (minPrice == null && maxPrice == null) return true;

// Extract price from string (e.g., "$129.99" -> 129.99)
final priceString = product.price.replaceAll('\$', '');
final price = double.tryParse(priceString) ?? 0.0;

if (minPrice != null && price < minPrice) return false;
if (maxPrice != null && price > maxPrice) return false;

return true;
}

bool _matchesCategory(Product product, String? category) {
if (category == null || category == 'All') return true;

// Since API doesn't have categories, we'll simulate based on title/description
// In a real app, you'd have actual category data
final productTitle = product.title.toLowerCase();
final productDesc = product.description.toLowerCase();
final cat = category.toLowerCase();

// Simple category matching logic
if (cat == 'electronics') {
return productTitle.contains('phone') ||
productTitle.contains('laptop') ||
productTitle.contains('electronic') ||
productDesc.contains('electronic');
} else if (cat == 'clothing') {
return productTitle.contains('shirt') ||
productTitle.contains('dress') ||
productTitle.contains('clothing') ||
productDesc.contains('clothing');
} else if (cat == 'home') {
return productTitle.contains('home') ||
productTitle.contains('furniture') ||
productDesc.contains('home');
} else if (cat == 'beauty') {
return productTitle.contains('beauty') ||
productTitle.contains('perfume') ||
productDesc.contains('beauty');
} else if (cat == 'sports') {
return productTitle.contains('sport') ||
productTitle.contains('fitness') ||
productDesc.contains('sport');
}

return true;
}

List<Product> _sortProducts(List<Product> products, String sortBy) {
List<Product> sorted = List.from(products);

switch (sortBy) {
case 'Price: Low to High':
sorted.sort((a, b) {
final priceA = _extractPrice(a.price);
final priceB = _extractPrice(b.price);
return priceA.compareTo(priceB);
});
break;

case 'Price: High to Low':
sorted.sort((a, b) {
final priceA = _extractPrice(a.price);
final priceB = _extractPrice(b.price);
return priceB.compareTo(priceA);
});
break;

case 'Newest':
// Since API doesn't have dates, sort by ID (assuming higher ID = newer)
sorted.sort((a, b) => b.id.compareTo(a.id));
break;

case 'Most Popular':
// Since API doesn't have popularity, sort by price as a placeholder
sorted.sort((a, b) {
final priceA = _extractPrice(a.price);
final priceB = _extractPrice(b.price);
return priceB.compareTo(priceA); // Higher price first as placeholder
});
break;

case 'Relevance':
default:
// Already filtered by relevance
break;
}

return sorted;
}

double _extractPrice(String priceString) {
final cleanString = priceString.replaceAll('\$', '').replaceAll(',', '');
return double.tryParse(cleanString) ?? 0.0;
}

// Get suggestions based on query
List<String> getSearchSuggestions(String query, List<String> history) {
if (query.isEmpty) return history.take(5).toList();

// Filter history by query
final fromHistory = history.where((item) =>
item.toLowerCase().contains(query.toLowerCase())
).take(3).toList();

// Add some generic suggestions
final suggestions = <String>[
if (query.length > 2) ...['$query shoes', '$query dress', '$query phone'],
];

return [...fromHistory, ...suggestions].take(5).toList();
}
}
