import 'package:chat_app/shared/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.suffixIcon,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    required this.validator,
    required this.type,
    this.fillColor,
    this.labelColor,
  });

  final TextEditingController controller;
  final Widget? suffixIcon;
  final String labelText;
  final Widget prefixIcon;
  final bool obscureText;
  final String? Function(String?) validator;
  final TextInputType type;
  final Color? fillColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return TextFormField(
          style: TextStyle(color: themeProvider.textColor),
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            labelText: labelText,
            labelStyle: TextStyle(color: labelColor ?? themeProvider.textColor),
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(),
            filled: fillColor != null,
            fillColor: fillColor,
          ),
          cursorColor: themeProvider.textColor,
          obscureText: obscureText,
          validator: validator,
          keyboardType: type,
        );
      },
    );
  }
}
