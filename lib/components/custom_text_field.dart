
import 'package:flutter/material.dart';
import 'package:laza/components/colors.dart';
import 'package:laza/extensions/context_extension.dart';

class CustomTextField extends StatelessWidget {
const CustomTextField({
super.key,
required this.labelText,
this.controller,
this.textInputAction,
this.validator,
this.keyboardType = TextInputType.text,
this.obscureText = false,
});

final String labelText;
final TextEditingController? controller;
final TextInputAction? textInputAction;
final String? Function(String?)? validator;
final TextInputType keyboardType;
final bool obscureText;

@override
Widget build(BuildContext context) {
return TextFormField(
controller: controller,
validator: validator,
textInputAction: textInputAction ?? TextInputAction.next,
keyboardType: keyboardType,
obscureText: obscureText,
style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
textCapitalization: TextCapitalization.words,
decoration: InputDecoration(
labelText: labelText,
labelStyle: context.bodySmall?.copyWith(color: ColorConstant.manatee),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
),
);
}
}
