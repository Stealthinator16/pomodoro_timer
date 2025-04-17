import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

const int totalSeconds = 25 * 60; // 25 minutes

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Timer',
      theme: ThemeData.dark().copyWith( // Use a dark theme
        scaffoldBackgroundColor: const Color(0xFF2c3e50),
      ),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  int _remainingSeconds = totalSeconds;
  bool _isActive = false;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer(); // Initialize timer state
  }

 @override
 void didChangeAppLifecycleState(AppLifecycleState state) {
     super.didChangeAppLifecycleState(state);
     if (state == AppLifecycleState.resumed) {
         // App came to foreground
         print("App Resumed");
          // Reset timer only if it wasn't running
          if (!_isActive) {
             setState(() {
                  _resetTimer();
             });
          }
     } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
         // App went to background or became inactive
         // Optional: You might want to pause the timer here if it's running
         // if (_isActive) {
         //   _pauseTimer();
         // }
     }
 }


  void _resetTimer() {
    _timer?.cancel(); // Cancel any existing timer
    setState(() {
      _remainingSeconds = totalSeconds;
      _isActive = false;
    });
  }

   void _pauseTimer() {
     _timer?.cancel();
     setState(() {
         _isActive = false;
     });
   }


  void _startTimer() {
    if (_isActive || _remainingSeconds == 0) return; // Don't start if already active or finished

    setState(() {
      _isActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isActive = false;
        });
        _playSound();
        // Optional: Auto-reset after sound plays
        // Future.delayed(Duration(seconds: 3), () => _resetTimer());
      }
    });
  }

  Future<void> _playSound() async {
    print('Playing sound');
    try {
      // For local assets, use AssetSource
      await _audioPlayer.play(AssetSource('alarm.mp3')); // Assuming alarm.mp3 is in assets/
      print('Sound played');
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel(); // Clean up timer
    _audioPlayer.dispose(); // Clean up audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _startTimer, // Start timer on tap
        child: Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFecf0f1), // Light grey border
                width: 5,
              ),
            ),
            child: Center(
              child: Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFecf0f1), // Light grey text
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}