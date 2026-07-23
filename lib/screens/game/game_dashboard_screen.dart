import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../data/models/game_match.dart';
import '../../data/models/match_player.dart';
import '../../providers/game_match_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_header.dart';
import '../../widgets/game_nav_scaffold.dart';
import '../../widgets/main_nav_scaffold.dart';
import '../../widgets/progression_chart.dart';

/// The active "playing" view for a single game: current round, leaderboard,
/// score progression, and the ability to record a new round.
class GameDashboardScreen extends StatelessWidget {
  const GameDashboardScreen({super.key, required this.gameId, required this.gameName});

  final String gameId;
  final String gameName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => GameMatchProvider(
        box: ctx.read<Box<GameMatch>>(),
        gameId: gameId,
        gameName: gameName,
      ),
      child: _GameDashboardBody(gameId: gameId),
    );
  }
}

class _GameDashboardBody extends StatelessWidget {
  const _GameDashboardBody({required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameMatchProvider>();
    final leaderboard = provider.leaderboard;
    final players = provider.match.players;
    final topTwo = leaderboard.take(2).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeader(
              onSettings: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => GameNavScaffold(gameId: gameId)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                provider.match.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.05,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.statusYourTurnBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.style_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'ROUND ${provider.currentRound}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < leaderboard.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _LeaderboardRow(rank: i + 1, player: leaderboard[i]),
                  ],
                ],
              ),
            ),
            // const SizedBox(height: 20),
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: AppColors.cardMuted,
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             'Progression',
            //             style: TextStyle(
            //               fontSize: 17,
            //               fontWeight: FontWeight.w700,
            //               color: AppColors.textPrimary,
            //             ),
            //           ),
            //           Icon(Icons.show_chart_rounded, color: AppColors.textSecondary),
            //         ],
            //       ),
            //       const SizedBox(height: 12),
            //       if (topTwo.length >= 2)
            //         ProgressionChart(
            //           leaderSeries: _seriesFor(players, topTwo[0].id),
            //           runnerUpSeries: _seriesFor(players, topTwo[1].id),
            //           roundLabels: List.generate(provider.currentRound, (i) => 'R${i + 1}'),
            //         ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showAddRoundDialog(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add New Round',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0,
        onTap: (i) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainNavScaffold(initialIndex: i)),
          (route) => false,
        ),
      ),
    );
  }

  List<int> _seriesFor(List<MatchPlayer> players, String playerId) {
    return players.firstWhere((p) => p.id == playerId).roundScores;
  }

  Future<void> _showAddRoundDialog(BuildContext context, GameMatchProvider provider) async {
    final controllers = {for (final p in provider.match.players) p.id: TextEditingController()};

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Round'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final p in provider.match.players)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TextField(
                  controller: controllers[p.id],
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  decoration: InputDecoration(labelText: '${p.name} points this round'),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final roundPoints = {
        for (final entry in controllers.entries) entry.key: int.tryParse(entry.value.text) ?? 0,
      };
      await provider.addRound(roundPoints);
    }
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.rank, required this.player});

  final int rank;
  final MatchPlayerView player;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFirst ? AppColors.rankGoldBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isFirst ? AppColors.rankGoldCircle : AppColors.rankNeutralCircle,
            child: isFirst
                ? const Icon(Icons.star_rounded, color: Colors.white, size: 18)
                : Text(
                    '$rank',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatScore(player.total),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isFirst ? AppColors.rankGoldFg : AppColors.textPrimary,
                ),
              ),
              const Text(
                'PTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatScore(int score) {
    final digits = score.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return (score < 0 ? '-' : '') + buffer.toString();
  }
}
