// lib/widgets/custom_snackbar.dart
import 'package:flutter/material.dart';
import 'package:meetzone/theme.dart';

class CustomSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      iconColor: AppColors.success,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      iconColor: AppColors.error,
      icon: Icons.error_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message,
      iconColor: AppColors.info,
      icon: Icons.info_rounded,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color iconColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        elevation:
            0, // Using manual shadow via container if needed, or flat for clean look
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
