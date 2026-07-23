import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/games_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

/// Ranks players by games won (aggregated by name) across every game
/// they've played, live as rounds are recorded.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<GamesProvider>().leaderboard;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeader(showBack: false, showSettings: false),
                    const SizedBox(height: 16),
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (entries.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No games played yet',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.separated(
                  itemCount: entries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _LeaderboardEntryRow(rank: index + 1, entry: entries[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardEntryRow extends StatelessWidget {
  const _LeaderboardEntryRow({required this.rank, required this.entry});

  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFirst ? AppColors.rankGoldBg : AppColors.cardMuted,
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
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: entry.avatarColor,
            child: Text(
              entry.initial,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.gamesPlayed} game${entry.gamesPlayed == 1 ? '' : 's'} played',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.wins}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isFirst ? AppColors.rankGoldFg : AppColors.textPrimary,
                ),
              ),
              const Text(
                'WINS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
