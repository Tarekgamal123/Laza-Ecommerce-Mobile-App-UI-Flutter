
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // CHANGED FROM system.dart
import 'package:fluttertoast/fluttertoast.dart';
import 'package:laza/components/custom_appbar.dart';
import 'package:laza/components/custom_text_field.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/providers/auth_provider.dart' as laza_auth;
import 'package:provider/provider.dart';

import 'components/bottom_nav_button.dart';
import 'components/colors.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
const SignUpScreen({super.key});

@override
State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
final formKey = GlobalKey<FormState>();
final usernameCtrl = TextEditingController();
final emailCtrl = TextEditingController();
final passwordCtrl = TextEditingController();
final confirmPasswordCtrl = TextEditingController();
bool agreeToTerms = false;

@override
void dispose() {
usernameCtrl.dispose();
emailCtrl.dispose();
passwordCtrl.dispose();
confirmPasswordCtrl.dispose();
super.dispose();
}

Future<void> _handleSignup(BuildContext context) async {
if (!formKey.currentState!.validate()) return;

if (!agreeToTerms) {
Fluttertoast.showToast(msg: 'Please agree to Terms and Conditions');
return;
}

if (passwordCtrl.text != confirmPasswordCtrl.text) {
Fluttertoast.showToast(msg: 'Passwords do not match');
return;
}

final auth = Provider.of<laza_auth.AuthProvider>(context, listen: false);

try {
bool success = await auth.signup(
emailCtrl.text.trim(),
passwordCtrl.text,
usernameCtrl.text.trim(),
);

if (success && mounted) {
Fluttertoast.showToast(
msg: 'Account created successfully! Please sign in.',
toastLength: Toast.LENGTH_LONG,
);

Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => const SignInScreen()),
(route) => false,
);
}
} catch (e) {
Fluttertoast.showToast(msg: 'Signup failed: $e');
}
}

@override
Widget build(BuildContext context) {
return AnnotatedRegion<SystemUiOverlayStyle>(
value: context.theme.appBarTheme.systemOverlayStyle ?? SystemUiOverlayStyle.light,  // FIXED
child: GestureDetector(
onTap: () => FocusScope.of(context).unfocus(),
child: Scaffold(
resizeToAvoidBottomInset: false,
appBar: const CustomAppBar(),
bottomNavigationBar: Consumer<laza_auth.AuthProvider>(
builder: (context, auth, child) {
return BottomNavButton(
label: auth.isLoading ? 'Creating Account...' : 'Sign Up',
onTap: () {
if (auth.isLoading) return;
_handleSignup(context);
},
);
},
),
body: SafeArea(
child: Column(
mainAxisSize: MainAxisSize.max,
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
SizedBox(
width: double.maxFinite,
child: Column(
children: [
Text(
'Create Account',
style: context.headlineMedium,
),
Text(
'Complete your sign up to get started',
style: context.bodyMedium?.copyWith(color: ColorConstant.manatee),
),
],
),
),
Expanded(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: Form(
key: formKey,
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
CustomTextField(
controller: usernameCtrl,
labelText: 'Username',
validator: (val) {
if (val == null || val.isEmpty) {
return 'Username is required';
}
if (val.length < 3) {
return 'Username must be at least 3 characters';
}
return null;
},
),
const SizedBox(height: 10),

CustomTextField(
controller: emailCtrl,
labelText: 'Email Address',
keyboardType: TextInputType.emailAddress,
validator: (val) {
if (val == null || val.isEmpty) {
return 'Email is required';
}
if (!val.contains('@') || !val.contains('.')) {
return 'Enter a valid email address';
}
return null;
},
),
const SizedBox(height: 10),

CustomTextField(
controller: passwordCtrl,
labelText: 'Password',
obscureText: true,
validator: (val) {
if (val == null || val.isEmpty) {
return 'Password is required';
}
if (val.length < 8) {
return 'Password must be at least 8 characters';
}
return null;
},
),
const SizedBox(height: 10),

CustomTextField(
controller: confirmPasswordCtrl,
labelText: 'Confirm Password',
obscureText: true,
textInputAction: TextInputAction.done,
validator: (val) {
if (val == null || val.isEmpty) {
return 'Please confirm your password';
}
return null;
},
),
const SizedBox(height: 15),

SwitchListTile.adaptive(
activeColor: ColorConstant.primary,
contentPadding: EdgeInsets.zero,
title: Text.rich(
TextSpan(
text: 'I agree with ',
style: context.bodySmall,
children: [
TextSpan(
text: 'Privacy Policy ',
style: context.bodySmallW500,
),
const TextSpan(text: 'and '),
TextSpan(
text: 'Terms of Use',
style: context.bodySmallW500,
),
],
),
),
value: agreeToTerms,
onChanged: (val) => setState(() => agreeToTerms = val),
),
],
),
),
),
),
Center(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
child: InkWell(
onTap: () {
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (context) => const SignInScreen()),
);
},
child: Text.rich(
TextSpan(
text: 'Already have an account? ',
style: context.bodySmall?.copyWith(color: ColorConstant.manatee),
children: [
TextSpan(
text: 'Sign In',
style: context.bodySmallW500?.copyWith(color: ColorConstant.primary),
)
],
),
textAlign: TextAlign.center,
),
),
),
),
const SizedBox(height: 10),
],
),
),
),
),
);
}
}
