import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/match_player.dart';
import '../../providers/game_match_provider.dart';
import '../../theme/app_theme.dart';

/// Lists every round recorded for the current game with each player's
/// points that round and running total, and lets the user edit or delete
/// a round after the fact.
class GameHistoryTabScreen extends StatelessWidget {
  const GameHistoryTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameMatchProvider>();
    final players = provider.match.players;
    final rounds = provider.rounds.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Round History',
          style: TextStyle(color: AppColors.primary, fontSize: 19, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: rounds.isEmpty
          ? const Center(
              child: Text(
                'No rounds recorded yet',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: rounds.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final round = rounds[index];
                return _RoundCard(
                  round: round,
                  players: players,
                  onEdit: () => _showEditRoundDialog(context, provider, round, players),
                  onDelete: () => _confirmDeleteRound(context, provider, round),
                );
              },
            ),
    );
  }

  Future<void> _showEditRoundDialog(
    BuildContext context,
    GameMatchProvider provider,
    RoundSummary round,
    List<MatchPlayer> players,
  ) async {
    final controllers = {
      for (final p in players) p.id: TextEditingController(text: '${round.deltas[p.id] ?? 0}'),
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Round ${round.roundNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final p in players)
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
      await provider.updateRound(round.roundNumber - 1, roundPoints);
    }
  }

  Future<void> _confirmDeleteRound(
    BuildContext context,
    GameMatchProvider provider,
    RoundSummary round,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Round ${round.roundNumber}'),
        content: const Text(
          'This round will be removed and every player\'s totals recalculated.',
        ),
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

    if (confirmed == true) {
      await provider.deleteRound(round.roundNumber - 1);
    }
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    required this.round,
    required this.players,
    required this.onEdit,
    required this.onDelete,
  });

  final RoundSummary round;
  final List<MatchPlayer> players;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Round ${round.roundNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.negative,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final player in players) _RoundPlayerRow(player: player, round: round),
        ],
      ),
    );
  }
}

class _RoundPlayerRow extends StatelessWidget {
  const _RoundPlayerRow({required this.player, required this.round});

  final MatchPlayer player;
  final RoundSummary round;

  @override
  Widget build(BuildContext context) {
    final delta = round.deltas[player.id] ?? 0;
    final total = round.totals[player.id] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(player.avatarColorValue),
            child: Text(
              player.initial,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${delta >= 0 ? '+' : ''}$delta',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: delta < 0 ? AppColors.negative : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: Text(
              '$total',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
