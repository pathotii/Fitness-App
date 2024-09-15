import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../view/login/user.dart';
import '../view/login/user_schedule.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<int> deleteSchedulesByEmail(String email) async {
    final db = await database;

    // Perform the delete operation
    final result = await db.delete(
      'user_schedule', // The table name
      where: 'email = ?', // The WHERE clause
      whereArgs: [email], // The WHERE arguments (email in this case)
    );

    // Print the result to check if records were deleted
    print('Number of records deleted: $result');

    return result;
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await Future.wait([
      db.delete('users'),
      db.delete('user_details'),
      db.delete('user_schedule'),
    ]);
    print("All data deleted from users and user_details");
  }

  Future<List<Map<String, dynamic>>> getUserDetailsContents() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('user_details');
    return result;
  }

  Future<void> _printUserDetailsContents() async {
    try {
      List<Map<String, dynamic>> userDetails = await getUserDetailsContents();
      for (var row in userDetails) {
        print(row.entries.map((e) => '${e.key}: ${e.value}').join(', '));
      }
    } catch (e) {
      print("Error retrieving user details: $e");
    }
  }

  Future<void> _addAgeColumn(Database db) async {
    await db.execute('ALTER TABLE user_details ADD COLUMN age INTEGER');
  }

  // Function to check if the 'age' column exists
  Future<bool> _columnExists(Database db, String columnName) async {
    final List<Map<String, dynamic>> result =
        await db.rawQuery('PRAGMA table_info(user_details)');
    return result.any((column) => column['name'] == columnName);
  }

  Future<void> checkAndUpdateSchema() async {
    final db = await database;

    // Check if the 'age' column already exists
    if (!await _columnExists(db, 'age')) {
      await _addAgeColumn(db);
    }

    // Check if there are any non-null rows for the 'age' column
    await _printAgeColumnData(db);
  }

  Future<void> _printAgeColumnData(Database db) async {
    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT age FROM user_details WHERE age IS NOT NULL');

    if (result.isNotEmpty) {
      print('There are ${result.length} rows with a non-null age value.');
    } else {
      print('No rows with a non-null age value found.');
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_fitness_data.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        // Create tables
        return Future.wait([
          db.execute(
            'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT, lastName TEXT, email TEXT UNIQUE, password TEXT)',
          ),
          db.execute(
            'CREATE TABLE user_details(email TEXT PRIMARY KEY, firstName TEXT, gender TEXT, dateOfBirth TEXT, weight REAL, height REAL, bmi REAL, age INTEGER)',
          ),
          db.execute(
            'CREATE TABLE user_health(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, heartRate REAL, calories REAL, caloriesBurned REAL, sleepTime REAL, FOREIGN KEY(email) REFERENCES user_details(email))',
          ),
          db.execute(
            'CREATE TABLE user_schedule(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT NOT NULL, date TEXT NOT NULL, time TEXT NOT NULL, workout TEXT, difficulty TEXT, repetitions INTEGER, weights REAL, FOREIGN KEY(email) REFERENCES users(email))',
          ),
        ]);
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Handle database upgrade
      },
      version: 3, // Increment version for schema changes
    );
  }

  Future<void> createUserHealthTable() async {
    final db = await database;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS user_health(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, heartRate REAL, calories REAL, caloriesBurned REAL, sleepTime REAL, FOREIGN KEY(email) REFERENCES user_details(email))',
    );
  }

  Future<void> createUserScheduleTable() async {
    final db = await database;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS user_schedule(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT NOT NULL, date TEXT NOT NULL, time TEXT NOT NULL, workout TEXT, difficulty TEXT, repetitions INTEGER, weights REAL, FOREIGN KEY(email) REFERENCES users(email))',
    );
  }

  Future<void> updateUserScheduleTable() async {
  final db = await database;

  // Start a transaction to ensure everything happens atomically
  await db.transaction((txn) async {
    // Step 1: Create the new table without NOT NULL constraints
    await txn.execute(
      'CREATE TABLE IF NOT EXISTS user_schedule_new('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'email TEXT, '
      'date TEXT, '
      'time TEXT, '
      'workout TEXT, '
      'difficulty TEXT, '
      'repetitions INTEGER, '
      'weights REAL, '
      'FOREIGN KEY(email) REFERENCES users(email))',
    );

    // Step 2: Copy data from the old table to the new one
    await txn.execute(
      'INSERT INTO user_schedule_new (id, email, date, time, workout, difficulty, repetitions, weights) '
      'SELECT id, email, date, time, workout, difficulty, repetitions, weights FROM user_schedule',
    );

    // Step 3: Drop the old table
    await txn.execute('DROP TABLE IF EXISTS user_schedule');

    // Step 4: Rename the new table to the original name
    await txn.execute('ALTER TABLE user_schedule_new RENAME TO user_schedule');
  });
}

