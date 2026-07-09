import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../data/models/game_match.dart';
import '../data/models/game_settings.dart';
import '../data/models/match_player.dart';
import '../data/models/participant_entry.dart';
import '../data/models/round_multiplier.dart';
import '../data/models/winning_condition.dart';
import '../models/game_session.dart';
import '../providers/games_provider.dart';
import '../theme/app_theme.dart';
import 'game/game_dashboard_screen.dart';

const List<String> _kCategories = ['Board Game', 'Card Game', 'Sports'];

const List<Color> _kCustomAvatarPalette = [
  Color(0xFFB9A6E0),
  Color(0xFFE8A0A0),
  Color(0xFF7FCDBB),
  Color(0xFFF3C98B),
  Color(0xFF8FB8E0),
  Color(0xFFE0A9D9),
  Color(0xFFA9D18E),
  Color(0xFFE0938F),
];

class _RosterFriend {
  _RosterFriend({
    required this.id,
    required this.name,
    this.subtitle,
    Color? avatarColor,
    this.isCustom = false,
  }) : avatarColor = avatarColor ?? AppColors.cardMuted;

  final String id;
  final String name;
  final String? subtitle;
  final Color avatarColor;
  final bool isCustom;

  String get firstName => name.split(' ').first;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color get textColor =>
      avatarColor == AppColors.cardMuted ? AppColors.textSecondary : Colors.white;
}

