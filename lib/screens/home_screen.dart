import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_session.dart';
import '../providers/games_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/game_session_card.dart';
import '../widgets/total_activity_card.dart';
import 'game/game_dashboard_screen.dart';
import 'new_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = context.watch<GamesProvider>();

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
                        const AppSearchBar(),
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList.separated(
                    itemCount: games.activeGames.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final session = games.activeGames[index];
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: Text('Do you want to delete "${session.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.negative)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GamesProvider>().deleteGame(session.id);
    }
  }
}
