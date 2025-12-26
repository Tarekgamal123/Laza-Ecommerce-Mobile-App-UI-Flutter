
import 'package:flutter/material.dart';
import 'package:laza/components/bottom_nav_button.dart';
import 'package:laza/components/colors.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/models/product.dart';
import 'package:laza/reviews_screen.dart';
import 'package:laza/theme.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'cart_screen.dart';
import 'components/laza_icons.dart';
import 'package:laza/providers/cart_provider.dart';       // ADD THIS
import 'package:laza/providers/favorites_provider.dart'; // ADD THIS

class ProductDetailsScreen extends StatefulWidget {
const ProductDetailsScreen({super.key, required this.product});
final Product product;

@override
State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
late String selectedImage;

@override
void initState() {
selectedImage = widget.product.image;
super.initState();
}

@override
Widget build(BuildContext context) {
final product = widget.product;
final bottomPadding = context.bottomViewPadding == 0.0 ? 30.0 : context.bottomViewPadding;

return Scaffold(
bottomNavigationBar: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Divider(height: 0),
Container(
color: context.theme.scaffoldBackgroundColor,
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Total Price', style: context.bodyMediumW600),
Text('with VAT,SD', style: context.bodyExtraSmall?.copyWith(color: ColorConstant.manatee)),
],
),
Text(product.price, style: context.bodyLargeW600),
],
),
),
Consumer<CartProvider>(
builder: (context, cartProvider, child) {
final isInCart = cartProvider.isInCart(product.id);
return BottomNavButton(
label: isInCart ? 'Already in Cart' : 'Add to Cart',
onTap: () {
if (!isInCart) {
cartProvider.addToCart(product);
Fluttertoast.showToast(
msg: 'Added to cart successfully!',
toastLength: Toast.LENGTH_SHORT,
gravity: ToastGravity.BOTTOM,
);
} else {
Fluttertoast.showToast(
msg: 'Product already in cart',
toastLength: Toast.LENGTH_SHORT,
gravity: ToastGravity.BOTTOM,
);
}
},
);
},
),
],
),
body: CustomScrollView(
slivers: [
SliverAppBar(
leadingWidth: 0,
leading: const SizedBox.shrink(),
title: InkWell(
borderRadius: BorderRadius.circular(56),
onTap: () => Navigator.pop(context),
child: Ink(
width: 45,
height: 45,
decoration: ShapeDecoration(
color: AppTheme.lightTheme.cardColor,
shape: const CircleBorder(),
),
child: const Icon(Icons.arrow_back_outlined),
),
),
centerTitle: false,
pinned: true,
actions: [
Consumer<FavoritesProvider>(
builder: (context, favoritesProvider, child) {
final isFavorite = favoritesProvider.isFavorite(product.id);
return InkWell(
borderRadius: const BorderRadius.all(Radius.circular(50)),
onTap: () {
favoritesProvider.toggleFavorite(product);
},
child: Ink(
width: 45,
height: 45,
decoration: ShapeDecoration(
color: AppTheme.lightTheme.cardColor,
shape: const CircleBorder(),
),
child: Icon(
LazaIcons.heart,
color: isFavorite ? Colors.red : ColorConstant.manatee,
),
),
);
},
),
Padding(
padding: const EdgeInsets.only(right: 20.0, left: 10.0),
child: InkWell(
borderRadius: const BorderRadius.all(Radius.circular(50)),
onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
child: Ink(
width: 45,
height: 45,
decoration: ShapeDecoration(
color: AppTheme.lightTheme.cardColor,
shape: const CircleBorder(),
),
child: const Icon(LazaIcons.bag),
),
),
),
],
backgroundColor: const Color(0xffF2F2F2),
surfaceTintColor: Colors.transparent,
expandedHeight: 400,
flexibleSpace: FlexibleSpaceBar(
background: SafeArea(
child: Image.network(
selectedImage,
fit: BoxFit.fitHeight,
loadingBuilder: (context, child, loadingProgress) {
if (loadingProgress == null) return child;
return const Center(child: CircularProgressIndicator());
},
errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
),
),
),
systemOverlayStyle: context.theme.appBarTheme.systemOverlayStyle!.copyWith(
statusBarIconBrightness: Brightness.dark,
statusBarBrightness: Brightness.light,
),
),
const SliverToBoxAdapter(child: SizedBox(height: 20)),
SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Flexible(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Category Placeholder', style: context.bodySmall),
const SizedBox(height: 5.0),
Text(
product.title,
style: context.headlineSmall,
),
],
),
),
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Price', style: context.bodySmall),
const SizedBox(height: 5.0),
Text(
product.price,
style: context.headlineSmall,
),
],
),
],
),
),
),
const SliverToBoxAdapter(child: SizedBox(height: 20)),
// Thumbnail selector
if (product.images.isNotEmpty)
SliverToBoxAdapter(
child: SizedBox(
height: 80,
width: double.infinity,
child: ListView.separated(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
physics: const BouncingScrollPhysics(),
scrollDirection: Axis.horizontal,
itemBuilder: (context, index) {
final image = product.images[index];
return InkWell(
onTap: () => setState(() => selectedImage = image),
child: Ink(
height: double.infinity,
width: 80,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(10),
border: Border.all(
color: selectedImage == image ? ColorConstant.primary : Colors.transparent,
width: 2,
),
image: DecorationImage(
image: NetworkImage(image),
fit: BoxFit.cover,
),
),
),
);
},
separatorBuilder: (_, __) => const SizedBox(width: 10.0),
itemCount: product.images.length,
),
),
),
const SliverToBoxAdapter(child: SizedBox(height: 20)),
// Description
SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Description', style: context.bodyLargeW600),
const SizedBox(height: 10.0),
Text(
product.description.isEmpty ? 'No description available' : product.description,
style: context.bodyMedium?.copyWith(color: ColorConstant.manatee),
),
const SizedBox(height: 20.0),
],
),
),
),
// Reviews
SliverToBoxAdapter(
child: Column(
children: [
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Reviews', style: context.bodyLargeW600),
TextButton(
onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewsScreen())),
child: const Text('View All'),
),
],
),
),
const Padding(
padding: EdgeInsets.symmetric(horizontal: 20.0),
child: ReviewCard(),
),
],
),
),
SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
],
),
);
}
}

class ReviewCard extends StatelessWidget {
const ReviewCard({super.key});

@override
Widget build(BuildContext context) {
return Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Row(
children: [
const CircleAvatar(),
const SizedBox(width: 10.0),
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Ronald Richards', style: context.bodyMediumW500),
const SizedBox(height: 5.0),
Row(
children: [
Icon(LazaIcons.clock, color: ColorConstant.manatee, size: 18),
const SizedBox(width: 5.0),
Text(
'13 Sep, 2020',
style: context.bodyExtraSmall?.copyWith(color: ColorConstant.manatee),
)
],
)
],
),
],
),
Column(
children: [
Row(
children: [
Text('4.8', style: context.bodyMediumW500),
Text(' rating', style: context.bodyExtraSmall?.copyWith(color: ColorConstant.manatee))
],
),
const SizedBox(height: 5.0),
Row(
children: [
const Icon(Icons.star, size: 14, color: Color(0xffFF981F)),
const Icon(Icons.star, size: 14, color: Color(0xffFF981F)),
const Icon(Icons.star, size: 14, color: Color(0xffFF981F)),
Icon(Icons.star_border, size: 14, color: ColorConstant.manatee),
Icon(Icons.star_border, size: 14, color: ColorConstant.manatee)
],
),
],
),
],
),
const SizedBox(height: 10.0),
const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque malesuada eget vitae amet...')
],
);
}
}
