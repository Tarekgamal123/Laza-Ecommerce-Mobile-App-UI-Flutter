
import 'package:flutter/material.dart';
import 'package:laza/components/colors.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/product_details.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'components/laza_icons.dart';
import 'components/product_card.dart';
import 'models/product.dart';
import 'providers/favorites_provider.dart';

class WishlistScreen extends StatefulWidget {
const WishlistScreen({super.key});

@override
State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
@override
void initState() {
super.initState();
// Load favorites when screen opens
WidgetsBinding.instance.addPostFrameCallback((_) {
Provider.of<FavoritesProvider>(context, listen: false).loadFavorites();
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('Wishlist', style: context.headlineSmall),
centerTitle: false,
actions: [
Consumer<FavoritesProvider>(
builder: (context, favoritesProvider, child) {
if (favoritesProvider.favorites.isEmpty) return const SizedBox();
return IconButton(
onPressed: () {
_showClearFavoritesDialog(context, favoritesProvider);
},
icon: const Icon(Icons.delete_outline),
tooltip: 'Clear All',
);
},
),
],
),
body: Consumer<FavoritesProvider>(
builder: (context, favoritesProvider, child) {
if (favoritesProvider.isLoading) {
return const Center(child: CircularProgressIndicator());
}

if (favoritesProvider.favorites.isEmpty) {
return _buildEmptyWishlist();
}

return Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: GridView.builder(
itemCount: favoritesProvider.favorites.length,
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
mainAxisExtent: 250,
crossAxisSpacing: 15.0,
mainAxisSpacing: 15.0,
),
itemBuilder: (context, index) {
final product = favoritesProvider.favorites[index];
return _buildFavoriteProductCard(context, product, favoritesProvider);
},
),
);
},
),
);
}

Widget _buildEmptyWishlist() {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
LazaIcons.heart,
size: 100,
color: ColorConstant.manatee.withOpacity(0.3),
),
const SizedBox(height: 20),
Text(
'Your wishlist is empty',
style: context.headlineSmall?.copyWith(color: ColorConstant.manatee),
),
const SizedBox(height: 10),
Text(
'Add products you love',
style: context.bodyMedium?.copyWith(color: ColorConstant.manatee),
),
const SizedBox(height: 30),
ElevatedButton(
onPressed: () {
Navigator.pop(context); // Go back to home
},
style: ElevatedButton.styleFrom(
backgroundColor: ColorConstant.primary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
),
child: Text(
'Start Shopping',
style: context.bodyMedium?.copyWith(color: Colors.white),
),
),
],
),
);
}

Widget _buildFavoriteProductCard(
BuildContext context,
Product product,
FavoritesProvider favoritesProvider,
) {
return Stack(
children: [
ProductCard(product: product),
// Remove from favorites button
Positioned(
top: 8,
right: 8,
child: Material(
color: Colors.transparent,
child: InkWell(
borderRadius: const BorderRadius.all(Radius.circular(50)),
onTap: () {
favoritesProvider.removeFromFavorites(product.id);
Fluttertoast.showToast(msg: 'Removed from favorites');
},
child: Container(
width: 35,
height: 35,
decoration: BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.1),
blurRadius: 4,
offset: const Offset(0, 2),
),
],
),
child: Icon(
LazaIcons.heart,
color: Colors.red,
size: 16,
),
),
),
),
),
],
);
}

void _showClearFavoritesDialog(
BuildContext context,
FavoritesProvider favoritesProvider,
) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Clear Wishlist'),
content: const Text('Are you sure you want to remove all items from your wishlist?'),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancel'),
),
TextButton(
onPressed: () {
favoritesProvider.clearFavorites();
Navigator.pop(context);
Fluttertoast.showToast(msg: 'Wishlist cleared');
},
child: const Text('Clear', style: TextStyle(color: Colors.red)),
),
],
),
);
}
}
