import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The "PointMate" header (back arrow, wordmark, settings gear) shared by
/// the Home screen and any screen pushed on top of it that should keep the
/// same app-level chrome.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.onBack, this.onSettings});

  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        const Text(
          'PointMate',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        IconButton(
          onPressed: onSettings ?? () {},
          icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
