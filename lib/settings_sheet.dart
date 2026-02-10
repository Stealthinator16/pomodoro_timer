import 'package:flutter/material.dart';
import 'models.dart';

class SettingsSheet extends StatefulWidget {
  final TimerConfig config;
  final ValueChanged<TimerConfig> onConfigChanged;

  const SettingsSheet({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TimerConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  void _update(TimerConfig newConfig) {
    setState(() => _config = newConfig);
    widget.onConfigChanged(newConfig);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Settings',
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Work',
            value: _config.workMinutes,
            min: 1,
            max: 60,
            suffix: 'min',
            onChanged: (v) => _update(_config.copyWith(workMinutes: v)),
          ),
          _buildSlider(
            label: 'Short Break',
            value: _config.shortBreakMinutes,
            min: 1,
            max: 30,
            suffix: 'min',
            onChanged: (v) => _update(_config.copyWith(shortBreakMinutes: v)),
          ),
          _buildSlider(
            label: 'Long Break',
            value: _config.longBreakMinutes,
            min: 1,
            max: 60,
            suffix: 'min',
            onChanged: (v) => _update(_config.copyWith(longBreakMinutes: v)),
          ),
          _buildSlider(
            label: 'Sessions before long break',
            value: _config.sessionsBeforeLongBreak,
            min: 1,
            max: 8,
            suffix: '',
            onChanged: (v) =>
                _update(_config.copyWith(sessionsBeforeLongBreak: v)),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('Sound', style: textTheme.bodyLarge),
            value: _config.soundEnabled,
            onChanged: (v) => _update(_config.copyWith(soundEnabled: v)),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text('Auto-start next phase', style: textTheme.bodyLarge),
            value: _config.autoStartNextPhase,
            onChanged: (v) => _update(_config.copyWith(autoStartNextPhase: v)),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required int value,
    required int min,
    required int max,
    required String suffix,
    required ValueChanged<int> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: textTheme.bodyLarge),
              Text('$value${suffix.isNotEmpty ? ' $suffix' : ''}',
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
