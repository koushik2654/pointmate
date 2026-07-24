import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../data/models/game_match.dart';
import '../../data/models/game_settings.dart';
import '../../data/models/match_player.dart';
import '../../data/models/winning_condition.dart';
import '../../providers/game_match_provider.dart';
import '../../providers/game_settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_nav_scaffold.dart';
import 'game_history_tab_screen.dart';
import 'game_settings_screen.dart';

/// The active "playing" view for a single game: current round, leaderboard,
/// score progression, and the ability to record a new round.
class GameDashboardScreen extends StatelessWidget {
  const GameDashboardScreen({super.key, required this.gameId, required this.gameName});

  final String gameId;
  final String gameName;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => GameMatchProvider(
            box: ctx.read<Box<GameMatch>>(),
            gameId: gameId,
            gameName: gameName,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GameSettingsProvider(
            box: ctx.read<Box<GameSettings>>(),
            gameId: gameId,
          ),
        ),
      ],
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
    final settingsProvider = context.watch<GameSettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  AppHeader(
                    title: provider.match.name,
                    onSettings: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider<GameSettingsProvider>.value(
                              value: settingsProvider,
                            ),
                            ChangeNotifierProvider<GameMatchProvider>.value(value: provider),
                          ],
                          child: const GameSettingsScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: provider.isFinished
                    ? SingleChildScrollView(
                        child: _LeaderboardCard(leaderboard: provider.leaderboard),
                      )
                    : _RoundsTable(provider: provider, settings: settingsProvider.settings),
              ),
            ),
            if (!provider.isFinished)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: SizedBox(
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

  Future<void> _finishGame(BuildContext context, GameMatchProvider provider) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      icon: Icons.flag_rounded,
      title: 'Finish Game?',
      message:
          'This locks in the final standings and moves the game to History. '
          "You won't be able to add more rounds afterward.",
      confirmLabel: 'Finish',
    );

    if (!confirmed) return;

    await provider.finishGame();
    if (!context.mounted) return;

    await _showGameFinishedDialog(context, provider.leaderboard);

    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _showGameFinishedDialog(
    BuildContext context,
    List<MatchPlayerView> leaderboard,
  ) {
    final winner = leaderboard.first;

    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.rankGoldBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.rankGoldFg,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Game Finished!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${winner.name} wins with ${winner.total} pts!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  for (int i = 0; i < leaderboard.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _FinishedStandingRow(rank: i + 1, player: leaderboard[i]),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinishedStandingRow extends StatelessWidget {
  const _FinishedStandingRow({required this.rank, required this.player});

  final int rank;
  final MatchPlayerView player;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isFirst ? AppColors.rankGoldBg : AppColors.cardMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isFirst ? AppColors.rankGoldCircle : AppColors.rankNeutralCircle,
            child: isFirst
                ? const Icon(Icons.star_rounded, color: Colors.white, size: 14)
                : Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 12,
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${player.total} pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isFirst ? AppColors.rankGoldFg : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
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
  const _RoundsTable({required this.provider, required this.settings});

  final GameMatchProvider provider;
  final GameSettings settings;

  @override
  State<_RoundsTable> createState() => _RoundsTableState();
}

class _RoundsTableState extends State<_RoundsTable> {
  static const double _labelColumnWidth = 52;
  static const double _playerColumnWidth = 84;
  static const double _rowHeight = 44;
  static const double _headerHeight = 72;

  late Map<String, TextEditingController> _pendingControllers;
  late Map<String, FocusNode> _pendingFocusNodes;

  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();
  String? _editingPlayerId;
  int? _editingRoundIndex;

  // The rounds region scrolls horizontally past 4+ players; the fixed Total
  // row below it mirrors that same offset so its columns stay aligned.
  final ScrollController _roundsHorizontalController = ScrollController();
  final ScrollController _totalsHorizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pendingControllers = {
      for (final p in widget.provider.match.players) p.id: TextEditingController(),
    };
    _pendingFocusNodes = {
      for (final p in widget.provider.match.players) p.id: FocusNode(),
    };
    _editFocusNode.addListener(() {
      if (_editFocusNode.hasFocus) {
        _editController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _editController.text.length,
        );
      } else {
        _commitEdit();
      }
    });
    _roundsHorizontalController.addListener(() {
      if (_totalsHorizontalController.hasClients) {
        _totalsHorizontalController.jumpTo(_roundsHorizontalController.offset);
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _pendingControllers.values) {
      controller.dispose();
    }
    for (final node in _pendingFocusNodes.values) {
      node.dispose();
    }
    _editController.dispose();
    _editFocusNode.dispose();
    _roundsHorizontalController.dispose();
    _totalsHorizontalController.dispose();
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

  /// Jumps focus to the next player's score field after one is filled, so
  /// the whole round can be entered without reaching for each field by hand.
  void _focusNextPlayer(List<MatchPlayer> players, String currentPlayerId) {
    final index = players.indexWhere((p) => p.id == currentPlayerId);
    if (index == -1 || index + 1 >= players.length) return;
    FocusScope.of(context).requestFocus(_pendingFocusNodes[players[index + 1].id]);
  }

  void _startEditingCell(String playerId, int roundIndex, int currentDelta) {
    final isSameCell = _editingPlayerId == playerId && _editingRoundIndex == roundIndex;
    if (_editingPlayerId != null && !isSameCell) {
      _commitEdit();
    }
    _editController.text = '$currentDelta';
    setState(() {
      _editingPlayerId = playerId;
      _editingRoundIndex = roundIndex;
    });
  }

  Future<void> _commitEdit() async {
    final playerId = _editingPlayerId;
    final roundIndex = _editingRoundIndex;
    if (playerId == null || roundIndex == null) return;
    final value = int.tryParse(_editController.text);
    setState(() {
      _editingPlayerId = null;
      _editingRoundIndex = null;
    });
    if (value == null) return;
    await widget.provider.updateRound(roundIndex, {playerId: value});
  }

  /// Whether the highest total (vs. the lowest) should be highlighted green.
  /// Follows the game's winning condition by default; flipped by
  /// [GameSettings.invertScoreColors] for players who want it the other way.
  bool get _highestIsGreen =>
      (widget.settings.winningCondition == WinningCondition.highestScoreWins) !=
      widget.settings.invertScoreColors;

  @override
  Widget build(BuildContext context) {
    final players = widget.provider.match.players;
    final rounds = widget.provider.rounds;

    final totals = [for (final p in players) p.total];
    final highestTotal = totals.isEmpty ? null : totals.reduce((a, b) => a > b ? a : b);
    final lowestTotal = totals.isEmpty ? null : totals.reduce((a, b) => a < b ? a : b);
    final hasSpread = highestTotal != null && lowestTotal != null && highestTotal != lowestTotal;

    Color totalColor(int total) {
      if (!hasSpread) return AppColors.textPrimary;
      if (total == highestTotal) {
        return _highestIsGreen ? AppColors.positive : AppColors.negative;
      }
      if (total == lowestTotal) {
        return _highestIsGreen ? AppColors.negative : AppColors.positive;
      }
      return AppColors.textPrimary;
    }

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
          // Rounds scroll independently, within whatever space is left once
          // the header above and the Total row/Finish Game button below have
          // claimed theirs — so those two stay put no matter how many rounds
          // have been played.
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _roundsHorizontalController,
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
                                for (final round in rounds) ...[
                                  _deltaCell(round, player),
                                  const Divider(height: 1, color: AppColors.inputBorder),
                                ],
                                SizedBox(
                                  width: _playerColumnWidth,
                                  height: _rowHeight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                    child: TextField(
                                      controller: _pendingControllers[player.id],
                                      focusNode: _pendingFocusNodes[player.id],
                                      textAlign: TextAlign.center,
                                      keyboardType: const TextInputType.numberWithOptions(
                                        signed: true,
                                      ),
                                      textInputAction: players.last.id == player.id
                                          ? TextInputAction.done
                                          : TextInputAction.next,
                                      onSubmitted: (_) => _focusNextPlayer(players, player.id),
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
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: _headerHeight),
                      for (final round in rounds) ...[
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
                        const Divider(height: 1, color: AppColors.inputBorder),
                      ],
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (rounds.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.inputBorder),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _totalsHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        for (final player in players)
                          SizedBox(
                            width: _playerColumnWidth,
                            height: _rowHeight,
                            child: Center(
                              child: Text(
                                '${player.total}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: totalColor(player.total),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: _labelColumnWidth,
                  height: _rowHeight,
                  child: Center(
                    child: Text(
                      'T',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _deltaCell(RoundSummary round, MatchPlayer player) {
    final delta = round.deltas[player.id] ?? 0;
    final roundIndex = round.roundNumber - 1;

    if (_editingPlayerId == player.id && _editingRoundIndex == roundIndex) {
      return SizedBox(
        width: _playerColumnWidth,
        height: _rowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: TextField(
            controller: _editController,
            focusNode: _editFocusNode,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _commitEdit(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
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
      );
    }

    return SizedBox(
      width: _playerColumnWidth,
      height: _rowHeight,
      child: InkWell(
        onTap: () => _startEditingCell(player.id, roundIndex, delta),
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
