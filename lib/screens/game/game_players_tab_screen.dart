import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class GamePlayersTabScreen extends StatelessWidget {
  const GamePlayersTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Player standings coming soon',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
      ),
    );
  }
}
