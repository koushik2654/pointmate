import 'package:flutter/material.dart';

import '../models/game_session.dart';
import '../theme/app_theme.dart';

/// A single active game card, matching the Home mockup: name + created-at
/// in place of a redundant "in progress" chip (every card in this list is
/// in progress by definition), its top 2 players by score, and a quick
/// See More / Finish action row.
class GameSessionCard extends StatelessWidget {
  const GameSessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onDelete,
    this.onFinish,
  });

  final GameSession session;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final topPlayers = [...session.players]
      ..sort((a, b) => b.score.compareTo(a.score));

    return Material(
      color: AppColors.cardMuted,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCreatedAt(session.createdAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(session.icon, size: 18, color: AppColors.primary),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDelete,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.negative,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              ...topPlayers.take(2).map(
                (player) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _PlayerRow(player: player),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('See More', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  if (onFinish != null)
                    OutlinedButton(
                      onPressed: onFinish,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primaryLight),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Finish',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _kMonthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatCreatedAt(DateTime createdAt) {
  final hour12 = createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12;
  final period = createdAt.hour >= 12 ? 'PM' : 'AM';
  final minute = createdAt.minute.toString().padLeft(2, '0');
  return '${createdAt.day} ${_kMonthAbbreviations[createdAt.month - 1]} · $hour12:$minute $period';
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final PlayerScore player;

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = player.score < 0
        ? AppColors.negative
        : player.isCurrentUser
            ? AppColors.primary
            : AppColors.textPrimary;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: player.avatarColor,
          child: Text(
            player.initial,
            style: TextStyle(
              color: player.isCurrentUser ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            player.name,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: player.isCurrentUser ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          '${player.score}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: scoreColor),
        ),
      ],
    );
  }
}
