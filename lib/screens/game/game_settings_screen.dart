import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/participant_entry.dart';
import '../../data/models/round_multiplier.dart';
import '../../data/models/winning_condition.dart';
import '../../providers/game_settings_provider.dart';
import '../../theme/app_theme.dart';

class GameSettingsScreen extends StatelessWidget {
  const GameSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Game Settings',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.check, color: AppColors.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: const [
          _SectionHeader(icon: Icons.flag_rounded, label: 'Game Rules'),
          SizedBox(height: 12),
          _GameRulesCard(),
          SizedBox(height: 28),
          _SectionHeader(icon: Icons.functions_rounded, label: 'Scoring'),
          SizedBox(height: 12),
          _ScoringCard(),
          SizedBox(height: 28),
          _SectionHeader(icon: Icons.groups_rounded, label: 'Participants'),
          SizedBox(height: 12),
          _ParticipantsSection(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.inputBorder),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _GameRulesCard extends StatelessWidget {
  const _GameRulesCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameSettingsProvider>();
    final settings = provider.settings;

    return _SettingsCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RowLabel(icon: Icons.emoji_events_outlined, label: 'Winning Condition'),
              const SizedBox(height: 10),
              _DropdownField<WinningCondition>(
                value: settings.winningCondition,
                items: WinningCondition.values,
                labelBuilder: (c) => c.label,
                onChanged: (value) {
                  if (value != null) provider.setWinningCondition(value);
                },
              ),
            ],
          ),
        ),
        _ToggleRow(
          icon: Icons.exposure_rounded,
          title: 'Allow Negative Scores',
          subtitle: 'Players can fall below zero',
          value: settings.allowNegativeScores,
          onChanged: provider.setAllowNegativeScores,
        ),
        _ToggleRow(
          icon: Icons.timer_outlined,
          title: 'Enable Timer',
          subtitle: 'Limit turn duration',
          value: settings.enableTimer,
          onChanged: provider.setEnableTimer,
        ),
      ],
    );
  }
}

class _ScoringCard extends StatelessWidget {
  const _ScoringCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameSettingsProvider>();
    final settings = provider.settings;

    return _SettingsCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RowLabel(icon: Icons.outlined_flag_rounded, label: 'Target Score'),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: '${settings.targetScore}',
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                ),
                onFieldSubmitted: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) provider.setTargetScore(parsed);
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RowLabel(icon: Icons.close_rounded, label: 'Round Multiplier'),
              const SizedBox(height: 10),
              _DropdownField<RoundMultiplier>(
                value: settings.roundMultiplier,
                items: RoundMultiplier.values,
                labelBuilder: (c) => c.label,
                onChanged: (value) {
                  if (value != null) provider.setRoundMultiplier(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(labelBuilder(item))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ParticipantsSection extends StatelessWidget {
  const _ParticipantsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameSettingsProvider>();
    final participants = provider.settings.participants;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardMuted,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              for (int i = 0; i < participants.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.inputBorder),
                _ParticipantRow(
                  participant: participants[i],
                  onRemove: () => provider.removeParticipant(participants[i].id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => _showAddParticipantDialog(context, provider),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.primaryLight, style: BorderStyle.solid),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add Player', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Future<void> _showAddParticipantDialog(
    BuildContext context,
    GameSettingsProvider provider,
  ) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Player'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Player name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await provider.addParticipant(name);
    }
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({required this.participant, required this.onRemove});

  final ParticipantEntry participant;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator_rounded, color: AppColors.textMuted),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(participant.avatarColorValue),
            child: Text(
              participant.initial,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              participant.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.person_remove_outlined, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