Future<void> printUserScheduleTable() async {
  final db = await database;

  // Fetch all rows from user_schedule table
  final List<Map<String, dynamic>> result = await db.query('user_schedule');

  if (result.isNotEmpty) {
    print('Rows in user_schedule table:');
    for (var row in result) {
      print(row); // Print each row as a Map
    }
  } else {
    print('No rows found in user_schedule table.');
  }
}

  Future<void> createUserDetailsTable() async {
    final db = await database;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS user_details(email TEXT PRIMARY KEY, firstName TEXT, gender TEXT, dateOfBirth TEXT, weight REAL, height REAL, bmi REAL, age INTEGER)',
    );
  }

  Future<List<String>> getExistingTables() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.rawQuery('PRAGMA table_list');

    List<String> tables = [];
    for (var row in result) {
      tables.add(row['name'] as String);
    }
    print(tables);
    return tables;
  }

  Future<void> printUserScheduleByEmail(String email) async {
  final db = await database;

  // Fetch the schedules from user_schedule using the email as the key
  final List<Map<String, dynamic>> scheduleMaps = await db.query(
    'user_schedule',
    where: 'email = ?',
    whereArgs: [email],
  );

  // If schedules exist for the user
  if (scheduleMaps.isNotEmpty) {
    print('User Schedules for email: $email');
    scheduleMaps.forEach((map) {
      final schedule = UserSchedule.fromMap(map);
      print(
          'Schedule ID: ${schedule.id}, Date: ${schedule.date}, Time: ${schedule.time}, Workout: ${schedule.workout}, Difficulty: ${schedule.difficulty}, Repetitions: ${schedule.repetitions}, Weights: ${schedule.weights}');
    });
  } else {
    print('No schedules found for email: $email');
  }
}

  Future<void> insertUserSchedule(UserSchedule userSchedule) async {
    final db = await database;

    
    try {
      final id = await db.insert(
        'user_schedule',
        userSchedule.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("User schedule inserted with id: $id");
    } catch (e) {
      print("Error inserting user schedule: $e");
    }
  }

  Future<String?> getUserFirstName(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      columns: ['firstName'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return maps.first['firstName'] as String?;
    } else {
      return null;
    }
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    int id = await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("User inserted with id: $id"); // Add this line to confirm insertion
  }

  Future<void> insertUserHealth({
    required String email,
    required double heartRate,
    required double calories,
    required double caloriesBurned,
    required double sleepTime,
  }) async {
    try {
      final db = await database;
      await db.insert(
        'user_health',
        {
          'email': email,
          'heartRate': heartRate,
          'calories': calories,
          'caloriesBurned': caloriesBurned,
          'sleepTime': sleepTime,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting user health data: $e");
    }
  }

  Future<void> _loginWithFacebook(BuildContext context) async {
    final result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final accessToken = result.accessToken?.token;
      // Use this access token for Facebook-specific features
      print("Facebook login successful. Access Token: $accessToken");
    } else {
      // If login fails, show an alert dialog
      String message = "Facebook login failed. Please try again.";
      if (result.status == LoginStatus.cancelled) {
        message = "Facebook login was cancelled.";
      } else if (result.status == LoginStatus.failed) {
        message = "Facebook login failed. Register instead.";
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Failed"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to registration screen or other appropriate action
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> insertUserDetails({
    required String email,
    required String firstName,
    required String gender,
    required String dateOfBirth,
    required double weight,
    required double height,
    required double bmi,
    required int age,
  }) async {
    try {
      final db = await database;
      final result = await db.insert(
        'user_details',
        {
          'email': email,
          'firstName': firstName,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'weight': weight,
          'height': height,
          'bmi': bmi,
          'age': age,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Inserted user details with result: $result");
    } catch (e) {
      print("Error inserting user details: $e");
    }
  }

  Future<void> printUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query('users');

    for (var user in users) {
      print(
          'ID: ${user['id']}, First Name: ${user['firstName']}, Last Name: ${user['lastName']}, Email: ${user['email']}, Password: ${user['password']}');
    }
  }

  Future<void> printUserHealth() async {
    final db = await database;
    final List<Map<String, dynamic>> userHealth = await db.query('user_health');

    for (var health in userHealth) {
      print(
          'ID: ${health['id']}, Email: ${health['email']}, Heart Rate: ${health['heartRate']}, Calories: ${health['calories']}, Calories Burned: ${health['caloriesBurned']}, Sleep Time: ${health['sleepTime']}');
    }
  }

  Future<void> printUserDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> userDetails =
        await db.query('user_details');

    for (var detail in userDetails) {
      print(
          'ID: ${detail['id']}, Email: ${detail['email']}, First Name: ${detail['firstName']}, Gender: ${detail['gender']}, Date of Birth: ${detail['dateOfBirth']}, Weight: ${detail['weight']}, Height: ${detail['height']}, BMI: ${detail['bmi']}');
    }
  }

  Future<List<User>> users() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        firstName: maps[i]['firstName'],
        lastName: maps[i]['lastName'],
        email: maps[i]['email'],
        password: maps[i]['password'],
      );
    });
  }
}
