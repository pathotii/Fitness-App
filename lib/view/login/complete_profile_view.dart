import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../common/colo_extension.dart';
import '../../view/login/what_your_goal_view.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../SQFLite/database_helper.dart';

class CompleteProfileView extends StatefulWidget {
  final String email;
  const CompleteProfileView({super.key, required this.email});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _gender;
  String? firstName;

  @override
  void initState() {
    super.initState();
    _fetchUserFirstName();
  }

  Future<void> _fetchUserFirstName() async {
    firstName = await DatabaseHelper().getUserFirstName(widget.email);
    setState(() {});
  }

  double? _calculateBMI(double weight, double height) {
    if (height > 0) {
      double bmi = weight / ((height / 100) * (height / 100));
      return double.parse(bmi.toStringAsFixed(1)); // Round to one decimal place
    }
    return null;
  }

  Future<void> _saveUserProfile() async {
    final dateOfBirth = _dateOfBirthController.text;
    final weightStr = _weightController.text;
    final heightStr = _heightController.text;

    if (_gender == null || dateOfBirth.isEmpty || weightStr.isEmpty || heightStr.isEmpty) {
      // Show error if any required field is missing
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Missing Information"),
          content: const Text("Please fill in all the fields."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    double weight = double.parse(weightStr);
    double height = double.parse(heightStr);
    double? bmi = _calculateBMI(weight, height);

    try {
      await DatabaseHelper().insertUserDetails(
        email: widget.email,
        firstName: firstName ?? '',
        gender: _gender!,
        dateOfBirth: dateOfBirth,
        weight: weight,
        height: height,
        bmi: bmi ?? 0.0,
        age: _calculateAge(dateOfBirth),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WhatYourGoalView(
            firstName: firstName ?? '',
            userEmail: widget.email,
          ),
        ),
      );
    } catch (e) {
      print("Error saving user profile: $e");
      // Show error if something goes wrong
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("An error occurred while saving your profile."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  int _calculateAge(String dateOfBirth) {
    final birthDate = DateFormat('MM/dd/yyyy').parse(dateOfBirth);
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Image.asset(
                  "assets/img/complete_profile.png",
                  width: media.width,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Text(
                  "Let’s complete your profile",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  "It will help us to know more about you!",
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Image.asset(
                                "assets/img/gender.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: TColor.gray,
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _gender,
                                  items: ["Male", "Female"]
                                      .map((name) => DropdownMenuItem(
                                            value: name,
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                  color: TColor.gray,
                                                  fontSize: 14),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value;
                                    });
                                  },
                                  isExpanded: true,
                                  hint: Text(
                                    "Choose Gender",
                                    style: TextStyle(
                                        color: TColor.gray, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8,),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      RoundTextField(
                        controller: _dateOfBirthController,
                        hitText: "Date of Birth (08/01/2002)",
                        icon: "assets/img/date.png",
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              controller: _weightController,
                              hitText: "Your Weight",
                              icon: "assets/img/weight.png",
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.secondaryG,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "KG",
                              style: TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              controller: _heightController,
                              hitText: "Your Height",
                              icon: "assets/img/hight.png",
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.secondaryG,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "CM",
                              style: TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.07,
                      ),
                      RoundButton(
                        title: "Next >",
                        type: RoundButtonType.bgGradient,
                        onPressed: () {
                          _saveUserProfile(); // Save data to the database
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WhatYourGoalView(
                                firstName: firstName ?? '',
                                userEmail: widget.email,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
