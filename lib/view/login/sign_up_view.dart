import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../view/login/complete_profile_view.dart';
import '../../SQFLite/database_helper.dart';
import '../login/user.dart';
import 'package:email_validator/email_validator.dart';
import 'login_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SignUpView extends StatefulWidget {
  final String userEmail;
  const SignUpView({super.key, required this.userEmail});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isCheck = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: media.width * 0.07),
                    child: Text(
                      "Hey there,",
                      style: TextStyle(color: TColor.gray, fontSize: 16),
                    ),
                  ),
                  Text(
                    "Create an Account",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  RoundTextField(
                    hitText: "First Name",
                    icon: "assets/img/user_text.png",
                    controller: _firstNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    hitText: "Last Name",
                    icon: "assets/img/user_text.png",
                    controller: _lastNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    hitText: "Email",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    hitText: "Password",
                    icon: "assets/img/lock.png",
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    rigtIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: TColor.gray,
                        size: 20,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isCheck = !isCheck;
                          });
                        },
                        icon: Icon(
                          isCheck
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: TColor.gray,
                          size: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          "By continuing you accept our Privacy Policy and\nTerm of Use",
                          style: TextStyle(color: TColor.gray, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.2,
                  ),
                  RoundButton(
                    title: "Register",
                    type: RoundButtonType.bgGradient,
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        User newUser = User(
                          firstName: _firstNameController.text,
                          lastName: _lastNameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                        );

                        await DatabaseHelper().insertUser(newUser);
                        checkUsers();

                        // Navigate to CompleteProfileView
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompleteProfileView(
                              email: _emailController.text,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        height: 1,
                        color: TColor.gray.withOpacity(0.5),
                      )),
                      Text(
                        "  Or  ",
                        style: TextStyle(color: TColor.black, fontSize: 12),
                      ),
                      Expanded(
                          child: Container(
                        height: 1,
                        color: TColor.gray.withOpacity(0.5),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _signInWithGoogle();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: TColor.white,
                            border: Border.all(
                              width: 1,
                              color: TColor.gray.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Image.asset(
                            "assets/img/google.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: media.width * 0.04,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await _signInWithFacebook();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: TColor.white,
                            border: Border.all(
                              width: 1,
                              color: TColor.gray.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Image.asset(
                            "assets/img/facebook.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginView()));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Login",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // ignore: unused_local_variable
        final accessToken = googleAuth.accessToken;
        // ignore: unused_local_variable
        final idToken = googleAuth.idToken;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteProfileView(
              email: googleUser.email,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();

        // Use the Facebook user data
        final email = userData['email'] ?? '';

        // Navigate to CompleteProfileView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteProfileView(
              email: email,
            ),
          ),
        );
      } else {
        print("Facebook Sign-In failed: ${result.message}");
      }
    } catch (e) {
      print("Error during Facebook Sign-In: $e");
    }
  }

  void checkUsers() async {
    List<User> userList = await DatabaseHelper().users();
    if (userList.isNotEmpty) {
      print("Users found: ${userList.length}");
      for (var user in userList) {
        print("User: ${user.firstName} ${user.lastName}");
      }
    } else {
      print("No users found.");
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
