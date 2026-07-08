import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../data/models/game_settings.dart';
import '../providers/game_settings_provider.dart';
import '../screens/game/game_account_tab_screen.dart';
import '../screens/game/game_history_tab_screen.dart';
import '../screens/game/game_players_tab_screen.dart';
import '../screens/game/game_settings_screen.dart';
import '../theme/app_theme.dart';

/// Hosts the per-game destinations (rules, round history, players, account)
/// once the user has entered a specific game, behind their own bottom nav.
class GameNavScaffold extends StatefulWidget {
  const GameNavScaffold({super.key, required this.gameId});

  final String gameId;

  @override
  State<GameNavScaffold> createState() => _GameNavScaffoldState();
}

class _GameNavScaffoldState extends State<GameNavScaffold> {
  int _index = 0;

  static const _screens = [
    GameSettingsScreen(),
    GameHistoryTabScreen(),
    GamePlayersTabScreen(),
    GameAccountTabScreen(),
  ];

  static const _destinations = [
    (icon: Icons.sports_esports_rounded, label: 'Game'),
    (icon: Icons.history_rounded, label: 'History'),
    (icon: Icons.groups_rounded, label: 'Players'),
    (icon: Icons.settings_outlined, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => GameSettingsProvider(
        box: ctx.read<Box<GameSettings>>(),
        gameId: widget.gameId,
      ),
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardMuted, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_destinations.length, (i) {
                final destination = _destinations[i];
                return _GameNavItem(
                  icon: destination.icon,
                  label: destination.label,
                  selected: i == _index,
                  onTap: () => setState(() => _index = i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameNavItem extends StatelessWidget {
  const _GameNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.statusYourTurnBg : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: selected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
