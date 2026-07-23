import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../data/models/game_match.dart';
import '../../data/models/game_settings.dart';
import '../../data/models/match_player.dart';
import '../../providers/game_match_provider.dart';
import '../../providers/game_settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_nav_scaffold.dart';
import 'game_settings_screen.dart';

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

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeader(
              title: provider.match.name,
              onSettings: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (ctx) => GameSettingsProvider(
                      box: ctx.read<Box<GameSettings>>(),
                      gameId: gameId,
                    ),
                    child: const GameSettingsScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: provider.isFinished
                      ? AppColors.rankGoldBg
                      : AppColors.statusYourTurnBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.isFinished ? Icons.check_circle_rounded : Icons.style_outlined,
                      size: 16,
                      color: provider.isFinished
                          ? AppColors.rankGoldFg
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.isFinished ? 'FINISHED' : 'ROUND ${provider.currentRound}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: provider.isFinished
                            ? AppColors.rankGoldFg
                            : AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (provider.isFinished) _LeaderboardCard(leaderboard: provider.leaderboard),
            if (!provider.isFinished) _RoundsTable(provider: provider),
            const SizedBox(height: 24),
            if (!provider.isFinished) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _finishGame(context, provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primaryLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text(
                    'Finish Game',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
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

  Future<void> _finishGame(BuildContext context, GameMatchProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Game'),
        content: const Text(
          'This locks in the final standings and moves the game to History. '
          'You won\'t be able to add more rounds afterward.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await provider.finishGame();
    if (!context.mounted) return;

    final leaderboard = provider.leaderboard;
    final winner = leaderboard.first;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Finished!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${winner.name} wins with ${winner.total} pts!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < leaderboard.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${i + 1}. ${leaderboard[i].name} — ${leaderboard[i].total} pts'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

/// Final standings shown once a game has been marked finished.
class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.leaderboard});

  final List<MatchPlayerView> leaderboard;

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
          const Text(
            'Leaderboard',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < leaderboard.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _LeaderboardRow(rank: i + 1, player: leaderboard[i]),
          ],
        ],
      ),
    );
  }
}

/// Round-by-round scoreboard for an in-progress game: one row per round,
/// one column per player (scrolls horizontally past 4 players), a running
/// total in the bottom row, and an always-available input row for entering
/// the next round's scores directly — no separate dialog.
class _RoundsTable extends StatefulWidget {
  const _RoundsTable({required this.provider});

  final GameMatchProvider provider;

  @override
  State<_RoundsTable> createState() => _RoundsTableState();
}

class _RoundsTableState extends State<_RoundsTable> {
  static const double _labelColumnWidth = 52;
  static const double _playerColumnWidth = 84;
  static const double _rowHeight = 44;
  static const double _headerHeight = 72;

  late Map<String, TextEditingController> _pendingControllers;

  @override
  void initState() {
    super.initState();
    _pendingControllers = {
      for (final p in widget.provider.match.players) p.id: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _pendingControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _commitPendingRound() async {
    final roundPoints = {
      for (final entry in _pendingControllers.entries)
        entry.key: int.tryParse(entry.value.text) ?? 0,
    };
    for (final controller in _pendingControllers.values) {
      controller.clear();
    }
    await widget.provider.addRound(roundPoints);
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.provider.match.players;
    final rounds = widget.provider.rounds;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scoreboard',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final player in players)
                        Column(
                          children: [
                            SizedBox(
                              width: _playerColumnWidth,
                              height: _headerHeight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Color(player.avatarColorValue),
                                    child: Text(
                                      player.initial,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    player.name.split(' ').first,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            for (final round in rounds) _deltaCell(round, player),
                            SizedBox(
                              width: _playerColumnWidth,
                              height: _rowHeight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                child: TextField(
                                  controller: _pendingControllers[player.id],
                                  textAlign: TextAlign.center,
                                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    isDense: true,
                                    filled: true,
                                    fillColor: AppColors.searchFill,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (rounds.isNotEmpty) ...[
                              const Divider(height: 1, color: AppColors.inputBorder),
                              SizedBox(
                                width: _playerColumnWidth,
                                height: _rowHeight,
                                child: Center(
                                  child: Text(
                                    '${player.total}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: _headerHeight),
                  for (final round in rounds)
                    SizedBox(
                      width: _labelColumnWidth,
                      height: _rowHeight,
                      child: Center(
                        child: Text(
                          'R${round.roundNumber}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: _labelColumnWidth,
                    height: _rowHeight,
                    child: Center(
                      child: InkWell(
                        onTap: _commitPendingRound,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (rounds.isNotEmpty) ...[
                    const Divider(height: 1, color: AppColors.inputBorder),
                    const SizedBox(width: _labelColumnWidth, height: _rowHeight),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deltaCell(RoundSummary round, MatchPlayer player) {
    final delta = round.deltas[player.id] ?? 0;
    return SizedBox(
      width: _playerColumnWidth,
      height: _rowHeight,
      child: Center(
        child: Text(
          '${delta >= 0 ? '+' : ''}$delta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: delta < 0 ? AppColors.negative : AppColors.textPrimary,
          ),
        ),
      ),
    );
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
