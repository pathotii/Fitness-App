import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../SQFLite/database_helper.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';
import '../login/user_schedule.dart';

class AddScheduleView extends StatefulWidget {
  final String userEmail;
  final VoidCallback onScheduleSaved;
  final DateTime date;

  const AddScheduleView(
      {super.key,
      required this.userEmail,
      required this.date,
      required this.onScheduleSaved});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  String selectedWorkout = 'Upperbody';
  String selectedDifficulty = 'Beginner';
  int? selectedRepetitions;
  double? selectedWeight;
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserSchedules();
  }

  Future<List<UserSchedule>> _fetchUserSchedules() async {
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;

  // Fetch user schedules based on email
  final List<Map<String, dynamic>> scheduleRecords = await db.query(
    'user_schedule',
    where: 'email = ?',
    whereArgs: [widget.userEmail], // Ensure widget.userEmail is correctly set
  );

  return List.generate(scheduleRecords.length, (i) {
    return UserSchedule.fromMap(scheduleRecords[i]);
  });
}


  Future<void> _fetchUserData() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    try {
      // Print the user's email to verify it's being passed correctly
      print('User email being fetched: ${widget.userEmail}');

      // Fetch user details
      print('Fetching data for email: ${widget.userEmail}');
      final List<Map<String, dynamic>> userRecords = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [widget.userEmail],
      );

      print('User Records: $userRecords');

      if (userRecords.isNotEmpty) {
        final List<Map<String, dynamic>> detailRecords = await db.query(
          'user_details',
          where: 'email = ?',
          whereArgs: [widget.userEmail],
        );

        print('Detail Records: $detailRecords');
      } else {
        print('No user records found for email: ${widget.userEmail}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Add Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Image.asset(
                "assets/img/date.png",
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                style: TextStyle(color: TColor.gray, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Time",
            style: TextStyle(
                color: TColor.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: media.width * 0.35,
            child: CupertinoDatePicker(
              onDateTimeChanged: (newDate) {
                setState(() {
                  selectedTime = newDate;
                });
              },
              initialDateTime: DateTime.now(),
              use24hFormat: false,
              minuteInterval: 1,
              mode: CupertinoDatePickerMode.time,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Details Workout",
            style: TextStyle(
                color: TColor.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 8,
          ),
          IconTitleNextRow(
              icon: "assets/img/choose_workout.png",
              title: "Choose Workout",
              time: selectedWorkout,
              color: TColor.lightGray,
              onPressed: () {
                _showWorkoutPicker(context);
              }),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/difficulity.png",
              title: "Difficulity",
              time: selectedDifficulty,
              color: TColor.lightGray,
              onPressed: () {
                _showDifficultyPicker(context);
              }),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/repetitions.png",
              title: "Custom Repetitions",
              time: selectedRepetitions != null
                  ? "$selectedRepetitions reps"
                  : "",
              color: TColor.lightGray,
              onPressed: () {
                _showRepetitionsPicker(context);
              }),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/repetitions.png",
              title: "Custom Weights",
              time: selectedWeight != null ? "$selectedWeight kg" : "",
              color: TColor.lightGray,
              onPressed: () {
                _showWeightsPicker(context);
              }),
          const Spacer(),
          RoundButton(
              title: "Save",
              onPressed: () {
                _saveSchedule();
              }),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }

  void _showRepetitionsPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: CupertinoPicker.builder(
                itemExtent: 40,
                selectionOverlay: Container(
                  width: double.maxFinite,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: TColor.gray.withOpacity(0.2), width: 1),
                      bottom: BorderSide(
                          color: TColor.gray.withOpacity(0.2), width: 1),
                    ),
                  ),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedRepetitions = (index + 1) * 12;
                  });
                },
                childCount: 15, // Set to 15 repetitions
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/img/repetitions.png",
                        width: 15,
                        height: 15,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        " ${index + 1} ",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        " set",
                        style: TextStyle(color: TColor.gray, fontSize: 16),
                      )
                    ],
                  );
                },
              ),
            ),
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightsPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: CupertinoPicker.builder(
                itemExtent: 40,
                selectionOverlay: Container(
                  width: double.maxFinite,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: TColor.gray.withOpacity(0.2), width: 1),
                      bottom: BorderSide(
                          color: TColor.gray.withOpacity(0.2), width: 1),
                    ),
                  ),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedWeight =
                        (index + 1).toDouble(); // Example weight increment
                  });
                },
                childCount: 150, // Adjust the number of items
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        " ${(index + 1)} kg",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Column(
          children: [
            Text(
              'Choose Workout',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18, // Adjust the font size as needed
              ),
            ),
            SizedBox(height: 5), // Add some spacing if needed
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Upperbody'),
            onPressed: () {
              setState(() {
                selectedWorkout = "Upperbody";
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Lowerbody'),
            onPressed: () {
              setState(() {
                selectedWorkout = "Lowerbody";
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Core'),
            onPressed: () {
              setState(() {
                selectedWorkout = "Core";
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Fullbody'),
            onPressed: () {
              setState(() {
                selectedWorkout = "Fullbody";
              });
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showDifficultyPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Column(
          children: [
            Text(
              'Choose Difficulty',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18, // Adjust the font size as needed
              ),
            ),
            SizedBox(height: 5), // Add some spacing if needed
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Beginner'),
            onPressed: () {
              setState(() {
                selectedDifficulty = "Beginner";
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Intermediate'),
            onPressed: () {
              setState(() {
                selectedDifficulty = "Intermediate";
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Expert'),
            onPressed: () {
              setState(() {
                selectedDifficulty = "Expert";
              });
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _saveSchedule() async {
    if (selectedTime == null ||
        selectedWorkout.isEmpty ||
        selectedDifficulty.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please complete all fields before saving.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      return;
    }

    print("Saving schedule with email: ${widget.userEmail}");

    // Save the schedule to the database
    final userSchedule = UserSchedule(
      email: widget.userEmail, 
      date: dateToString(widget.date),
      time: timeToString(selectedTime ?? DateTime.now()), // Convert DateTime to String
      workout: selectedWorkout,
      difficulty: selectedDifficulty,
      repetitions: selectedRepetitions ?? 0,
      weights: selectedWeight ?? 0,
    );

    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.insertUserSchedule(userSchedule);

      // Notify parent widget to refresh the list
      widget.onScheduleSaved();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Schedule saved successfully.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                printUserScheduleTable(); // Navigate back to the previous screen
              },
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error saving user schedule: $e");

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to save schedule. Please try again.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> insertUserSchedule(UserSchedule schedule) async {
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;
  await db.insert(
    'user_schedule',
    schedule.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  Future<void> printUserScheduleTable() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

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

  String dateToString(DateTime date, {String formatStr = "yyyy-MM-dd"}) {
    return DateFormat(formatStr).format(date);
  }

  String timeToString(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
