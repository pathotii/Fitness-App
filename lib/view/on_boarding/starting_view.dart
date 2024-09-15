import 'package:fit_pair/common/colo_extension.dart';
import 'package:fit_pair/common_widget/round_button.dart';
import 'package:fit_pair/view/on_boarding/on_boarding_view.dart';
import 'package:flutter/material.dart';

import '../../SQFLite/database_helper.dart';

class StartingView extends StatefulWidget {
  const StartingView({super.key});

  @override
  State<StartingView> createState() => _StartingViewState();
}

class _StartingViewState extends State<StartingView> {
  bool isChangeColor = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      body: Container(
          width: media.width,
          decoration: BoxDecoration(
            gradient: isChangeColor
                ? LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                "FitPair",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 36,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                "Every Body Can Stay Fit",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 18,
                ),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () async {
                  await DatabaseHelper().printUserScheduleTable();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('users schedule table update')),
                  );
                },
                child: const Text('Check'),
              ),

              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: RoundButton(
                    title: "Get Started",
                    type: isChangeColor
                        ? RoundButtonType.textGradient
                        : RoundButtonType.bgGradient,
                    onPressed: () {
                      if (isChangeColor) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OnBoardingView()));
                      } else {
                        setState(() {
                          isChangeColor = true;
                        });
                      }
                    },
                  ),
                ),
              )
            ],
          )),
    );
  }
}
