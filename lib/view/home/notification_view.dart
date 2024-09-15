import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/notification_row.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<Map<String, dynamic>> notificationArr = [];

  @override
  void initState() {
    super.initState();
    _fetchTodayWorkoutSchedule();
  }

  Future<void> _fetchTodayWorkoutSchedule() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'user_fitness_data.db');

  final db = await openDatabase(path);

  final today = DateTime.now();
  final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final List<Map<String, dynamic>> result = await db.query(
    'user_schedule',
    where: 'date = ?',
    whereArgs: [dateString],
  );

  // Convert result to the required format
  final notifications = result.map((row) {
    return {
      "image": "assets/img/Workout${row['id'] as int}.png", // Assuming workout_id is an int
      "title": row['workout'] as String, // Cast to String
      "time": '${row['time'] as String} on ${row['date'] as String}', // Cast to String
    };
  }).toList();

  setState(() {
    notificationArr = notifications;
  });
}

  @override
  Widget build(BuildContext context) {
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
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Notification",
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
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        itemBuilder: (context, index) {
          var nObj = notificationArr[index];
          return NotificationRow(nObj: nObj);
        },
        separatorBuilder: (context, index) {
          return Divider(color: TColor.gray.withOpacity(0.5), height: 1);
        },
        itemCount: notificationArr.length,
      ),
    );
  }
}
