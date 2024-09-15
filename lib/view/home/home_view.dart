import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fit_pair/common_widget/round_button.dart';
import 'package:fit_pair/view/home/activity_tracker_view.dart';
import 'package:fit_pair/view/home/notification_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '../../SQFLite/database_helper.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/workout_row.dart';

class HomeView extends StatefulWidget {
  final String userEmail;

  const HomeView({super.key, required this.userEmail});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List lastWorkoutArr = [
    {
      "name": "Full Body Workout",
      "image": "assets/img/Workout1.png",
      "kcal": "180",
      "time": "20",
      "progress": 0.3
    },
    {
      "name": "Lower Body Workout",
      "image": "assets/img/Workout2.png",
      "kcal": "200",
      "time": "30",
      "progress": 0.4
    },
    {
      "name": "Ab Workout",
      "image": "assets/img/Workout3.png",
      "kcal": "300",
      "time": "40",
      "progress": 0.7
    },
  ];

  List<int> showingTooltipOnSpots = [21];

  List<FlSpot> get allSpots => const [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 40),
        FlSpot(3, 50),
        FlSpot(4, 35),
        FlSpot(5, 40),
        FlSpot(6, 30),
        FlSpot(7, 20),
        FlSpot(8, 25),
        FlSpot(9, 40),
        FlSpot(10, 50),
        FlSpot(11, 35),
        FlSpot(12, 50),
        FlSpot(13, 60),
        FlSpot(14, 40),
        FlSpot(15, 50),
        FlSpot(16, 20),
        FlSpot(17, 25),
        FlSpot(18, 40),
        FlSpot(19, 50),
        FlSpot(20, 35),
        FlSpot(21, 80),
        FlSpot(22, 30),
        FlSpot(23, 20),
        FlSpot(24, 25),
        FlSpot(25, 40),
        FlSpot(26, 50),
        FlSpot(27, 35),
        FlSpot(28, 50),
        FlSpot(29, 60),
        FlSpot(30, 40)
      ];

  double progressRatio = 0.0;
  int currentIndex = 0;
  double totalIntake = 0.0;
  String? firstName;
  double? bmi;
  String _bmiCategoryText = "loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _resetWaterIntake() {
    setState(() {
      totalIntake = 0.0; // Reset total intake
      currentIndex = 0;
      progressRatio = 0.0; // Reset the index to start from the first value
    });
  }

  void _recordWaterIntake() {
    setState(() {
      // Increment progress until it reaches 5 (for 5 water intake periods)
      if (progressRatio < 1.0) {
        progressRatio += 0.2;

        // Update the current index to cycle through the waterArr list
        double intakeAmount =
            _getWaterAmount(waterArr[currentIndex]['subtitle']);
        totalIntake += intakeAmount;

        currentIndex = (currentIndex + 1) % waterArr.length;
      } else {
        // Reset progress and index when it's complete
        progressRatio = 0.0;
        currentIndex = 0;
      }
    });
  }

  Future<void> _fetchUserData() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Fetch user details
    final List<Map<String, dynamic>> userRecords = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [widget.userEmail],
    );

    print('User Records: $userRecords');

    if (userRecords.isNotEmpty) {
      final userRecord = userRecords.first;
      setState(() {
        firstName = userRecord['firstName'];
      });

      // Fetch user details for BMI
      final List<Map<String, dynamic>> detailRecords = await db.query(
        'user_details',
        where: 'email = ?',
        whereArgs: [widget.userEmail],
      );

      print('Detail Records: $detailRecords');

      if (detailRecords.isNotEmpty) {
        final detailRecord = detailRecords.first;
        setState(() {
          bmi = detailRecord['bmi']?.toDouble();
          if (bmi != null) {
            _updateBMICategory(bmi!);
          } // Assuming the column name is 'bmi'
        });
      } else {
        setState(() {
          _bmiCategoryText = "BMI data not available";
        });
      }
    } else {
      setState(() {
        _bmiCategoryText = "User data not available";
      });
    }
  }

  void _updateBMICategory(double bmi) {
    setState(() {
      if (bmi < 18.5) {
        _bmiCategoryText = "You are underweight!";
      } else if (bmi >= 18.5 && bmi <= 25) {
        _bmiCategoryText = "You have a normal weight!";
      } else if (bmi > 25 && bmi <= 35) {
        _bmiCategoryText = "You are overweight!";
      } else {
        _bmiCategoryText = "You are obese!";
      }
    });
  }

  List waterArr = [
    {"title": "6am - 7am", "subtitle": "400ml"},
    {"title": "9am - 11am", "subtitle": "400ml"},
    {"title": "11am - 2pm", "subtitle": "500ml"},
    {"title": "2pm - 4pm", "subtitle": "600ml"},
    {"title": "6pm - 8pm", "subtitle": "700ml"},
  ];

  double _getWaterAmount(String subtitle) {
    return double.parse(subtitle.replaceAll('ml', ''));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            TColor.primaryColor2.withOpacity(0.4),
            TColor.primaryColor1.withOpacity(0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(
          colors: TColor.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          " Welcome Back,",
                          style: TextStyle(color: TColor.gray, fontSize: 13),
                        ),
                      ),
                      Text(
                        "$firstName!",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ]),
                    IconButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationView()));
                        },
                        icon: Image.asset(
                          "assets/img/notification_active.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.fitHeight,
                        ))
                  ],
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(media.width * 0.075)),
                  child: Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      "assets/img/bg_dots.png",
                      height: media.width * 0.4,
                      width: double.maxFinite,
                      fit: BoxFit.fitHeight,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BMI (Body Mass Index)",
                                style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                _bmiCategoryText,
                                style: TextStyle(
                                    color: TColor.white.withOpacity(0.9),
                                    fontSize: 12),
                              ),
                              SizedBox(
                                height: media.width * 0.05,
                              ),
                              SizedBox(
                                  width: 120,
                                  height: 35,
                                  child: RoundButton(
                                      title: "View More",
                                      type: RoundButtonType.bgSGradient,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      onPressed: () {}))
                            ],
                          ),
                          AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {},
                                ),
                                startDegreeOffset: 250,
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 1,
                                centerSpaceRadius: 0,
                                sections: showingSections(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                        color: TColor.primaryColor2.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Target",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                            width: 75,
                            height: 25,
                            child: RoundButton(
                                title: "Check",
                                type: RoundButtonType.bgGradient,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivityTrackerView()));
                                }))
                      ],
                    )),
                // SizedBox(
                //   height: media.width * 0.05,
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 10),
                //   child: Text(
                //     "Activity Status",
                //     style: TextStyle(
                //         color: TColor.black,
                //         fontSize: 14,
                //         fontWeight: FontWeight.w700),
                //   ),
                // ),
                // SizedBox(
                //   height: media.width * 0.02,
                // ),
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                //   decoration: BoxDecoration(
                //       color: TColor.primaryColor2.withOpacity(0.3),
                //       borderRadius: BorderRadius.circular(15)),
                // ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: media.width * 1.09,
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 25),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ]),
                        child: Row(
                          children: [
                            SimpleAnimationProgressBar(
                              height: media.width * 0.95,
                              width: media.width * 0.07,
                              backgroundColor: Colors.grey.shade100,
                              foregrondColor: Colors.purple,
                              ratio: progressRatio,
                              direction: Axis.vertical,
                              curve: Curves.easeInOutCubicEmphasized,
                              duration: const Duration(seconds: 1),
                              borderRadius: BorderRadius.circular(10),
                              gradientColor: LinearGradient(
                                  colors: TColor.primaryG,
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Water Intake",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                              colors: TColor.primaryG,
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight)
                                          .createShader(Rect.fromLTRB(0, 0,
                                              bounds.width, bounds.height));
                                    },
                                    child: Text(
                                      "${totalIntake.toStringAsFixed(0)} ml",
                                      style: TextStyle(
                                          color: TColor.white.withOpacity(0.7),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13),
                                    )),
                                const SizedBox(height: 2),
                                Text(
                                  "Real time updates",
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 10),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 9),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: waterArr.map((wObj) {
                                      var isLast = wObj == waterArr.last;
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                    color: TColor
                                                        .secondaryColor1
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                              ),
                                              if (!isLast)
                                                DottedDashedLine(
                                                    height: media.width * 0.078,
                                                    width: 0,
                                                    dashColor: TColor
                                                        .secondaryColor1
                                                        .withOpacity(0.5),
                                                    axis: Axis.vertical)
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                wObj["title"].toString(),
                                                style: TextStyle(
                                                    color: TColor.gray,
                                                    fontSize: 9),
                                              ),
                                              ShaderMask(
                                                  blendMode: BlendMode.srcIn,
                                                  shaderCallback: (bounds) {
                                                    return LinearGradient(
                                                            colors: TColor
                                                                .secondaryG,
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight)
                                                        .createShader(
                                                            Rect.fromLTRB(
                                                                0,
                                                                0,
                                                                bounds.width,
                                                                bounds.height));
                                                  },
                                                  child: Text(
                                                    wObj["subtitle"].toString(),
                                                    style: TextStyle(
                                                        color: TColor.white
                                                            .withOpacity(0.7),
                                                        fontSize: 10),
                                                  )),
                                            ],
                                          )
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        10), // Spacing between waterArr and the button
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: RoundButton(
                                    title: progressRatio >= 1.0
                                        ? "Reset"
                                        : "Record",
                                    type: RoundButtonType.bgSGradient,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    onPressed: () {
                                      if (progressRatio >= 1.0) {
                                        // If progress is complete (1.0), reset the water intake
                                        _resetWaterIntake();
                                      } else {
                                        // Otherwise, record the water intake
                                        _recordWaterIntake();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: media.width * 0.05,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              height: media.width * 0.52,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 25, horizontal: 25),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 2)
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sleep",
                                    style: TextStyle(
                                        color: TColor.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                                colors: TColor.primaryG,
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight)
                                            .createShader(Rect.fromLTRB(0, 0,
                                                bounds.width, bounds.height));
                                      },
                                      child: Text(
                                        "8h 20min",
                                        style: TextStyle(
                                            color:
                                                TColor.white.withOpacity(0.7),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                      )),
                                  const Spacer(),
                                  Image.asset(
                                    "assets/img/sleep_grap.png",
                                    width: double.maxFinite,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ],
                              )),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          Container(
                              height: media.width * 0.52,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 25, horizontal: 25),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 2)
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Calories",
                                    style: TextStyle(
                                        color: TColor.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                                colors: TColor.primaryG,
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight)
                                            .createShader(Rect.fromLTRB(0, 0,
                                                bounds.width, bounds.height));
                                      },
                                      child: Text(
                                        "760 kCal",
                                        style: TextStyle(
                                            color:
                                                TColor.white.withOpacity(0.7),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                      )),
                                  const Spacer(),
                                  Container(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: media.width * 0.2,
                                      height: media.width * 0.2,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: media.width * 0.15,
                                            height: media.width * 0.15,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: TColor.primaryG),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      media.width * 0.075),
                                            ),
                                            child: FittedBox(
                                              child: Text(
                                                "230kCal\nleft",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: TColor.white,
                                                    fontSize: 10),
                                              ),
                                            ),
                                          ),
                                          SimpleCircularProgressBar(
                                            progressStrokeWidth: 10,
                                            startAngle: -180,
                                            backColor: Colors.grey.shade100,
                                            backStrokeWidth: 10,
                                            valueNotifier: ValueNotifier(50),
                                            progressColors: TColor.primaryG,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: media.width * 0.1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Workout Progress",
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: TColor.primaryG),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            items: ["Weekly", "Monthly"]
                                .map((name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                            color: TColor.gray, fontSize: 14),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {},
                            icon: Icon(Icons.expand_more, color: TColor.white),
                            hint: Text(
                              "Weekly",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                    padding: const EdgeInsets.only(left: 15),
                    height: media.width * 0.5,
                    width: double.maxFinite,
                    child: LineChart(
                      LineChartData(
                        showingTooltipIndicators:
                            showingTooltipOnSpots.map((index) {
                          return ShowingTooltipIndicators([
                            LineBarSpot(
                              tooltipsOnBar,
                              lineBarsData.indexOf(tooltipsOnBar),
                              tooltipsOnBar.spots[index],
                            ),
                          ]);
                        }).toList(),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: false,
                          touchCallback: (FlTouchEvent event,
                              LineTouchResponse? response) {
                            if (response == null ||
                                response.lineBarSpots == null) {
                              return;
                            }
                            if (event is FlTapUpEvent) {
                              final spotIndex =
                                  response.lineBarSpots!.first.spotIndex;
                              showingTooltipOnSpots.clear();
                              setState(() {
                                showingTooltipOnSpots.add(spotIndex);
                              });
                            }
                          },
                          mouseCursorResolver: (FlTouchEvent event,
                              LineTouchResponse? response) {
                            if (response == null ||
                                response.lineBarSpots == null) {
                              return SystemMouseCursors.basic;
                            }
                            return SystemMouseCursors.click;
                          },
                          getTouchedSpotIndicator: (LineChartBarData barData,
                              List<int> spotIndexes) {
                            return spotIndexes.map((index) {
                              return TouchedSpotIndicatorData(
                                FlLine(
                                  color: Colors.transparent,
                                ),
                                FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) =>
                                          FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.white,
                                    strokeWidth: 3,
                                    strokeColor: TColor.secondaryColor1,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: TColor.secondaryColor1,
                            tooltipRoundedRadius: 20,
                            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                              return lineBarsSpot.map((lineBarSpot) {
                                return LineTooltipItem(
                                  "${lineBarSpot.x.toInt()} mins ago",
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: lineBarsData1,
                        minY: -0.5,
                        maxY: 110,
                        titlesData: FlTitlesData(
                            show: true,
                            leftTitles: AxisTitles(),
                            topTitles: AxisTitles(),
                            bottomTitles: AxisTitles(
                              sideTitles: bottomTitles,
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: rightTitles,
                            )),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 25,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: TColor.gray.withOpacity(0.15),
                              strokeWidth: 2,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    )),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Workout",
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "See More",
                        style: TextStyle(
                            color: TColor.gray,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  ],
                ),
                ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: lastWorkoutArr.length,
                    itemBuilder: (context, index) {
                      var wObj = lastWorkoutArr[index] as Map? ?? {};
                      return InkWell(
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute( builder: (context) => const FinishedWorkoutView(),),);
                          },
                          child: WorkoutRow(wObj: wObj));
                    }),
                SizedBox(
                  height: media.width * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    if (bmi == null) {
      return [];
    }

    double bmiValue = bmi!;
    double healthyRange = 24.9;

    return List.generate(
      2,
      (i) {
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: TColor.secondaryColor1,
              value: healthyRange - bmiValue,
              title: '',
              radius: 55,
              titlePositionPercentageOffset: 0.55,
              badgeWidget: Text(
                bmiValue.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          case 1:
            return PieChartSectionData(
              color: Colors.white,
              value: healthyRange,
              title: '',
              radius: 50,
              titlePositionPercentageOffset: 0.55,
            );
          default:
            throw Error();
        }
      },
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.primaryColor2.withOpacity(0.5),
          TColor.primaryColor1.withOpacity(0.5),
        ]),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.secondaryColor2.withOpacity(0.5),
          TColor.secondaryColor1.withOpacity(0.5),
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
        ),
        spots: const [
          FlSpot(1, 80),
          FlSpot(2, 50),
          FlSpot(3, 90),
          FlSpot(4, 40),
          FlSpot(5, 80),
          FlSpot(6, 35),
          FlSpot(7, 60),
        ],
      );

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(
          color: TColor.gray,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.gray,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Sun', style: style);
        break;
      case 2:
        text = Text('Mon', style: style);
        break;
      case 3:
        text = Text('Tue', style: style);
        break;
      case 4:
        text = Text('Wed', style: style);
        break;
      case 5:
        text = Text('Thu', style: style);
        break;
      case 6:
        text = Text('Fri', style: style);
        break;
      case 7:
        text = Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}
