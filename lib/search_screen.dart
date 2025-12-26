
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/models/product.dart';
import 'package:laza/services/product_service.dart';
import 'package:laza/services/search_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/colors.dart';
import 'components/laza_icons.dart';
import 'components/product_card.dart';
import 'product_details.dart';

class SearchScreen extends StatefulWidget {
const SearchScreen({super.key});

@override
State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
final TextEditingController _searchController = TextEditingController();
final ProductService _productService = ProductService();
final SearchService _searchService = SearchService();

List<Product> _allProducts = [];
List<Product> _searchResults = [];
List<String> _searchHistory = [];
bool _isLoading = true;
bool _isSearching = false;
String _currentQuery = '';

// Filter variables
double _minPrice = 0;
double _maxPrice = 1000;
String _selectedCategory = 'All';
String _sortBy = 'Relevance';

List<String> _categories = ['All', 'Electronics', 'Clothing', 'Home', 'Beauty', 'Sports'];
List<String> _sortOptions = ['Relevance', 'Price: Low to High', 'Price: High to Low', 'Newest', 'Most Popular'];

@override
void initState() {
super.initState();
_loadProducts();
_loadSearchHistory();
}

Future<void> _loadProducts() async {
setState(() => _isLoading = true);
_allProducts = await _productService.fetchProducts();
setState(() => _isLoading = false);
}

Future<void> _loadSearchHistory() async {
final prefs = await SharedPreferences.getInstance();
final history = prefs.getStringList('search_history') ?? [];
setState(() => _searchHistory = history.reversed.toList());
}

Future<void> _saveSearchToHistory(String query) async {
if (query.isEmpty) return;

final prefs = await SharedPreferences.getInstance();
List<String> history = prefs.getStringList('search_history') ?? [];

// Remove if already exists
history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());

// Add to beginning
history.insert(0, query);

// Keep only last 10 searches
if (history.length > 10) {
history = history.sublist(0, 10);
}

await prefs.setStringList('search_history', history);
await _loadSearchHistory();
}

Future<void> _clearSearchHistory() async {
final prefs = await SharedPreferences.getInstance();
await prefs.remove('search_history');
setState(() => _searchHistory = []);
}

void _performSearch(String query) {
if (query.isEmpty) {
setState(() {
_isSearching = false;
_searchResults = [];
_currentQuery = '';
});
return;
}

setState(() {
_isSearching = true;
_currentQuery = query;
_searchResults = _searchService.searchProducts(
products: _allProducts,
query: query,
minPrice: _minPrice,
maxPrice: _maxPrice,
category: _selectedCategory == 'All' ? null : _selectedCategory,
sortBy: _sortBy,
);
});

// Save to history
_saveSearchToHistory(query);
}

void _clearSearch() {
_searchController.clear();
setState(() {
_isSearching = false;
_searchResults = [];
_currentQuery = '';
});
}

void _searchFromHistory(String query) {
_searchController.text = query;
_performSearch(query);
}

void _showFilterDialog() {
showModalBottomSheet(
context: context,
isScrollControlled: true,
builder: (context) {
return StatefulBuilder(
builder: (context, setState) {
return Container(
padding: const EdgeInsets.all(20),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Filters', style: context.headlineSmall),
IconButton(
onPressed: () => Navigator.pop(context),
icon: const Icon(Icons.close),
),
],
),
const SizedBox(height: 20),

// Price Range
Text('Price Range', style: context.bodyLargeW600),
const SizedBox(height: 10),
RangeSlider(
values: RangeValues(_minPrice, _maxPrice),
min: 0,
max: 1000,
divisions: 20,
labels: RangeLabels(
'\$$_minPrice',
'\$$_maxPrice',
),
onChanged: (values) {
setState(() {
_minPrice = values.start;
_maxPrice = values.end;
});
},
),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('\$$_minPrice', style: context.bodySmall),
Text('\$$_maxPrice', style: context.bodySmall),
],
),

const SizedBox(height: 20),

// Category
Text('Category', style: context.bodyLargeW600),
const SizedBox(height: 10),
Wrap(
spacing: 10,
runSpacing: 10,
children: _categories.map((category) {
final isSelected = _selectedCategory == category;
return ChoiceChip(
label: Text(category),
selected: isSelected,
onSelected: (selected) {
setState(() => _selectedCategory = category);
},
);
}).toList(),
),

const SizedBox(height: 20),

// Sort By
Text('Sort By', style: context.bodyLargeW600),
const SizedBox(height: 10),
DropdownButtonFormField<String>(
value: _sortBy,
items: _sortOptions.map((option) {
return DropdownMenuItem(
value: option,
child: Text(option),
);
}).toList(),
onChanged: (value) {
setState(() => _sortBy = value!);
},
decoration: InputDecoration(
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),

const SizedBox(height: 30),

// Apply Button
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
Navigator.pop(context);
_performSearch(_currentQuery);
},
style: ElevatedButton.styleFrom(
backgroundColor: ColorConstant.primary,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
),
child: Text(
'Apply Filters',
style: context.bodyLarge?.copyWith(color: Colors.white),
),
),
),
const SizedBox(height: 20),
],
),
);
},
);
},
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
resizeToAvoidBottomInset: false,
appBar: SearchAppBar(
controller: _searchController,
onSearchChanged: _performSearch,
onClearSearch: _clearSearch,
onFilterPressed: _showFilterDialog,
),
body: SafeArea(
child: _isLoading
? const Center(child: CircularProgressIndicator())
    : _buildBody(),
),
);
}

