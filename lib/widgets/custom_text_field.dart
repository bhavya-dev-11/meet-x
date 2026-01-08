// lib/widgets/auth_text_field.dart
import 'package:flutter/material.dart';
import 'package:meetzone/theme.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool
  isLightBackground; // New: auto-detect or force light/dark mode style
  final TextInputType? keyboardType;
  final int? maxLines;

  const AuthTextField({
    Key? key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.isLightBackground = false, // default = dark mode (main app)
    this.keyboardType,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool lightMode =
        isLightBackground || Theme.of(context).brightness == Brightness.light;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: validator,
      maxLines: isPassword ? 1 : maxLines,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: lightMode ? AppColors.textOnLight : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color:
              lightMode
                  ? AppColors.textMutedLight.withValues(alpha: 0.7)
                  : AppColors.textTertiary.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor:
            lightMode
                ? Colors.white.withValues(alpha: 0.78)
                : AppColors.surfaceMuted.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(
            color:
                lightMode
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
        ),
      ),
    );
  }
}


