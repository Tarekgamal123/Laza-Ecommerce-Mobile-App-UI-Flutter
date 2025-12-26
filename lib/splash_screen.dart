
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laza/components/colors.dart';
import 'package:laza/intro_screen.dart';
import 'package:laza/providers/auth_provider.dart' as laza_auth;
import 'package:provider/provider.dart';

import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
@override
void initState() {
super.initState();
_checkAuthAndNavigate();
}

Future<void> _checkAuthAndNavigate() async {
// Wait 2 seconds for splash screen
await Future.delayed(const Duration(seconds: 2));

if (!mounted) return;

final authProvider = Provider.of<laza_auth.AuthProvider>(context, listen: false);

// Use the correct method name
bool isLoggedIn = await authProvider.checkAuthStatus();

Widget nextScreen;
if (isLoggedIn) {
nextScreen = const Dashboard();
} else {
nextScreen = const IntroductionScreen();
}

Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (context) => nextScreen),
);
}

@override
Widget build(BuildContext context) {
return AnnotatedRegion<SystemUiOverlayStyle>(
value: SystemUiOverlayStyle(
statusBarColor: ColorConstant.primary,
systemNavigationBarColor: ColorConstant.primary,
statusBarIconBrightness: Brightness.light,
),
child: Scaffold(
backgroundColor: ColorConstant.primary,
body: Center(
child: SvgPicture.asset('assets/images/Logo.svg'),
),
),
);
}
}
