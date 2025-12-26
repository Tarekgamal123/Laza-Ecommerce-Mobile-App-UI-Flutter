
import 'package:flutter/material.dart';
import 'package:laza/components/colors.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:laza/providers/auth_provider.dart' as laza_auth; // ADD ALIAS
import 'package:laza/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
const ProfileScreen({super.key});

@override
Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser;
final userName = user?.displayName ?? 'User';
final userEmail = user?.email ?? 'No email available';
final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

return Scaffold(
appBar: AppBar(
title: Text('Profile', style: context.headlineSmall),
centerTitle: false,
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Profile Header
_buildProfileHeader(context, userName, userEmail, initials),
const SizedBox(height: 30),

// Account Section
Text('Account', style: context.bodyLargeW600),
const SizedBox(height: 15),
_buildSettingItem(
context,
icon: Icons.person_outline,
title: 'Personal Information',
subtitle: 'Update your personal details',
onTap: () => _showComingSoon(context),
),
_buildSettingItem(
context,
icon: Icons.shopping_bag_outlined,
title: 'My Orders',
subtitle: 'Track and view your orders',
onTap: () => _showComingSoon(context),
),
_buildSettingItem(
context,
icon: Icons.location_on_outlined,
title: 'Shipping Address',
subtitle: 'Manage your delivery addresses',
onTap: () => _showComingSoon(context),
),
_buildSettingItem(
context,
icon: Icons.credit_card_outlined,
title: 'Payment Methods',
subtitle: 'Add or remove payment methods',
onTap: () => _showComingSoon(context),
),

const SizedBox(height: 30),

// App Section
Text('App', style: context.bodyLargeW600),
const SizedBox(height: 15),
_buildSettingItem(
context,
icon: Icons.notifications_outlined,
title: 'Notifications',
subtitle: 'Manage your notifications',
onTap: () => _showComingSoon(context),
),
_buildSettingItem(
context,
icon: Icons.security_outlined,
title: 'Privacy & Security',
subtitle: 'Manage your privacy settings',
onTap: () => _showComingSoon(context),
),
_buildSettingItem(
context,
icon: Icons.help_outline,
title: 'Help & Support',
subtitle: 'Get help or contact support',
onTap: () => _showComingSoon(context),
),
_buildSettingItem(
context,
icon: Icons.info_outline,
title: 'About',
subtitle: 'Learn more about Laza',
onTap: () => _showAboutDialog(context),
),

const SizedBox(height: 40),

// Logout Button
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () => _showLogoutDialog(context),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red.withOpacity(0.1),
foregroundColor: Colors.red,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
padding: const EdgeInsets.symmetric(vertical: 16),
),
child: Text(
'Logout',
style: context.bodyLarge?.copyWith(
color: Colors.red,
fontWeight: FontWeight.w600,
),
),
),
),

const SizedBox(height: 20),

// App Version
Center(
child: Text(
'Laza E-commerce v1.0.0',
style: context.bodySmall?.copyWith(
color: ColorConstant.manatee,
),
),
),
],
),
),
),
);
}

Widget _buildProfileHeader(
BuildContext context,
String userName,
String userEmail,
String initials,
) {
return Row(
children: [
// Profile Avatar
CircleAvatar(
radius: 40,
backgroundColor: ColorConstant.primary,
child: Text(
initials,
style: const TextStyle(
fontSize: 32,
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(width: 20),

// User Info
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
userName,
style: context.headlineSmall?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 5),
Text(
userEmail,
style: context.bodyMedium?.copyWith(
color: ColorConstant.manatee,
),
overflow: TextOverflow.ellipsis,
maxLines: 2,
),
const SizedBox(height: 10),
OutlinedButton(
onPressed: () => _showComingSoon(context),
style: OutlinedButton.styleFrom(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
side: BorderSide(color: ColorConstant.primary),
),
child: Text(
'Edit Profile',
style: context.bodySmall?.copyWith(
color: ColorConstant.primary,
),
),
),
],
),
),
],
);
}

Widget _buildSettingItem(
BuildContext context, {
required IconData icon,
required String title,
required String subtitle,
required VoidCallback onTap,
}) {
return ListTile(
onTap: onTap,
leading: Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: ColorConstant.primary.withOpacity(0.1),
shape: BoxShape.circle,
),
child: Icon(icon, color: ColorConstant.primary, size: 20),
),
title: Text(title, style: context.bodyMediumW500),
subtitle: Text(
subtitle,
style: context.bodySmall?.copyWith(color: ColorConstant.manatee),
),
trailing: const Icon(Icons.chevron_right, color: Colors.grey),
contentPadding: const EdgeInsets.symmetric(vertical: 8),
);
}

void _showComingSoon(BuildContext context) {
Fluttertoast.showToast(
msg: 'Coming soon!',
toastLength: Toast.LENGTH_SHORT,
gravity: ToastGravity.BOTTOM,
);
}

void _showAboutDialog(BuildContext context) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('About Laza'),
content: const Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Laza E-commerce Mobile App'),
SizedBox(height: 10),
Text('Version: 1.0.0'),
SizedBox(height: 10),
Text(
'A modern e-commerce app built with Flutter and Firebase.',
style: TextStyle(fontSize: 14),
),
],
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Close'),
),
],
),
);
}

void _showLogoutDialog(BuildContext context) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Logout'),
content: const Text('Are you sure you want to logout?'),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancel'),
),
TextButton(
onPressed: () {
Navigator.pop(context); // Close dialog
_performLogout(context);
},
child: const Text(
'Logout',
style: TextStyle(color: Colors.red),
),
),
],
),
);
}

void _performLogout(BuildContext context) async {
final authProvider = Provider.of<laza_auth.AuthProvider>(context, listen: false); // USE ALIAS

try {
await authProvider.logout();

// Navigate to login screen and clear navigation stack
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => const SignInScreen()),
(route) => false,
);

Fluttertoast.showToast(
msg: 'Logged out successfully',
toastLength: Toast.LENGTH_SHORT,
gravity: ToastGravity.BOTTOM,
);
} catch (e) {
Fluttertoast.showToast(
msg: 'Error logging out: $e',
toastLength: Toast.LENGTH_SHORT,
gravity: ToastGravity.BOTTOM,
);
}
}
}
