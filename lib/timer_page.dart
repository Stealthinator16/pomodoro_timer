import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'college_data.dart';
import 'gallery_screen.dart';
import 'models.dart';
import 'settings_sheet.dart';
import 'storage_service.dart';

class TimerPage extends StatefulWidget {
  final VoidCallback onThemeModePressed;
  final ThemeMode currentThemeMode;
  final StorageService storage;

  const TimerPage({
    super.key,
    required this.onThemeModePressed,
    required this.currentThemeMode,
    required this.storage,
  });

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  // --- State ---
  late TimerConfig _config;
  TimerPhase _phase = TimerPhase.work;
  int _completedWorkSessions = 0; // within current cycle
  late int _currentTimeInSeconds;
  late int _totalPhaseSeconds;
  Timer? _timer;
  bool _isRunning = false;
  int _bonusSeconds = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- Animations ---
  late AnimationController _popController;
  late Animation<double> _popAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _config = widget.storage.loadConfig();
    _totalPhaseSeconds = _config.durationSeconds(_phase);
    _currentTimeInSeconds = _totalPhaseSeconds;
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _popAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _popController, curve: Curves.fastOutSlowIn));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _popController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --- Timer Logic ---

  void _toggleTimer() {
    if (_isRunning) {
      // Pause
      _timer?.cancel();
      _pulseController.stop();
      _pulseController.reset();
      setState(() => _isRunning = false);
    } else {
      if (_currentTimeInSeconds <= 0) {
        _advancePhase();
        return;
      }
      // Start
      setState(() => _isRunning = true);
      _pulseController.repeat(reverse: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_currentTimeInSeconds > 0) {
          if (mounted) setState(() => _currentTimeInSeconds--);
        } else {
          _onTimerComplete();
        }
      });
    }
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    if (_phase == TimerPhase.work) {
      _completedWorkSessions++;
      final totalBefore = widget.storage.totalSessions();
      widget.storage.recordWorkSession(_config.workMinutes + (_bonusSeconds ~/ 60));
      final totalAfter = widget.storage.totalSessions();
      final newlyUnlocked = getNewlyUnlocked(totalBefore, totalAfter);
      if (newlyUnlocked.isNotEmpty && mounted) {
        final college = newlyUnlocked.first;
        Future.microtask(() {
          if (mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Campus Unlocked! \u{1f389}'),
                content: Text('You unlocked ${college.name}!\nHead to the gallery to explore.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Nice!'),
                  ),
                ],
              ),
            );
          }
        });
      }
    }

    if (_config.soundEnabled) _playAlarm();

    if (mounted) {
      setState(() => _isRunning = false);
    }

    if (_config.autoStartNextPhase) {
      _advancePhase();
      // Auto-start the next phase
      Future.microtask(() => _toggleTimer());
    }
  }

  void _advancePhase() {
    TimerPhase nextPhase;
    if (_phase == TimerPhase.work) {
      if (_completedWorkSessions >= _config.sessionsBeforeLongBreak) {
        nextPhase = TimerPhase.longBreak;
      } else {
        nextPhase = TimerPhase.shortBreak;
      }
    } else {
      // After any break, go back to work
      if (_phase == TimerPhase.longBreak) {
        _completedWorkSessions = 0; // Reset cycle
      }
      nextPhase = TimerPhase.work;
    }
    _setPhase(nextPhase);
  }

  void _setPhase(TimerPhase phase) {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    final seconds = _config.durationSeconds(phase);
    if (mounted) {
      setState(() {
        _phase = phase;
        _totalPhaseSeconds = seconds;
        _currentTimeInSeconds = seconds;
        _isRunning = false;
        _bonusSeconds = 0;
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    final seconds = _config.durationSeconds(_phase);
    if (mounted) {
      setState(() {
        _currentTimeInSeconds = seconds;
        _totalPhaseSeconds = seconds;
        _isRunning = false;
        _bonusSeconds = 0;
      });
    }
  }

  void _playAlarm() async {
    try {
      await _audioPlayer.play(AssetSource('alarm.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play notification sound.')),
        );
      }
    }
  }

  void _onConfigChanged(TimerConfig newConfig) {
    widget.storage.saveConfig(newConfig);
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _config = newConfig;
      _totalPhaseSeconds = newConfig.durationSeconds(_phase);
      _currentTimeInSeconds = _totalPhaseSeconds;
      _isRunning = false;
    });
  }

  // --- Formatting ---

  String _formatTime() {
    int minutes = _currentTimeInSeconds ~/ 60;
    int seconds = _currentTimeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _phaseLabel() {
    switch (_phase) {
      case TimerPhase.work:
        return 'Work';
      case TimerPhase.shortBreak:
        return 'Short Break';
      case TimerPhase.longBreak:
        return 'Long Break';
    }
  }

  String _statusText() {
    if (_currentTimeInSeconds <= 0) return 'Done!';
    if (_isRunning) {
      return _phase == TimerPhase.work ? 'Stay Focused!' : 'Relax...';
    }
    return 'Ready?';
  }

  Color _phaseColor(ColorScheme colors) {
    switch (_phase) {
      case TimerPhase.work:
        return colors.primary;
      case TimerPhase.shortBreak:
        return Colors.teal;
      case TimerPhase.longBreak:
        return Colors.indigo.shade300;
    }
  }

  IconData _themeIcon() {
    switch (widget.currentThemeMode) {
      case ThemeMode.light:
        return Icons.dark_mode_outlined;
      case ThemeMode.dark:
        return Icons.light_mode_outlined;
      case ThemeMode.system:
        return Icons.light_mode_outlined;
    }
  }

  String _themeTooltip() {
    switch (widget.currentThemeMode) {
      case ThemeMode.light:
        return 'Switch to Dark Theme';
      case ThemeMode.dark:
        return 'Switch to System Theme';
      case ThemeMode.system:
        return 'Switch to Light Theme';
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final phaseColor = _phaseColor(colors);

    final progress = _totalPhaseSeconds > 0
        ? 1.0 - (_currentTimeInSeconds / _totalPhaseSeconds)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Campus Gallery',
            onPressed: () => _openGallery(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => _showSettings(context),
          ),
          IconButton(
            icon: Icon(_themeIcon()),
            tooltip: _themeTooltip(),
            onPressed: widget.onThemeModePressed,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phase label & session counter
            Text(
              _phaseLabel(),
              style: textTheme.titleMedium?.copyWith(
                color: phaseColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_phase == TimerPhase.work)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Session ${_completedWorkSessions + 1} of ${_config.sessionsBeforeLongBreak}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Status text
            Text(
              _statusText(),
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 30),

            // Timer with progress ring
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress ring
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: _ProgressRingPainter(
                        progress: progress,
                        color: phaseColor,
                        trackColor: colors.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  // Timer text
                  ScaleTransition(
                    scale: _popAnimation,
                    child: Text(
                      _formatTime(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'TimerFont',
                        color: textTheme.displayMedium?.color,
                        fontSize: 72.0,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  iconSize: 35,
                  tooltip: 'Reset Timer',
                  onPressed: _resetTimer,
                ),
                const SizedBox(width: 30),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      shape: const CircleBorder(),
                      backgroundColor: phaseColor,
                      foregroundColor: colors.onPrimary,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child:
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        size: 45,
                        key: ValueKey(_isRunning),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: 35,
                  tooltip: 'Add 10 minutes',
                  onPressed: _addTenMinutes,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTenMinutes() {
    setState(() {
      _currentTimeInSeconds += 600;
      _totalPhaseSeconds += 600;
      _bonusSeconds += 600;
    });
    _popController.forward(from: 0);
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SettingsSheet(
        config: _config,
        onConfigChanged: _onConfigChanged,
      ),
    );
  }

  void _openGallery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GalleryScreen(storage: widget.storage),
      ),
    );
  }
}

// --- Progress Ring Painter ---

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 8.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.color != color;
}
