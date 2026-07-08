import 'package:flutter/material.dart';

import '../models/game_session.dart';
import '../theme/app_theme.dart';

/// A single active/paused/awaiting-turn game card, matching the Home mockup.
class GameSessionCard extends StatelessWidget {
  const GameSessionCard({super.key, required this.session, this.onTap, this.onDelete});

  final GameSession session;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusChip(status: session.status),
                  Row(
                    children: [
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
                ],
              ),
              const SizedBox(height: 12),
              Text(
                session.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...session.players.map(
                (player) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _PlayerRow(player: player),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final GameStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      GameStatus.inProgress => (
          AppColors.statusInProgressBg,
          AppColors.statusInProgressFg,
        ),
      GameStatus.paused => (AppColors.statusPausedBg, AppColors.statusPausedFg),
      GameStatus.yourTurn => (
          AppColors.statusYourTurnBg,
          AppColors.statusYourTurnFg,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
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
