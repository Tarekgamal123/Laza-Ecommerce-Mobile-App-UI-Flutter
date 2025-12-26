
import 'package:flutter/material.dart';
import 'package:laza/components/colors.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/home_screen.dart';

class OrderConfirmedScreen extends StatelessWidget {
final String totalPrice;
final VoidCallback onOrderComplete;

const OrderConfirmedScreen({
super.key,
required this.totalPrice,
required this.onOrderComplete,
});

@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 20),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
// Success Icon
Container(
width: 120,
height: 120,
decoration: BoxDecoration(
color: ColorConstant.primary.withOpacity(0.1),
shape: BoxShape.circle,
),
child: Icon(
Icons.check,
size: 60,
color: ColorConstant.primary,
),
),
const SizedBox(height: 30),
// Title
Text(
'Order Confirmed!',
style: context.headlineLarge?.copyWith(
fontWeight: FontWeight.bold,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 15),
// Message
Text(
'Your order has been confirmed and will be shipped within 2 days',
style: context.bodyLarge?.copyWith(
color: ColorConstant.manatee,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 30),
// Order Details
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Theme.of(context).cardColor,
borderRadius: BorderRadius.circular(15),
),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Order No:', style: context.bodyMedium),
Text('#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
style: context.bodyMediumW600),
],
),
const SizedBox(height: 10),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Date:', style: context.bodyMedium),
Text(
'${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
style: context.bodyMediumW600,
),
],
),
const SizedBox(height: 10),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Total:', style: context.bodyMedium),
Text(totalPrice, style: context.bodyLargeW600),
],
),
],
),
),
const SizedBox(height: 40),
// Buttons
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
onOrderComplete();
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => const HomeScreen()),
(route) => false,
);
},
style: ElevatedButton.styleFrom(
backgroundColor: ColorConstant.primary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
padding: const EdgeInsets.symmetric(vertical: 18),
),
child: Text(
'Continue Shopping',
style: context.bodyLarge?.copyWith(
color: Colors.white,
fontWeight: FontWeight.w600,
),
),
),
),
const SizedBox(height: 15),
TextButton(
onPressed: () {
// TODO: Navigate to order tracking screen
},
child: Text(
'Track Order',
style: context.bodyLarge?.copyWith(
color: ColorConstant.primary,
fontWeight: FontWeight.w600,
),
),
),
],
),
),
),
);
}
}
