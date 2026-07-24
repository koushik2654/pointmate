import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_session.dart';
import '../providers/games_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/app_header.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/game_session_card.dart';
import '../widgets/total_activity_card.dart';
import 'game/game_dashboard_screen.dart';
import 'new_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  List<GameSession> _filter(List<GameSession> sessions) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return sessions;
    return sessions.where((session) {
      if (session.name.toLowerCase().contains(query)) return true;
      return session.players.any((player) => player.name.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final games = context.watch<GamesProvider>();
    final activeGames = _filter(games.activeGames);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppHeader(showBack: false, showSettings: false),
                        const SizedBox(height: 16),
                        AppSearchBar(onChanged: (value) => setState(() => _query = value)),
                        const SizedBox(height: 20),
                        TotalActivityCard(gamesPlayed: games.totalGamesPlayed),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Active Games',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View All',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (activeGames.isEmpty && _query.isNotEmpty)
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'No games or players match your search',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList.separated(
                    itemCount: activeGames.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final session = activeGames[index];
                      return GameSessionCard(
                        session: session,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GameDashboardScreen(
                              gameId: session.id,
                              gameName: session.name,
                            ),
                          ),
                        ),
                        onDelete: () => _confirmDelete(context, session),
                        onFinish: () => _confirmFinish(context, session),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const NewGameScreen())),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GameSession session) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      icon: Icons.delete_outline_rounded,
      iconBackgroundColor: AppColors.statusInProgressBg,
      iconColor: AppColors.negative,
      title: 'Delete Game?',
      message: 'Do you want to delete "${session.name}"?',
      confirmLabel: 'Delete',
      confirmColor: AppColors.negative,
    );

    if (confirmed && context.mounted) {
      await context.read<GamesProvider>().deleteGame(session.id);
    }
  }

  Future<void> _confirmFinish(BuildContext context, GameSession session) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      icon: Icons.flag_rounded,
      title: 'Finish Game?',
      message:
          'This locks in the final standings for "${session.name}" and moves it '
          "to History. You won't be able to add more rounds afterward.",
      confirmLabel: 'Finish',
    );

    if (confirmed && context.mounted) {
      await context.read<GamesProvider>().finishGame(session.id);
    }
  }
}
