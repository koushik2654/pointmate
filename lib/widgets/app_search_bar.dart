import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Static search field used at the top of the Home screen.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search games, players...',
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.searchFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
