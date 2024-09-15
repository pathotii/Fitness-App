import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../login/welcome_view.dart'; // Adjust the import if needed

class WhatYourGoalView extends StatefulWidget {
  final String firstName;
  final String userEmail;
  
  const WhatYourGoalView({super.key, required this.firstName, required this.userEmail});

  @override
  State<WhatYourGoalView> createState() => _WhatYourGoalViewState();
}

class _WhatYourGoalViewState extends State<WhatYourGoalView> {
  final PageController _pageController =
      PageController(viewportFraction: 0.7, initialPage: 1);

  final List<Map<String, String>> goalArr = [
    {
      "image": "assets/img/goal_1.png",
      "title": "Improve Shape",
      "subtitle":
          "I have a low amount of body fat\nand need / want to build more\nmuscle"
    },
    {
      "image": "assets/img/goal_2.png",
      "title": "Lean & Tone",
      "subtitle":
          "I’m “skinny fat”. look thin but have\nno shape. I want to add lean\nmuscle in the right way"
    },
    {
      "image": "assets/img/goal_3.png",
      "title": "Lose a Fat",
      "subtitle":
          "I have over 20 lbs to lose. I want to\ndrop all this fat and gain muscle\nmass"
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: PageView.builder(
                controller: _pageController,
                itemCount: goalArr.length,
                itemBuilder: (context, index) {
                  final gObj = goalArr[index];
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: media.width * 0.02),
                      child: Container(
                        width: media.width * 0.9, // Adjust width of the container
                        height:
                            media.height * 0.6, // Adjust height of the container
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: TColor.primaryG,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center contents vertically
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Center contents horizontally
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(media.width *
                                    0.05), // Adjust padding around the image
                                child: Image.asset(
                                  gObj["image"]!,
                                  fit: BoxFit
                                      .contain, // Fit image within the container while maintaining aspect ratio
                                ),
                              ),
                            ),
                            SizedBox(height: media.width * 0.05),
                            Text(
                              gObj["title"]!,
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              width: media.width * 0.2,
                              height: 1,
                              color: TColor.white,
                            ),
                            SizedBox(height: media.width * 0.02),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: media.width *
                                      0.05), // Adjust padding for subtitle
                              child: Text(
                                gObj["subtitle"]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              width: media.width,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: media.width *
                            0.09), // Top padding for "What is your goal?" text
                    child: Text(
                      "What is your goal?",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: media.width *
                            0.015), 
                    child: Text(
                      "It will help us to choose a best\nprogram for you",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                  ),
                  const Spacer(),

                  SizedBox(height: media.width * 0.05),

                  Padding(
                    padding: EdgeInsets.only(bottom: media.width * 0.07),
                    child: SizedBox(
                      height: media.width * 0.12,
                      child: RoundButton(
                        title: "Confirm",
                        type: RoundButtonType.bgGradient,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WelcomeView(firstName: widget.firstName, userEmail: widget.userEmail,),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