Widget _buildBody() {
if (_isSearching) {
return _buildSearchResults();
} else {
return _buildSearchHome();
}
}

Widget _buildSearchHome() {
return ListView(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
children: [
// Search History
if (_searchHistory.isNotEmpty) ...[
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Recent Searches', style: context.bodyLargeW600),
TextButton(
onPressed: _clearSearchHistory,
child: Text(
'Clear All',
style: context.bodySmall?.copyWith(color: Colors.red),
),
),
],
),
const SizedBox(height: 10),
Wrap(
  spacing: 10,
  runSpacing: 10,
  children: _searchHistory.map((query) {
    return InputChip(
      label: Text(query),
      onPressed: () => _searchFromHistory(query),
      avatar: const Icon(Icons.history, size: 16),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        // Remove from history
        _searchHistory.remove(query);
        _saveSearchHistoryList(_searchHistory);
      },
    );
  }).toList(),
),
const SizedBox(height: 30),
],

// Popular Categories
Text('Popular Categories', style: context.bodyLargeW600),
const SizedBox(height: 15),
SizedBox(
height: 100,
child: ListView(
scrollDirection: Axis.horizontal,
children: [
_buildCategoryCard('Electronics', Icons.phone_iphone, Colors.blue),
_buildCategoryCard('Clothing', Icons.shopping_bag, Colors.pink),
_buildCategoryCard('Home', Icons.home, Colors.green),
_buildCategoryCard('Beauty', Icons.spa, Colors.purple),
_buildCategoryCard('Sports', Icons.sports_basketball, Colors.orange),
],
),
),
const SizedBox(height: 30),

// Trending Products
Text('Trending Products', style: context.bodyLargeW600),
const SizedBox(height: 15),
SizedBox(
height: 200,
child: ListView(
scrollDirection: Axis.horizontal,
children: _allProducts.take(5).map((product) {
return Container(
width: 150,
margin: const EdgeInsets.only(right: 15),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: ClipRRect(
borderRadius: BorderRadius.circular(10),
child: Image.network(
product.image,
fit: BoxFit.cover,
width: double.infinity,
),
),
),
const SizedBox(height: 8),
Text(
product.title,
style: context.bodySmall,
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
Text(
product.price,
style: context.bodyMediumW600,
),
],
),
);
}).toList(),
),
),
],
);
}

Widget _buildCategoryCard(String title, IconData icon, Color color) {
return Container(
width: 100,
margin: const EdgeInsets.only(right: 15),
child: Column(
children: [
Container(
width: 70,
height: 70,
decoration: BoxDecoration(
color: color.withOpacity(0.1),
borderRadius: BorderRadius.circular(20),
),
child: Icon(icon, color: color, size: 30),
),
const SizedBox(height: 10),
Text(
title,
style: context.bodySmall,
textAlign: TextAlign.center,
),
],
),
);
}

