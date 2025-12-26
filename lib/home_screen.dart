
import 'package:flutter/material.dart';
import 'package:laza/brand_products_screen.dart';
import 'package:laza/cart_screen.dart';
import 'package:laza/components/colors.dart';
import 'package:laza/dashboard.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/search_screen.dart';
import 'package:laza/services/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';  // ADD THIS IMPORT
import 'package:provider/provider.dart';  // ADD THIS

import 'components/laza_icons.dart';
import 'components/product_card.dart';
import 'package:laza/models/brand.dart';
import 'package:laza/models/product.dart';

class HomeScreen extends StatefulWidget {
final VoidCallback? onMenuPressed;

const HomeScreen({super.key, this.onMenuPressed});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final ProductService _productService = ProductService();
List<Product> products = [];
List<Product> filteredProducts = [];
bool isLoading = true;
String searchQuery = '';

// Get current user
User? get currentUser => FirebaseAuth.instance.currentUser;

// Get user display name or email
String get userGreeting {
final user = currentUser;
if (user == null) return 'Hello';  // Fallback if no user

// Try to get display name first
if (user.displayName != null && user.displayName!.isNotEmpty) {
return 'Hello ${user.displayName!}';
}

// If no display name, use email (first part before @)
if (user.email != null) {
final email = user.email!;
final namePart = email.split('@').first;
return 'Hello $namePart';
}

return 'Hello';  // Final fallback
}

final brands = [
Brand('Adidas', LazaIcons.adidas_logo),
Brand('Nike', LazaIcons.nike_logo),
Brand('Puma', LazaIcons.puma_logo),
Brand('Fila', LazaIcons.fila_logo),
];

@override
void initState() {
super.initState();
_fetchProducts();
}

Future<void> _fetchProducts() async {
setState(() => isLoading = true);
products = await _productService.fetchProducts();
filteredProducts = products;
setState(() => isLoading = false);
}

void _filterProducts(String query) {
setState(() {
searchQuery = query;
filteredProducts = products
    .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
    .toList();
});
}

void _navigateToSearchScreen(BuildContext context) {
Navigator.push(
context,
MaterialPageRoute(builder: (context) => const SearchScreen()),
);
}

@override
Widget build(BuildContext context) {
const inputBorder = OutlineInputBorder(
borderRadius: BorderRadius.all(Radius.circular(10.0)),
borderSide: BorderSide(width: 0, color: Colors.transparent));

return Scaffold(
appBar: HomeAppBar(onMenuPressed: widget.onMenuPressed),
body: SafeArea(
child: ListView(
children: [
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// UPDATED: Show personalized greeting
Text(userGreeting, style: context.headlineMedium),
Text('Welcome to Laza', style: context.bodyMedium?.copyWith(color: ColorConstant.manatee)),
],
),
),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: Row(
children: [
Expanded(
child: Hero(
tag: 'search',
child: Material(
color: Colors.transparent,
child: TextField(
readOnly: true, // Make it read-only to open full search screen
onTap: () => _navigateToSearchScreen(context),
decoration: InputDecoration(
filled: true,
hintText: 'Search ...',
contentPadding: EdgeInsets.zero,
border: inputBorder,
enabledBorder: inputBorder,
focusedBorder: inputBorder,
hintStyle: TextStyle(color: ColorConstant.manatee),
fillColor: context.theme.cardColor,
prefixIcon: Icon(LazaIcons.search, color: ColorConstant.manatee),
),
),
),
),
),
const SizedBox(width: 10.0),
Hero(
tag: 'voice',
child: Material(
color: Colors.transparent,
child: InkWell(
borderRadius: const BorderRadius.all(Radius.circular(10.0)),
onTap: () {},
child: Ink(
width: 45,
height: 45,
decoration: BoxDecoration(color: ColorConstant.primary, borderRadius: const BorderRadius.all(Radius.circular(10.0))),
child: const Icon(LazaIcons.voice, color: Colors.white, size: 22),
),
),
),
)
],
),
),
const SizedBox(height: 10.0),
Headline(headline: 'Choose Brand', onViewAllTap: () {}),
SizedBox(
width: double.infinity,
height: 50,
child: ListView.separated(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
separatorBuilder: (_, __) => const SizedBox(width: 10.0),
physics: const BouncingScrollPhysics(),
shrinkWrap: true,
itemCount: brands.length,
scrollDirection: Axis.horizontal,
itemBuilder: (context, index) {
final brand = brands[index];
return BrandTile(brand: brand);
},
),
),
const SizedBox(height: 10.0),
Headline(headline: 'New Arrival', onViewAllTap: () {}),
isLoading
? const Center(child: CircularProgressIndicator())
    : filteredProducts.isEmpty
? Center(child: Text('No products found', style: context.bodyLarge))
    : GridView.builder(
shrinkWrap: true,
itemCount: filteredProducts.length,
padding: const EdgeInsets.symmetric(horizontal: 20.0),
physics: const NeverScrollableScrollPhysics(),
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
mainAxisExtent: 270,
crossAxisSpacing: 15.0,
mainAxisSpacing: 15.0,
),
itemBuilder: (context, index) {
final product = filteredProducts[index];
return ProductCard(product: product);
},
),
],
),
),
);
}
}

