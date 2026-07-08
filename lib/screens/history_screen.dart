import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'History coming soon',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
      ),
    );
  }
}
