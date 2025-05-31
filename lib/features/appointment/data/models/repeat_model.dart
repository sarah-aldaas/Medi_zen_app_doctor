class RepeatModel {
  final List<String> dayOfWeek;
  final String timeOfDay;
  final int duration;

  RepeatModel({
    required this.dayOfWeek,
    required this.timeOfDay,
    required this.duration,
  });

  factory RepeatModel.fromJson(Map<String, dynamic> json) {
    return RepeatModel(
      dayOfWeek: (json['dayOfWeek'] as List).cast<String>(),
      timeOfDay: json['timeOfDay'] as String,
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'timeOfDay': timeOfDay,
      'duration': duration,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RepeatModel &&
              dayOfWeek == other.dayOfWeek &&
              timeOfDay == other.timeOfDay &&
              duration == other.duration;

  @override
  int get hashCode => Object.hash(dayOfWeek, timeOfDay, duration);
}

