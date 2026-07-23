import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Modern floating snack bars matching PointMate's visual language, in place
/// of Material's default bottom-anchored bar.
class AppSnackBar {
  AppSnackBar._();

  static void showError(BuildContext context, String message) {
    _show(context, message: message, icon: Icons.error_outline_rounded, accent: AppColors.negative);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color accent,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
        elevation: 6,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
