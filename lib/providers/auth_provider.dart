
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
bool _isLoading = false;
String? _errorMessage;

bool get isLoading => _isLoading;
String? get errorMessage => _errorMessage;

// Check if user is logged in
Future<bool> isUserLoggedIn() async {
final prefs = await SharedPreferences.getInstance();
final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

// Also check Firebase Auth state for consistency
final firebaseUser = FirebaseAuth.instance.currentUser;

return isLoggedIn && firebaseUser != null;
}

// Get current user email
Future<String?> getUserEmail() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getString('userEmail');
}

// Login with email and password
Future<bool> login(String email, String password) async {
try {
_isLoading = true;
_errorMessage = null;
notifyListeners();

// Sign in with Firebase Auth
final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
email: email.trim(),
password: password,
);

// Save login state
await _saveLoginState(email);

_isLoading = false;
notifyListeners();
return true;

} on FirebaseAuthException catch (e) {
_isLoading = false;

// Handle specific Firebase errors
switch (e.code) {
case 'user-not-found':
_errorMessage = 'No user found with this email';
break;
case 'wrong-password':
_errorMessage = 'Incorrect password';
break;
case 'invalid-email':
_errorMessage = 'Invalid email address';
break;
case 'user-disabled':
_errorMessage = 'This account has been disabled';
break;
case 'too-many-requests':
_errorMessage = 'Too many attempts. Try again later';
break;
default:
_errorMessage = 'Login failed: ${e.message}';
}

notifyListeners();
return false;

} catch (e) {
_isLoading = false;
_errorMessage = 'An unexpected error occurred';
notifyListeners();
return false;
}
}

// Signup with email, password, and username
Future<bool> signup(String email, String password, String username) async {
try {
_isLoading = true;
_errorMessage = null;
notifyListeners();

// Create user with email/password
UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
email: email.trim(),
password: password,
);

// Update display name
await credential.user?.updateDisplayName(username);

// Save user data to Firestore
await FirebaseFirestore.instance
    .collection('users')
    .doc(credential.user!.uid)
    .set({
'email': email,
'username': username,
'createdAt': FieldValue.serverTimestamp(),
});

// Sign out immediately after signup (for security - user must sign in)
await FirebaseAuth.instance.signOut();

// Clear login state since we signed out
final prefs = await SharedPreferences.getInstance();
await prefs.remove('isLoggedIn');
await prefs.remove('userEmail');

_isLoading = false;
notifyListeners();
return true;

} on FirebaseAuthException catch (e) {
_isLoading = false;

// Handle specific Firebase errors
switch (e.code) {
case 'email-already-in-use':
_errorMessage = 'Email already in use';
break;
case 'weak-password':
_errorMessage = 'Password is too weak (min 6 characters)';
break;
case 'invalid-email':
_errorMessage = 'Invalid email address';
break;
case 'operation-not-allowed':
_errorMessage = 'Email/password accounts are not enabled';
break;
default:
_errorMessage = 'Signup failed: ${e.message}';
}

notifyListeners();
return false;

} catch (e) {
_isLoading = false;
_errorMessage = 'Signup failed: $e';
notifyListeners();
return false;
}
}

// Reset password
Future<bool> resetPassword(String email) async {
try {
_isLoading = true;
_errorMessage = null;
notifyListeners();

await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

_isLoading = false;
notifyListeners();
return true;

} on FirebaseAuthException catch (e) {
_isLoading = false;

switch (e.code) {
case 'user-not-found':
_errorMessage = 'No user found with this email';
break;
case 'invalid-email':
_errorMessage = 'Invalid email address';
break;
default:
_errorMessage = 'Failed to send reset email: ${e.message}';
}

notifyListeners();
return false;

} catch (e) {
_isLoading = false;
_errorMessage = 'Failed to send reset email: $e';
notifyListeners();
return false;
}
}

// Logout
Future<void> logout() async {
try {
_isLoading = true;
notifyListeners();

// Sign out from Firebase
await FirebaseAuth.instance.signOut();

// Clear local storage
await _clearLoginState();

_isLoading = false;
notifyListeners();

} catch (e) {
_isLoading = false;
if (kDebugMode) {
print('Logout error: $e');
}
// Even if there's an error, clear local state
await _clearLoginState();
notifyListeners();
}
}

// Get current user from Firebase
User? getCurrentUser() {
return FirebaseAuth.instance.currentUser;
}

// Get user display name or email for greeting
String getUserGreeting() {
final user = getCurrentUser();
if (user == null) return 'Hello';

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

return 'Hello';
}

// Check auth status for splash screen - ADD THIS METHOD
Future<bool> checkAuthStatus() async {
try {
// Check SharedPreferences
final prefs = await SharedPreferences.getInstance();
final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

if (!isLoggedIn) return false;

// Verify Firebase session is still valid
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
await _clearLoginState();
return false;
}

// Try to refresh token to ensure it's valid
try {
await user.getIdToken(true);
return true;
} catch (e) {
// Token invalid, clear local state
await _clearLoginState();
return false;
}

} catch (e) {
if (kDebugMode) {
print('Error checking auth status: $e');
}
return false;
}
}

// Private helper methods
Future<void> _saveLoginState(String email) async {
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('isLoggedIn', true);
await prefs.setString('userEmail', email);
}

Future<void> _clearLoginState() async {
final prefs = await SharedPreferences.getInstance();
await prefs.remove('isLoggedIn');
await prefs.remove('userEmail');
}

// Clear error message
void clearError() {
_errorMessage = null;
notifyListeners();
}
}
