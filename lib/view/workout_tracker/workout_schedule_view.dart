import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';

import '../../SQFLite/database_helper.dart';
import '../../common/colo_extension.dart';
import '../login/user_schedule.dart';
import 'add_schedule_view.dart';

class WorkoutScheduleView extends StatefulWidget {
  final String userEmail;
  const WorkoutScheduleView({super.key, required this.userEmail});

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  DateTime _selectedDateAppBBar = DateTime.now();
  List<Map<String, dynamic>> selectDayEventArr = [];

  Future<void> _fetchUserData() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    try {
      final List<Map<String, dynamic>> userRecords = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [widget.userEmail],
      );

      if (userRecords.isNotEmpty) {
        final List<Map<String, dynamic>> detailRecords = await db.query(
          'user_details',
          where: 'email = ?',
          whereArgs: [widget.userEmail],
        );

        print('User Records: $userRecords');
        print('Detail Records: $detailRecords');
      }
    } catch (e) {
      // Handle errors (e.g., show a message to the user)
      print("Error fetching user data: $e");
    }
  }

  void refreshScheduleList() {
    setState(() {
      setDayEventWorkoutList();
    });
  }

  Future<List<UserSchedule>> _fetchUserSchedules() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    try {
      final List<Map<String, dynamic>> scheduleRecords = await db.query(
        'user_schedule',
        where: 'email = ?',
        whereArgs: [widget.userEmail],
      );

      return List.generate(scheduleRecords.length, (i) {
        return UserSchedule.fromMap(scheduleRecords[i]);
      });
    } catch (e) {
      print("Error fetching user schedules: $e");
      return [];
    }
  }

  void setDayEventWorkoutList() async {
    List<UserSchedule> schedules = await _fetchUserSchedules();

    Map<String, String> timeSlotWorkouts = {};

    for (var schedule in schedules) {
      if (schedule.date != null && schedule.time != null) {
        DateTime scheduleDate = DateTime.parse(schedule.date!);
        if (scheduleDate.year == _selectedDateAppBBar.year &&
            scheduleDate.month == _selectedDateAppBBar.month &&
            scheduleDate.day == _selectedDateAppBBar.day) {
          timeSlotWorkouts[schedule.time!] = schedule.workout ?? 'No workout';
        }
      }
    }

    setState(() {
      selectDayEventArr = List.generate(24, (index) {
        String timeSlot = getTime(index * 60);

        return {
          "time": timeSlot,
          "workout": timeSlotWorkouts[timeSlot] ?? 'No workout',
        };
      });
    });

    printUserSchedule();
  }

  void printUserSchedule() {
    print("Current user schedules:");
    selectDayEventArr.forEach((schedule) {
      print(schedule);
    });
  }

  void printTimeSlots() {
    List<Map<String, dynamic>> timeSlots = List.generate(24, (index) {
      String timeSlot = getTime(index * 60);
      return {
        "time": timeSlot,
        "workout":
            "No workout", // Default value, can be replaced with actual data if available
      };
    });

    print("Time Slots:");
    for (var slot in timeSlots) {
      print("Time: ${slot["time"]}, Workout: ${slot["workout"]}");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserSchedules().then((_) {
      setDayEventWorkoutList();
      printTimeSlots(); // Print time slots on initialization
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset("assets/img/black_btn.png", width: 15, height: 15),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Workout Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Image.asset("assets/img/more_btn.png", width: 15, height: 15),
            onPressed: () {},
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            appbar: false,
            selectedDayPosition: SelectedDayPosition.center,
            leading: IconButton(
                icon: Image.asset("assets/img/ArrowLeft.png",
                    width: 15, height: 15),
                onPressed: () {}),
            training: IconButton(
                icon: Image.asset("assets/img/ArrowRight.png",
                    width: 15, height: 15),
                onPressed: () {}),
            weekDay: WeekDay.short,
            dayNameFontSize: 12,
            dayNumberFontSize: 16,
            dayBGColor: Colors.grey.withOpacity(0.15),
            titleSpaceBetween: 15,
            backgroundColor: Colors.transparent,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,
            locale: 'en',
            initialDate: DateTime.now(),
            calendarEventColor: TColor.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),
            onDateSelected: (date) {
              setState(() {
                _selectedDateAppBBar = date;
                setDayEventWorkoutList();
              });
            },
            selectedDayLogo: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: media.width * 1.5,
                child: ListView.builder(
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    var timeSlot = getTime(index * 60);
                    var workout = selectDayEventArr.firstWhere(
                        (event) => event["time"] == timeSlot,
                        orElse: () => {"workout": "No Schedule"})["workout"];
                    bool hasWorkout = workout != 'No workout';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasWorkout
                            ? TColor.primaryColor2
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: hasWorkout ? Colors.transparent : Colors.grey,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time slot text
                          Expanded(
                            child: Text(
                              timeSlot,
                              style: TextStyle(
                                fontSize: 16,
                                color: TColor.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                workout,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: TColor.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColor.primaryColor1,
        onPressed: () {
          // Trigger the printTimeSlots method
          printTimeSlots();
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  String getTime(int minutes) {
    int hour = minutes ~/ 60;
    int minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