class Headline extends StatelessWidget {
const Headline({super.key, required this.headline, this.onViewAllTap});
final String headline;
final void Function()? onViewAllTap;

@override
Widget build(BuildContext context) {
return Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(headline, style: context.bodyLargeW500),
TextButton(
onPressed: onViewAllTap,
child: Text('View All', style: context.bodySmall?.copyWith(color: ColorConstant.manatee)),
)
],
),
);
}
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
final VoidCallback? onMenuPressed;

const HomeAppBar({super.key, this.onMenuPressed});

@override
Widget build(BuildContext context) {
return Material(
color: Theme.of(context).scaffoldBackgroundColor,
child: Container(
alignment: Alignment.bottomLeft,
child: Padding(
padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Hero(
tag: 'search_back',
child: Material(
color: Colors.transparent,
child: InkWell(
borderRadius: const BorderRadius.all(Radius.circular(50)),
onTap: onMenuPressed,
child: Ink(
width: 45,
height: 45,
decoration: ShapeDecoration(
color: context.theme.cardColor,
shape: const CircleBorder(),
),
child: const Icon(LazaIcons.menu_horizontal, size: 13),
),
),
),
),
InkWell(
borderRadius: const BorderRadius.all(Radius.circular(50)),
onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
},
child: Ink(
width: 45,
height: 45,
decoration: ShapeDecoration(
color: context.theme.cardColor,
shape: const CircleBorder(),
),
child: const Icon(LazaIcons.bag),
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

class BrandTile extends StatelessWidget {
const BrandTile({super.key, required this.brand, this.onTap});
final Brand brand;
final void Function()? onTap;

@override
Widget build(BuildContext context) {
return InkWell(
onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BrandProductsScreen(brand: brand))),
borderRadius: const BorderRadius.all(Radius.circular(10.0)),
child: Ink(
height: 50,
width: 115,
decoration: BoxDecoration(
color: context.theme.cardColor,
borderRadius: const BorderRadius.all(Radius.circular(10.0)),
),
child: Row(
children: [
Container(
height: 40,
width: 40,
margin: const EdgeInsets.all(5),
decoration: BoxDecoration(
color: context.theme.scaffoldBackgroundColor,
borderRadius: const BorderRadius.all(Radius.circular(10.0)),
),
child: Icon(
brand.iconData,
size: brand.name == 'Fila' ? 12 : 18,
),
),
Expanded(
child: Text(
brand.name,
style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
textAlign: TextAlign.center,
),
),
],
),
),
);
}
}
