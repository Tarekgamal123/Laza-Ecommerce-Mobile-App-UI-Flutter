
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // CHANGED FROM system.dart
import 'package:fluttertoast/fluttertoast.dart';
import 'package:laza/components/custom_appbar.dart';
import 'package:laza/components/custom_text_field.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/providers/auth_provider.dart' as laza_auth;
import 'package:laza/reset_password/forgot_password_screen.dart';
import 'package:provider/provider.dart';

import 'components/bottom_nav_button.dart';
import 'components/colors.dart';
import 'dashboard.dart';

class SignInWithEmail extends StatefulWidget {
const SignInWithEmail({super.key});

@override
State<SignInWithEmail> createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
bool rememberMe = false;
final formKey = GlobalKey<FormState>();
final emailCtrl = TextEditingController();
final passwordCtrl = TextEditingController();

@override
void dispose() {
emailCtrl.dispose();
passwordCtrl.dispose();
super.dispose();
}

Future<void> _handleLogin(BuildContext context) async {
if (!formKey.currentState!.validate()) return;

final auth = Provider.of<laza_auth.AuthProvider>(context, listen: false);

bool success = await auth.login(emailCtrl.text, passwordCtrl.text);

if (success && mounted) {
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => const Dashboard()),
(route) => false,
);
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
label: auth.isLoading ? 'Loading...' : 'Login',
onTap: () {
if (auth.isLoading) return;
_handleLogin(context);
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
'Welcome',
style: context.headlineMedium,
),
Text(
'Please enter your data to continue',
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
textInputAction: TextInputAction.done,
),

const SizedBox(height: 10),
Align(
alignment: Alignment.centerRight,
child: TextButton(
onPressed: () => Navigator.push(
context,
MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
),
child: const Text(
'Forgot Password?',
style: TextStyle(color: Colors.red),
),
),
),
const SizedBox(height: 10),
SwitchListTile.adaptive(
activeColor: Platform.isIOS ? ColorConstant.primary : null,
contentPadding: EdgeInsets.zero,
title: const Text('Remember me'),
value: rememberMe,
onChanged: (val) => setState(() => rememberMe = val),
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
onTap: () {},
child: Text.rich(
TextSpan(
text: 'By connecting your account confirm that you agree with our',
style: context.bodySmall?.copyWith(color: ColorConstant.manatee),
children: [
TextSpan(
text: ' Term and Condition',
style: context.bodySmallW500,
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
