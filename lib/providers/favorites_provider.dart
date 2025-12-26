
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:laza/models/product.dart';

class FavoritesProvider with ChangeNotifier {
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

List<Product> _favorites = [];
bool _isLoading = false;

List<Product> get favorites => _favorites;
bool get isLoading => _isLoading;
int get count => _favorites.length;

// Load favorites from Firestore
Future<void> loadFavorites() async {
if (_auth.currentUser == null) return;

_isLoading = true;
notifyListeners();

try {
final querySnapshot = await _firestore
    .collection('favorites')
    .doc(_auth.currentUser!.uid)
    .collection('items')
    .orderBy('addedAt', descending: true)
    .get();

_favorites = querySnapshot.docs.map((doc) {
final data = doc.data();
return Product(
id: data['productId'],
title: data['title'],
price: data['price'],
description: data['description'] ?? '',
image: data['image'],
images: data['images'] != null ? List<String>.from(data['images']) : [],
);
}).toList();

notifyListeners();
} catch (e) {
if (kDebugMode) {
print('Error loading favorites: $e');
}
} finally {
_isLoading = false;
notifyListeners();
}
}

// Add to favorites
Future<void> addToFavorites(Product product) async {
if (_auth.currentUser == null) return;

if (!_favorites.any((p) => p.id == product.id)) {
_favorites.add(product);
notifyListeners();

try {
await _firestore
    .collection('favorites')
    .doc(_auth.currentUser!.uid)
    .collection('items')
    .doc(product.id.toString())
    .set({
'productId': product.id,
'title': product.title,
'price': product.price,
'description': product.description,
'image': product.image,
'images': product.images,
'addedAt': FieldValue.serverTimestamp(),
});
} catch (e) {
if (kDebugMode) {
print('Error adding to favorites: $e');
}
// Rollback on error
_favorites.removeWhere((p) => p.id == product.id);
notifyListeners();
}
}
}

// Remove from favorites
Future<void> removeFromFavorites(int productId) async {
if (_auth.currentUser == null) return;

_favorites.removeWhere((product) => product.id == productId);
notifyListeners();

try {
await _firestore
    .collection('favorites')
    .doc(_auth.currentUser!.uid)
    .collection('items')
    .doc(productId.toString())
    .delete();
} catch (e) {
if (kDebugMode) {
print('Error removing from favorites: $e');
}
}
}

// Check if product is favorite
bool isFavorite(int productId) {
return _favorites.any((product) => product.id == productId);
}

// Toggle favorite status
Future<void> toggleFavorite(Product product) async {
if (isFavorite(product.id)) {
await removeFromFavorites(product.id);
} else {
await addToFavorites(product);
}
}

// Clear all favorites
Future<void> clearFavorites() async {
if (_auth.currentUser == null) return;

try {
final querySnapshot = await _firestore
    .collection('favorites')
    .doc(_auth.currentUser!.uid)
    .collection('items')
    .get();

final batch = _firestore.batch();
for (final doc in querySnapshot.docs) {
batch.delete(doc.reference);
}
await batch.commit();

_favorites.clear();
notifyListeners();
} catch (e) {
if (kDebugMode) {
print('Error clearing favorites: $e');
}
}
}
}
