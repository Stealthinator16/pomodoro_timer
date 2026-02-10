enum TimerPhase { work, shortBreak, longBreak }

class TimerConfig {
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final bool soundEnabled;
  final bool autoStartNextPhase;

  const TimerConfig({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.soundEnabled = true,
    this.autoStartNextPhase = false,
  });

  TimerConfig copyWith({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
    bool? soundEnabled,
    bool? autoStartNextPhase,
  }) {
    return TimerConfig(
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoStartNextPhase: autoStartNextPhase ?? this.autoStartNextPhase,
    );
  }

  Map<String, dynamic> toJson() => {
        'workMinutes': workMinutes,
        'shortBreakMinutes': shortBreakMinutes,
        'longBreakMinutes': longBreakMinutes,
        'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
        'soundEnabled': soundEnabled,
        'autoStartNextPhase': autoStartNextPhase,
      };

  factory TimerConfig.fromJson(Map<String, dynamic> json) => TimerConfig(
        workMinutes: json['workMinutes'] as int? ?? 25,
        shortBreakMinutes: json['shortBreakMinutes'] as int? ?? 5,
        longBreakMinutes: json['longBreakMinutes'] as int? ?? 15,
        sessionsBeforeLongBreak:
            json['sessionsBeforeLongBreak'] as int? ?? 4,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        autoStartNextPhase: json['autoStartNextPhase'] as bool? ?? false,
      );

  int durationSeconds(TimerPhase phase) {
    switch (phase) {
      case TimerPhase.work:
        return workMinutes * 60;
      case TimerPhase.shortBreak:
        return shortBreakMinutes * 60;
      case TimerPhase.longBreak:
        return longBreakMinutes * 60;
    }
  }
}

class SessionRecord {
  final String date; // yyyy-MM-dd
  int sessionsCompleted;
  int totalFocusMinutes;

  SessionRecord({
    required this.date,
    this.sessionsCompleted = 0,
    this.totalFocusMinutes = 0,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'sessionsCompleted': sessionsCompleted,
        'totalFocusMinutes': totalFocusMinutes,
      };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
        date: json['date'] as String,
        sessionsCompleted: json['sessionsCompleted'] as int? ?? 0,
        totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
      );
}
