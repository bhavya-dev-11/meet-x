// lib/widgets/custom_snackbar.dart
import 'package:flutter/material.dart';
import 'package:meetzone/theme.dart';

class CustomSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFF10B981), // Emerald 500
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFFEF4444), // Red 500
      icon: Icons.error_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFF3B82F6), // Blue 500
      icon: Icons.info_rounded,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}


