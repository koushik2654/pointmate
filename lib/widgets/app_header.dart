import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The "PointMate" header (back arrow, wordmark, settings gear) shared by
/// the Home screen and any screen pushed on top of it that should keep the
/// same app-level chrome.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.onBack,
    this.onSettings,
    this.showBack = true,
    this.showSettings = true,
    this.title = 'PointMate',
  });

  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final bool showBack;
  final bool showSettings;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showBack)
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          )
        else
          const SizedBox(width: 48),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        if (showSettings)
          IconButton(
            onPressed: onSettings ?? () {},
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}
