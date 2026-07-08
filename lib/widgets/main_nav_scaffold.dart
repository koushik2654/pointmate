import 'package:flutter/material.dart';

import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/leaderboard_screen.dart';
import 'app_bottom_nav_bar.dart';

/// Hosts the three top-level destinations behind the bottom navigation bar.
class MainNavScaffold extends StatefulWidget {
  const MainNavScaffold({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  late int _index = widget.initialIndex;

  static const _screens = [HomeScreen(), HistoryScreen(), LeaderboardScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
