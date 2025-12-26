
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:laza/models/product.dart';

class CartItem {
final Product product;
int quantity;

CartItem({
required this.product,
this.quantity = 1,
});

Map<String, dynamic> toMap() {
return {
'productId': product.id,
'title': product.title,
'price': product.price,
'image': product.image,
'quantity': quantity,
'addedAt': FieldValue.serverTimestamp(),
};
}

double get totalPrice {
// Remove $ sign and convert to double
String priceString = product.price.replaceAll('\$', '');
double price = double.tryParse(priceString) ?? 0.0;
return price * quantity;
}
}

class CartProvider with ChangeNotifier {
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

List<CartItem> _cartItems = [];
bool _isLoading = false;

List<CartItem> get cartItems => _cartItems;
bool get isLoading => _isLoading;

// Calculate total items in cart
int get totalItems {
return _cartItems.fold(0, (sum, item) => sum + item.quantity);
}

// Calculate total price
double get totalPrice {
return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
}

// Format total price with currency
String get formattedTotalPrice {
return '\$${totalPrice.toStringAsFixed(2)}';
}

// Load cart items from Firestore
Future<void> loadCartItems() async {
if (_auth.currentUser == null) return;

_isLoading = true;
notifyListeners();

try {
final querySnapshot = await _firestore
    .collection('carts')
    .doc(_auth.currentUser!.uid)
    .collection('items')
    .get();

_cartItems = querySnapshot.docs.map((doc) {
final data = doc.data();
final product = Product(
id: data['productId'],
title: data['title'],
price: data['price'],
description: '', // Not stored in cart
image: data['image'],
images: [],
);

return CartItem(
product: product,
quantity: data['quantity'] ?? 1,
);
}).toList();

notifyListeners();
} catch (e) {
if (kDebugMode) {
print('Error loading cart: $e');
}
} finally {
_isLoading = false;
notifyListeners();
}
}

// Add item to cart
Future<void> addToCart(Product product, {int quantity = 1}) async {
if (_auth.currentUser == null) return;

// Check if product already in cart
final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

if (existingIndex != -1) {
// Update quantity if already exists
_cartItems[existingIndex].quantity += quantity;
await _updateCartItemInFirestore(product.id, _cartItems[existingIndex].quantity);
} else {
// Add new item
final newItem = CartItem(product: product, quantity: quantity);
_cartItems.add(newItem);
await _addCartItemToFirestore(newItem);
}

notifyListeners();
}

// Remove item from cart
Future<void> removeFromCart(int productId) async {
if (_auth.currentUser == null) return;

_cartItems.removeWhere((item) => item.product.id == productId);

try {
await _firestore
    .collection('carts')
    .doc(_auth.currentUser!.uid)
    .collection('items')
    .doc(productId.toString())
    .delete();
} catch (e) {
if (kDebugMode) {
print('Error removing from cart: $e');
}
}

notifyListeners();
}

// Update item quantity
Future<void> updateQuantity(int productId, int newQuantity) async {
if (_auth.currentUser == null || newQuantity < 1) return;

final itemIndex = _cartItems.indexWhere((item) => item.product.id == productId);

if (itemIndex != -1) {
if (newQuantity == 0) {
await removeFromCart(productId);
} else {
_cartItems[itemIndex].quantity = newQuantity;
await _updateCartItemInFirestore(productId, newQuantity);
}
}

notifyListeners();
}

// Clear entire cart
Future<void> clearCart() async {
if (_auth.currentUser == null) return;

try {
// Delete all items in batch
final querySnapshot = await _firestore
    .collection('carts')
    .doc(_auth.currentUser!.uid)
    .collection('items')
    .get();

final batch = _firestore.batch();
for (final doc in querySnapshot.docs) {
batch.delete(doc.reference);
}
await batch.commit();

_cartItems.clear();
notifyListeners();
} catch (e) {
if (kDebugMode) {
print('Error clearing cart: $e');
}
}
}

// Check if product is in cart
bool isInCart(int productId) {
return _cartItems.any((item) => item.product.id == productId);
}

// Get quantity of a product in cart
int getQuantity(int productId) {
final item = _cartItems.firstWhere(
(item) => item.product.id == productId,
orElse: () => CartItem(product: Product(id: -1, title: '', price: '', description: '', image: ''), quantity: 0),
);
return item.quantity;
}

// Private helper methods
Future<void> _addCartItemToFirestore(CartItem item) async {
try {
await _firestore
    .collection('carts')
    .doc(_auth.currentUser!.uid)
    .collection('items')
    .doc(item.product.id.toString())
    .set(item.toMap());
} catch (e) {
if (kDebugMode) {
print('Error adding to Firestore: $e');
}
}
}

Future<void> _updateCartItemInFirestore(int productId, int quantity) async {
try {
await _firestore
    .collection('carts')
    .doc(_auth.currentUser!.uid)
    .collection('items')
    .doc(productId.toString())
    .update({'quantity': quantity});
} catch (e) {
if (kDebugMode) {
print('Error updating in Firestore: $e');
}
}
}
}
