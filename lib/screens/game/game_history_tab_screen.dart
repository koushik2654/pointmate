import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class GameHistoryTabScreen extends StatelessWidget {
  const GameHistoryTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Round history coming soon',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
      ),
    );
  }
}
