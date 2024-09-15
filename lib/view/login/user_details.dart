import 'package:intl/intl.dart';

class UserDetails {
  final String email;
  final String gender;
  final String dateOfBirth; // Store as a string in 'YYYY-MM-DD' format
  final double weight; // in kg
  final double height; // in cm
  late final double bmi;
  late final int age;

  UserDetails({
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    required this.weight,
    required this.height,
  }) {
    bmi = _calculateBMI();
    age = _calculateAge();
  }

  int _calculateAge() {
    final birthDate = DateFormat('yyyy-MM-dd').parse(dateOfBirth);
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Method to calculate BMI
  double _calculateBMI() {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Convert UserDetails object to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'age': age,
    };
  }

  // Create a UserDetails object from a Map (database query)
  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      email: map['email'],
      gender: map['gender'],
      dateOfBirth: map['date_of_birth'],
      weight: map['weight'],
      height: map['height'],
    );
  }
}
