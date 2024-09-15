import 'package:fit_pair/common_widget/tab_button.dart';
import 'package:fit_pair/view/profile/profile_view.dart';
import 'package:fit_pair/view/workout_tracker/workout_tracker_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../SQFLite/database_helper.dart';
import '../../common/colo_extension.dart';
import '../home/home_view.dart';

class MainTabView extends StatefulWidget {
  final String userEmail;
  const MainTabView({super.key, required this.userEmail});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket();
  String? firstName;
  String? height;
  String? weight;
  String? dateOfBirth;
  int? age;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Fetch user details from the 'users' table
    final List<Map<String, dynamic>> userRecords = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [widget.userEmail],
    );

    if (userRecords.isNotEmpty) {
      final userRecord = userRecords.first;
      firstName = userRecord['firstName'];
    }

    // Fetch user details from the 'user_details' table
    final List<Map<String, dynamic>> detailRecords = await db.query(
      'user_details',
      where: 'email = ?',
      whereArgs: [widget.userEmail],
    );

    if (detailRecords.isNotEmpty) {
      final detailRecord = detailRecords.first;
      setState(() {
        height = detailRecord['height'].toString();
        weight = detailRecord['weight'].toString();
        dateOfBirth = detailRecord['dateOfBirth']; // Fetch date of birth
        age = _calculateAge(
            dateOfBirth); // Calculate age based on the date of birth
        isLoading = false;
      });
    }
  }

  int _calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    try {
      // Use DateFormat to parse the date
      final DateFormat dateFormat = DateFormat('MM/dd/yyyy');
      DateTime dob = dateFormat.parse(dateOfBirth);
      DateTime today = DateTime.now();
      int age = today.year - dob.year;

      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      return age;
    } catch (e) {
      print("Error parsing date of birth: $dateOfBirth");
      print(e); // Print error if date parsing fails
      return 0; // Default value in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(
        bucket: pageBucket,
        child: IndexedStack(
          index: selectTab,
          children: [
            HomeView(userEmail: widget.userEmail),
            WorkoutTrackerView(userEmail: widget.userEmail),
            ProfileView(
                userEmail: widget.userEmail,
                height: height,
                weight: weight,
                age: age),
            ProfileView(
                userEmail: widget.userEmail,
                height: height,
                weight: weight,
                age: age),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: InkWell(
          onTap: () {},
          child: Container(
            width: 65,
            height: 50,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: TColor.primaryG,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                  )
                ]),
            child: Icon(Icons.search, color: TColor.white, size: 35),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(color: TColor.white, boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 2, offset: Offset(0, -2))
          ]),
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                  icon: "assets/img/home_tab.png",
                  selectIcon: "assets/img/home_tab_select.png",
                  isActive: selectTab == 0,
                  onTap: () {
                    setState(() {
                      selectTab = 0;
                    });
                  }),
              TabButton(
                  icon: "assets/img/activity_tab.png",
                  selectIcon: "assets/img/activity_tab_select.png",
                  isActive: selectTab == 1,
                  onTap: () {
                    setState(() {
                      selectTab = 1;
                    });
                  }),
              const SizedBox(
                width: 30,
              ),
              TabButton(
                  icon: "assets/img/camera_tab.png",
                  selectIcon: "assets/img/camera_tab_select.png",
                  isActive: selectTab == 2,
                  onTap: () {
                    setState(() {
                      selectTab = 2;
                    });
                  }),
              TabButton(
                  icon: "assets/img/profile_tab.png",
                  selectIcon: "assets/img/profile_tab_select.png",
                  isActive: selectTab == 3,
                  onTap: () {
                    setState(() {
                      selectTab = 3;
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
