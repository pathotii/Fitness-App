class UserSchedule {
  final int? id;
  final String? date;
  final String? time;
  final String? workout;
  final String? difficulty;
  final int? repetitions;
  final double? weights;
  final String email;

  UserSchedule({
    this.id,
    this.date,
    this.time,
    this.workout,
    this.difficulty,
    this.repetitions,
    this.weights,
    required this.email,
  });

  factory UserSchedule.fromMap(Map<String, dynamic> json) {
    return UserSchedule(
      id: json['id'] as int?,
      date: json['date'] as String?, // Read date as String
      time: json['time'] as String?, // Read time as String
      workout: json['workout'] as String?,
      difficulty: json['difficulty'] as String?,
      repetitions: json['repetitions'] as int?,
      weights: json['weights'] != null ? (json['weights'] as num).toDouble() : null,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date, // Store date as String
      'time': time, // Store time as String
      'workout': workout,
      'difficulty': difficulty,
      'repetitions': repetitions,
      'weights': weights,
      'email': email,
    };
  }
}
