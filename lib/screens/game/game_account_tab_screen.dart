import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class GameAccountTabScreen extends StatelessWidget {
  const GameAccountTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Account settings coming soon',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
      ),
    );
  }
}