/// Modal form for creating a new game: name, category, and roster of players.
class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String _query = '';

  final List<_RosterFriend> _roster = [
    _RosterFriend(id: 'john-davis', name: 'John Davis', avatarColor: const Color(0xFFE8A0A0)),
    _RosterFriend(id: 'sarah-king', name: 'Sarah King', avatarColor: const Color(0xFFB9A6E0)),
    _RosterFriend(id: 'alex-morgan', name: 'Alex Morgan', avatarColor: const Color(0xFF7FCDBB)),
  ];

  final List<_RosterFriend> _available = [
    _RosterFriend(
      id: 'mike-johnson',
      name: 'Mike Johnson',
      subtitle: 'Last played: 2 days ago',
    ),
    _RosterFriend(id: 'emma-lee', name: 'Emma Lee', subtitle: 'New Friend'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_RosterFriend> get _filteredAvailable {
    if (_query.isEmpty) return _available;
    final query = _query.toLowerCase();
    return _available.where((f) => f.name.toLowerCase().contains(query)).toList();
  }

  void _addFriend(_RosterFriend friend) {
    setState(() {
      _available.remove(friend);
      _roster.add(friend);
    });
  }

  void _removeFromRoster(_RosterFriend friend) {
    setState(() {
      _roster.remove(friend);
      if (!friend.isCustom) _available.add(friend);
    });
  }

  Future<void> _showAddCustomPlayerDialog() async {
    final controller = TextEditingController();
    final usedColors = _roster.map((f) => f.avatarColor).toSet();
    Color selectedColor = _kCustomAvatarPalette.firstWhere(
      (color) => !usedColors.contains(color),
      orElse: () => _kCustomAvatarPalette[_roster.length % _kCustomAvatarPalette.length],
    );

    late StateSetter dialogSetState;
    controller.addListener(() => dialogSetState(() {}));

    final result = await showDialog<Map<String, Object>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          dialogSetState = setState;
          final canAdd = controller.text.trim().isNotEmpty;

          return AlertDialog(
            title: const Text('Add Player'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Player name'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Avatar Color',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final color in _kCustomAvatarPalette)
                      GestureDetector(
                        key: ValueKey(color),
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? AppColors.textPrimary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: selectedColor == color
                              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: canAdd
                    ? () => Navigator.of(
                        context,
                      ).pop({'name': controller.text.trim(), 'color': selectedColor})
                    : null,
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      setState(() {
        _roster.add(
          _RosterFriend(
            id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
            name: result['name']! as String,
            avatarColor: result['color']! as Color,
            isCustom: true,
          ),
        );
      });
    }
  }

  IconData get _categoryIcon {
    switch (_selectedCategory) {
      case 'Board Game':
        return Icons.hexagon_outlined;
      case 'Card Game':
        return Icons.style_rounded;
      case 'Sports':
        return Icons.sports_basketball_rounded;
      default:
        return Icons.style_rounded;
    }
  }

  Future<void> _createGame() async {
    final name = _nameController.text.trim();
    // ignore: avoid_print
    print('DEBUG _createGame name="$name"');
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a game name')));
      return;
    }

    final gameId = 'game-${DateTime.now().microsecondsSinceEpoch}';

    final participants = [
      ParticipantEntry(id: 'you', name: 'You', avatarColorValue: AppColors.primary.toARGB32()),
      for (final f in _roster)
        ParticipantEntry(id: f.id, name: f.name, avatarColorValue: f.avatarColor.toARGB32()),
    ];

    final matchPlayers = [
      MatchPlayer(
        id: 'you',
        name: 'You',
        avatarColorValue: AppColors.primary.toARGB32(),
        roundScores: const [],
      ),
      for (final f in _roster)
        MatchPlayer(
          id: f.id,
          name: f.name,
          avatarColorValue: f.avatarColor.toARGB32(),
          roundScores: const [],
        ),
    ];

    final settingsBox = context.read<Box<GameSettings>>();
    final matchBox = context.read<Box<GameMatch>>();
    final gamesProvider = context.read<GamesProvider>();
    final navigator = Navigator.of(context);
    // ignore: avoid_print
    print('DEBUG about to write settings');

    await settingsBox.put(
      gameId,
      GameSettings(
        gameId: gameId,
        winningCondition: WinningCondition.highestScoreWins,
        allowNegativeScores: true,
        enableTimer: false,
        targetScore: 500,
        roundMultiplier: RoundMultiplier.x1,
        participants: participants,
      ),
    );
    // ignore: avoid_print
    print('DEBUG wrote settings, about to write match');

    await matchBox.put(gameId, GameMatch(gameId: gameId, name: name, players: matchPlayers));
    // ignore: avoid_print
    print('DEBUG wrote match, about to createGame');

    gamesProvider.createGame(
      id: gameId,
      name: name,
      icon: _categoryIcon,
      players: [
        PlayerScore(
          id: 'you',
          name: 'You',
          score: 0,
          isCurrentUser: true,
          avatarColor: AppColors.primary,
        ),
        for (final f in _roster)
          PlayerScore(id: f.id, name: f.name, score: 0, avatarColor: f.avatarColor),
      ],
    );
    // ignore: avoid_print
    print('DEBUG createGame done, mounted=$mounted, about to navigate');

    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => GameDashboardScreen(gameId: gameId, gameName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardMuted,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
        ),
        title: const Text(
          'New Game',
          style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const Text(
            'Game Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'GAME NAME',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
              hintText: 'e.g. Friday Night Catan',
              contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final category in _kCategories)
                _CategoryChip(
                  label: category,
                  selected: _selectedCategory == category,
                  onTap: () => setState(
                    () => _selectedCategory = _selectedCategory == category ? null : category,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Roster',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_roster.length} Selected',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _roster.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _DashedAddAvatar(onTap: _showAddCustomPlayerDialog);
                }
                final friend = _roster[index - 1];
                return _RosterAvatar(
                  friend: friend,
                  onRemove: () => _removeFromRoster(friend),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search friends...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.searchFill,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                for (final friend in _filteredAvailable) ...[
                  const Divider(height: 1, color: AppColors.inputBorder),
                  _FriendListTile(friend: friend, onAdd: () => _addFriend(friend)),
                ],
                for (final friend in _roster) ...[
                  const Divider(height: 1, color: AppColors.inputBorder),
                  _RosterListRow(
                    key: ValueKey(friend.id),
                    friend: friend,
                    onDelete: () => _removeFromRoster(friend),
                  ),
                ],
                const Divider(height: 1, color: AppColors.inputBorder),
                InkWell(
                  onTap: _showAddCustomPlayerDialog,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Add custom player...',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _createGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Create Game',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DashedAddAvatar extends StatelessWidget {
  const _DashedAddAvatar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedCirclePainter(color: AppColors.primary),
          child: const SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    const dashCount = 24;
    final radius = size.width / 2 - paint.strokeWidth / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const gapFraction = 0.5;
    final anglePerDash = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * anglePerDash,
        anglePerDash * gapFraction,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) => oldDelegate.color != color;
}

class _RosterAvatar extends StatelessWidget {
  const _RosterAvatar({required this.friend, required this.onRemove});

  final _RosterFriend friend;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: friend.avatarColor,
                child: Text(
                  friend.initials,
                  style: TextStyle(fontWeight: FontWeight.w700, color: friend.textColor),
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.negative,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            friend.firstName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FriendListTile extends StatelessWidget {
  const _FriendListTile({required this.friend, required this.onAdd});

  final _RosterFriend friend;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: friend.avatarColor,
            child: Text(
              friend.initials,
              style: TextStyle(fontWeight: FontWeight.w700, color: friend.textColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (friend.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    friend.subtitle!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onAdd,
            customBorder: const CircleBorder(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// A roster member row that reveals a delete button when swiped left.
class _RosterListRow extends StatefulWidget {
  const _RosterListRow({super.key, required this.friend, required this.onDelete});

  final _RosterFriend friend;
  final VoidCallback onDelete;

  @override
  State<_RosterListRow> createState() => _RosterListRowState();
}

class _RosterListRowState extends State<_RosterListRow> {
  static const double _actionWidth = 64;

  double _dragExtent = 0;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent = (_dragExtent + details.delta.dx).clamp(-_actionWidth, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _dragExtent = _dragExtent < -_actionWidth / 2 ? -_actionWidth : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: _actionWidth,
          child: InkWell(
            onTap: widget.onDelete,
            child: const Center(
              child: Icon(Icons.remove_circle_rounded, color: AppColors.negative, size: 28),
            ),
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: widget.friend.avatarColor,
                    child: Text(
                      widget.friend.initials,
                      style: TextStyle(fontWeight: FontWeight.w700, color: widget.friend.textColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.friend.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
