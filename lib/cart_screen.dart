
import 'package:flutter/material.dart';
import 'package:laza/components/colors.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/order_confirmed_screen.dart';
import 'package:laza/product_details.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'components/laza_icons.dart';
import 'providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
const CartScreen({super.key});

@override
State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
@override
void initState() {
super.initState();
// Load cart items when screen opens
WidgetsBinding.instance.addPostFrameCallback((_) {
Provider.of<CartProvider>(context, listen: false).loadCartItems();
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('My Cart', style: context.headlineSmall),
centerTitle: false,
actions: [
Consumer<CartProvider>(
builder: (context, cartProvider, child) {
if (cartProvider.cartItems.isEmpty) return const SizedBox();
return IconButton(
onPressed: () {
_showClearCartDialog(context, cartProvider);
},
icon: const Icon(Icons.delete_outline),
tooltip: 'Clear Cart',
);
},
),
],
),
body: Consumer<CartProvider>(
builder: (context, cartProvider, child) {
if (cartProvider.isLoading) {
return const Center(child: CircularProgressIndicator());
}

if (cartProvider.cartItems.isEmpty) {
return _buildEmptyCart();
}

return Column(
children: [
Expanded(
child: ListView.builder(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
itemCount: cartProvider.cartItems.length,
itemBuilder: (context, index) {
final item = cartProvider.cartItems[index];
return CartItemCard(item: item);
},
),
),
_buildCheckoutSection(cartProvider),
],
);
},
),
);
}

Widget _buildEmptyCart() {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
LazaIcons.bag,
size: 100,
color: ColorConstant.manatee.withOpacity(0.3),
),
const SizedBox(height: 20),
Text(
'Your cart is empty',
style: context.headlineSmall?.copyWith(color: ColorConstant.manatee),
),
const SizedBox(height: 10),
Text(
'Add items to get started',
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

Widget _buildCheckoutSection(CartProvider cartProvider) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
decoration: BoxDecoration(
color: Theme.of(context).cardColor,
border: Border(top: BorderSide(color: Colors.grey.shade200)),
),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Total items:', style: context.bodyMedium),
Text('${cartProvider.totalItems}', style: context.bodyMediumW600),
],
),
const SizedBox(height: 10),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Subtotal:', style: context.bodyMedium),
Text(cartProvider.formattedTotalPrice, style: context.bodyLargeW600),
],
),
const SizedBox(height: 10),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Delivery:', style: context.bodyMedium),
Text('\$0.00', style: context.bodyMediumW600),
],
),
const SizedBox(height: 15),
Divider(color: Colors.grey.shade300),
const SizedBox(height: 10),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Total:', style: context.headlineSmall),
Text(
cartProvider.formattedTotalPrice,
style: context.headlineSmall?.copyWith(color: ColorConstant.primary),
),
],
),
const SizedBox(height: 20),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
_proceedToCheckout(context, cartProvider);
},
style: ElevatedButton.styleFrom(
backgroundColor: ColorConstant.primary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
padding: const EdgeInsets.symmetric(vertical: 18),
),
child: Text(
'Checkout',
style: context.bodyLarge?.copyWith(
color: Colors.white,
fontWeight: FontWeight.w600,
),
),
),
),
],
),
);
}

void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Clear Cart'),
content: const Text('Are you sure you want to remove all items from your cart?'),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancel'),
),
TextButton(
onPressed: () {
cartProvider.clearCart();
Navigator.pop(context);
Fluttertoast.showToast(msg: 'Cart cleared');
},
child: const Text('Clear', style: TextStyle(color: Colors.red)),
),
],
),
);
}

void _proceedToCheckout(BuildContext context, CartProvider cartProvider) {
if (cartProvider.cartItems.isEmpty) {
Fluttertoast.showToast(msg: 'Your cart is empty');
return;
}

Navigator.push(
context,
MaterialPageRoute(
builder: (context) => OrderConfirmedScreen(
totalPrice: cartProvider.formattedTotalPrice,
onOrderComplete: () {
cartProvider.clearCart();
},
),
),
);
}
}

class CartItemCard extends StatelessWidget {
final CartItem item;

const CartItemCard({super.key, required this.item});

@override
Widget build(BuildContext context) {
final cartProvider = Provider.of<CartProvider>(context, listen: false);

return Container(
margin: const EdgeInsets.only(bottom: 15),
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Theme.of(context).cardColor,
borderRadius: BorderRadius.circular(15),
boxShadow: [
BoxShadow(
color: Colors.grey.withOpacity(0.1),
blurRadius: 10,
offset: const Offset(0, 5),
),
],
),
child: Row(
children: [
// Product Image
InkWell(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => ProductDetailsScreen(product: item.product),
),
);
},
child: ClipRRect(
borderRadius: BorderRadius.circular(10),
child: Image.network(
item.product.image,
width: 80,
height: 80,
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) {
return Container(
width: 80,
height: 80,
color: Colors.grey[200],
child: const Icon(Icons.error),
);
},
),
),
),
const SizedBox(width: 15),
// Product Details
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
item.product.title,
style: context.bodyMediumW600,
maxLines: 2,
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 5),
Text(
item.product.price,
style: context.bodyLargeW600?.copyWith(color: ColorConstant.primary),
),
const SizedBox(height: 10),
// Quantity Controls
Row(
children: [
// Decrease Button
InkWell(
borderRadius: BorderRadius.circular(5),
onTap: () {
if (item.quantity > 1) {
cartProvider.updateQuantity(item.product.id, item.quantity - 1);
} else {
cartProvider.removeFromCart(item.product.id);
}
},
child: Container(
width: 30,
height: 30,
decoration: BoxDecoration(
color: Colors.grey[100],
borderRadius: BorderRadius.circular(5),
),
child: const Icon(Icons.remove, size: 18),
),
),
// Quantity Display
Padding(
padding: const EdgeInsets.symmetric(horizontal: 15),
child: Text(
'${item.quantity}',
style: context.bodyLargeW600,
),
),
// Increase Button
InkWell(
borderRadius: BorderRadius.circular(5),
onTap: () {
cartProvider.updateQuantity(item.product.id, item.quantity + 1);
},
child: Container(
width: 30,
height: 30,
decoration: BoxDecoration(
color: Colors.grey[100],
borderRadius: BorderRadius.circular(5),
),
child: const Icon(Icons.add, size: 18),
),
),
const Spacer(),
// Remove Button
InkWell(
borderRadius: BorderRadius.circular(5),
onTap: () {
cartProvider.removeFromCart(item.product.id);
Fluttertoast.showToast(msg: 'Removed from cart');
},
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
decoration: BoxDecoration(
color: Colors.red.withOpacity(0.1),
borderRadius: BorderRadius.circular(5),
),
child: Text(
'Remove',
style: context.bodySmall?.copyWith(color: Colors.red),
),
),
),
],
),
],
),
),
],
),
);
}
}