Widget _buildSearchResults() {
if (_searchResults.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.search_off,
size: 80,
color: ColorConstant.manatee.withOpacity(0.3),
),
const SizedBox(height: 20),
Text(
'No products found',
style: context.headlineSmall?.copyWith(
color: ColorConstant.manatee,
),
),
const SizedBox(height: 10),
Text(
'Try different keywords or filters',
style: context.bodyMedium?.copyWith(
color: ColorConstant.manatee,
),
),
const SizedBox(height: 20),
ElevatedButton(
onPressed: _clearSearch,
style: ElevatedButton.styleFrom(
backgroundColor: ColorConstant.primary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
),
child: const Text('Clear Search'),
),
],
),
);
}

return Column(
children: [
// Results header
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
'${_searchResults.length} results found',
style: context.bodyMedium?.copyWith(
color: ColorConstant.manatee,
),
),
Row(
children: [
IconButton(
onPressed: _showFilterDialog,
icon: const Icon(Icons.filter_list),
tooltip: 'Filters',
),
IconButton(
onPressed: () {
// TODO: Implement grid/list view toggle
},
icon: const Icon(Icons.grid_view),
tooltip: 'Change view',
),
],
),
],
),
),

// Results grid
Expanded(
child: GridView.builder(
padding: const EdgeInsets.symmetric(horizontal: 20),
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
mainAxisSpacing: 15,
crossAxisSpacing: 15,
mainAxisExtent: 250,
),
itemCount: _searchResults.length,
itemBuilder: (context, index) {
final product = _searchResults[index];
return ProductCard(product: product);
},
),
),
],
);
}

Future<void> _saveSearchHistoryList(List<String> history) async {
final prefs = await SharedPreferences.getInstance();
await prefs.setStringList('search_history', history);
setState(() => _searchHistory = history);
}
}

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
final TextEditingController controller;
final ValueChanged<String> onSearchChanged;
final VoidCallback onClearSearch;
final VoidCallback onFilterPressed;

const SearchAppBar({
super.key,
required this.controller,
required this.onSearchChanged,
required this.onClearSearch,
required this.onFilterPressed,
});

@override
Widget build(BuildContext context) {
const inputBorder = OutlineInputBorder(
borderRadius: BorderRadius.all(Radius.circular(10.0)),
borderSide: BorderSide(width: 0, color: Colors.transparent),
);

return AnnotatedRegion<SystemUiOverlayStyle>(
value: context.theme.appBarTheme.systemOverlayStyle!,
child: Container(
alignment: Alignment.bottomLeft,
child: Padding(
padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
child: Row(
children: [
// Back button
Hero(
tag: 'search_back',
child: Material(
color: Colors.transparent,
child: InkWell(
borderRadius: const BorderRadius.all(Radius.circular(50)),
onTap: () => Navigator.pop(context),
child: Ink(
width: 45,
height: 45,
decoration: ShapeDecoration(
color: context.theme.cardColor,
shape: const CircleBorder(),
),
child: const Icon(Icons.arrow_back_outlined),
),
),
),
),
const SizedBox(width: 12.0),

// Search field
Expanded(
child: Hero(
tag: 'search',
child: Material(
color: Colors.transparent,
child: TextField(
controller: controller,
autofocus: true,
onChanged: onSearchChanged,
decoration: InputDecoration(
filled: true,
hintText: 'Search products...',
contentPadding: EdgeInsets.zero,
border: inputBorder,
enabledBorder: inputBorder,
focusedBorder: inputBorder,
hintStyle: TextStyle(color: ColorConstant.manatee),
fillColor: context.theme.cardColor,
prefixIcon: Icon(Icons.search, color: ColorConstant.manatee),
suffixIcon: controller.text.isNotEmpty
? IconButton(
icon: const Icon(Icons.clear),
onPressed: onClearSearch,
)
    : null,
),
),
),
),
),
const SizedBox(width: 12.0),

// Filter button
Hero(
tag: 'filter',
child: Material(
color: Colors.transparent,
child: InkWell(
borderRadius: const BorderRadius.all(Radius.circular(50.0)),
onTap: onFilterPressed,
child: Ink(
width: 45,
height: 45,
decoration: BoxDecoration(
color: ColorConstant.primary,
borderRadius: const BorderRadius.all(Radius.circular(50.0)),
),
child: const Icon(Icons.filter_alt, color: Colors.white, size: 22),
),
),
),
),
],
),
),
),
);
}

@override
Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
