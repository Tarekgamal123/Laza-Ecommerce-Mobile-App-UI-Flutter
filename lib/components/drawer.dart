
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/profile_screen.dart';
import 'package:laza/theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'package:laza/providers/auth_provider.dart' as laza_auth;
import 'package:laza/sign_in_screen.dart';

class DrawerWidget extends StatelessWidget {
const DrawerWidget({super.key});

@override
Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser;
final userName = user?.displayName ?? 'User';
final userEmail = user?.email ?? 'No email';
final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

return Drawer(
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
child: SafeArea(
bottom: false,
child: Column(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Close button - FIXED: Use a different approach
Padding(
padding: const EdgeInsets.only(left: 20.0, top: 5),
child: GestureDetector(
onTap: () {
// Close the drawer using Navigator
if (Navigator.canPop(context)) {
Navigator.pop(context);
}
},
child: Container(
width: 45,
height: 45,
decoration: ShapeDecoration(
color: context.theme.cardColor,
shape: const CircleBorder(),
),
child: const Icon(Icons.close),
),
),
),
const SizedBox(height: 30.0),

// User Profile Section
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Flexible(
child: GestureDetector(
onTap: () {
Navigator.pop(context); // Close drawer first
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ProfileScreen(),
),
);
},
child: Row(
children: [
CircleAvatar(
maxRadius: 24,
backgroundColor: ColorConstant.primary,
child: Text(
initials,
style: const TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(width: 10.0),
Flexible(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
userName,
style: context.bodyLargeW500,
overflow: TextOverflow.ellipsis,
),
Row(
children: [
Flexible(
child: Text(
userEmail,
style: context.bodySmall?.copyWith(
color: ColorConstant.manatee,
),
overflow: TextOverflow.ellipsis,
),
),
const SizedBox(width: 5.0),
const Icon(
Icons.verified,
size: 15,
color: Colors.green,
)
],
),
],
),
),
],
),
),
),
Container(
padding: const EdgeInsets.all(10.0),
decoration: BoxDecoration(
color: context.theme.cardColor,
borderRadius: const BorderRadius.all(Radius.circular(5.0))
),
child: Text(
'Profile',
style: TextStyle(color: ColorConstant.manatee),
),
)
],
),
),
const SizedBox(height: 30.0),

// Drawer Menu Items
Consumer<ThemeNotifier>(
builder: (context, themeNotifier, _) {
IconData iconData = Icons.brightness_auto;
switch (themeNotifier.themeMode) {
case ThemeMode.system:
iconData = Icons.brightness_auto_outlined;
case ThemeMode.light:
iconData = Icons.light_mode_outlined;
case ThemeMode.dark:
iconData = Icons.dark_mode_outlined;
}
return ListTile(
leading: Icon(iconData),
onTap: () async {
Navigator.pop(context); // Close drawer first
await showModalActionSheet(
context: context,
title: 'Choose app appearance',
actions: <SheetAction<ThemeMode>>[
const SheetAction(label: 'Automatic (follow system)', key: ThemeMode.system),
const SheetAction(label: 'Light', key: ThemeMode.light),
const SheetAction(label: 'Dark', key: ThemeMode.dark),
],
).then((result) {
if (result == null) return;
themeNotifier.toggleTheme(result);
});
},
contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
title: const Text('Appearance'),
horizontalTitleGap: 10.0,
);
},
),

// Profile Menu Item
ListTile(
leading: const Icon(Icons.person_outline),
onTap: () {
Navigator.pop(context); // Close drawer first
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ProfileScreen(),
),
);
},
contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
title: const Text('My Profile'),
horizontalTitleGap: 10.0,
),

ListTile(
leading: const Icon(Icons.info_outline),
onTap: () {
Navigator.pop(context); // Close drawer first
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ProfileScreen(),
),
);
},
contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
title: const Text('Account Information'),
horizontalTitleGap: 10.0,
),

ListTile(
leading: const Icon(Icons.lock_outline),
onTap: () {
Navigator.pop(context); // Close drawer first
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ProfileScreen(),
),
);
},
contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
title: const Text('Password'),
horizontalTitleGap: 10.0,
),

ListTile(
leading: const Icon(Icons.shopping_bag_outlined),
onTap: () {
Navigator.pop(context); // Close drawer
// TODO: Navigate to Orders screen
},
contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
title: const Text('My Orders'),
horizontalTitleGap: 10.0,
),

ListTile(
leading: const Icon(Icons.credit_card_outlined),
onTap: () {
Navigator.pop(context); // Close drawer
// Already in My Cards screen via bottom nav
},
contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
title: const Text('My Cards'),
horizontalTitleGap: 10.0,
),

ListTile(
leading: const Icon(Icons.favorite_border),
onTap: () {
Navigator.pop(context); // Close drawer
// Already in Wishlist screen via bottom nav
},
contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
title: const Text('Wishlist'),
horizontalTitleGap: 10.0,
),

ListTile(
leading: const Icon(Icons.settings_outlined),
onTap: () {
Navigator.pop(context); // Close drawer first
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ProfileScreen(),
),
);
},
contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
title: const Text('Settings'),
horizontalTitleGap: 10.0,
),
],
),

// Logout Section
Column(
children: [
ListTile(
leading: const Icon(Icons.logout, color: Colors.red),
onTap: () async {
Navigator.pop(context); // Close drawer first
await showOkCancelAlertDialog(
context: context,
title: 'Confirm Logout',
message: 'Are you sure you want to logout?',
isDestructiveAction: true,
okLabel: 'Logout',
).then((result) async {
if (result == OkCancelResult.ok && context.mounted) {
try {
final authProvider = Provider.of<laza_auth.AuthProvider>(context, listen: false);
await authProvider.logout();

Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => const SignInScreen()),
(Route<dynamic> route) => false,
);
} catch (e) {
// Show error if logout fails
if (context.mounted) {
await showOkAlertDialog(
context: context,
title: 'Logout Error',
message: 'Failed to logout: $e',
);
}
}
}
});
},
contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
title: const Text(
'Logout',
style: TextStyle(color: Colors.red),
),
horizontalTitleGap: 10.0,
),
const SizedBox(height: 30.0),

// App Info Footer
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Laza E-commerce',
style: context.bodySmall?.copyWith(
color: ColorConstant.manatee,
),
),
Text(
'Version 1.0.0',
style: context.bodySmall?.copyWith(
color: ColorConstant.manatee,
fontSize: 12,
),
),
const SizedBox(height: 20.0),
],
),
),
],
),
],
),
),
);
}
}
