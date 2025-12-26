
import 'package:flutter/material.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/models/product.dart';
import 'package:laza/product_details.dart';
import 'package:laza/theme.dart';
import 'package:provider/provider.dart';
import 'colors.dart';
import 'laza_icons.dart';
import 'package:laza/providers/favorites_provider.dart';

class ProductCard extends StatelessWidget {
const ProductCard({
super.key,
required this.product,
});

final Product product;

@override
Widget build(BuildContext context) {
return InkWell(
borderRadius: const BorderRadius.all(Radius.circular(10.0)),
onTap: () => Navigator.push(
context,
MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
),
child: Ink(
height: 250,
child: Stack(
children: [
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: <Widget>[
// IMAGE SECTION
Container(
height: 150,
width: double.infinity,
decoration: BoxDecoration(
borderRadius: const BorderRadius.only(
topLeft: Radius.circular(10),
topRight: Radius.circular(10),
),
color: Colors.grey[200],
),
child: ClipRRect(
borderRadius: const BorderRadius.only(
topLeft: Radius.circular(10),
topRight: Radius.circular(10),
),
child: Image.network(
product.image,
fit: BoxFit.cover,
loadingBuilder: (context, child, loadingProgress) {
if (loadingProgress == null) return child;
return Center(
child: CircularProgressIndicator(
value: loadingProgress.expectedTotalBytes != null
? loadingProgress.cumulativeBytesLoaded /
loadingProgress.expectedTotalBytes!
    : null,
),
);
},
errorBuilder: (context, error, stackTrace) {
return Container(
color: Colors.grey[200],
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.error, color: Colors.grey[500]),
const SizedBox(height: 8),
Text(
'Image failed to load',
style: TextStyle(
fontSize: 10,
color: Colors.grey[500],
),
),
],
),
);
},
),
),
),
const SizedBox(height: 10.0),
// TITLE AND PRICE SECTION
Padding(
padding: const EdgeInsets.symmetric(horizontal: 8.0),
child: SizedBox(
height: 90,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Flexible(
child: Text(
product.title,
style: context.bodyMedium?.copyWith(
fontWeight: FontWeight.w500,
overflow: TextOverflow.ellipsis,
),
maxLines: 2,
),
),
const SizedBox(height: 4),
Text(
product.price,
style: context.bodyLarge?.copyWith(
fontWeight: FontWeight.bold,
color: Theme.of(context).colorScheme.primary,
),
),
],
),
),
),
],
),
// FAVORITE ICON - Positioned OVER the image
Positioned(
top: 8,
right: 8,
child: Consumer<FavoritesProvider>(
builder: (context, favoritesProvider, child) {
final isFavorite = favoritesProvider.isFavorite(product.id);
return Material(
color: Colors.transparent,
child: InkWell(
borderRadius: const BorderRadius.all(Radius.circular(50)),
onTap: () {
favoritesProvider.toggleFavorite(product);
},
child: Container(
width: 35,
height: 35,
decoration: BoxDecoration(
color: AppTheme.lightTheme.cardColor,
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
color: isFavorite ? Colors.red : ColorConstant.manatee,
size: 16,
),
),
),
);
},
),
),
],
),
),
);
}
}
