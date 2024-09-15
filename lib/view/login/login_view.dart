import 'package:fit_pair/view/main_tab/main_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../SQFLite/database_helper.dart';
import '../login/user.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: media.height * 0.9,
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
                    "Welcome Back",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
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
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Invalid email format';
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
                    obscureText: !isPasswordVisible,
                    rigtIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          isPasswordVisible
                              ? "assets/img/hide_password.png"
                              : "assets/img/show_password.png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          color: TColor.gray,
                        ),
                      ),
                    ),
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: media.width * 0.04),
                        child: Text(
                          "Forgot your password?",
                          style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  RoundButton(
                    title: "Login",
                    type: RoundButtonType.bgGradient,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final email = _emailController.text;
                        final password = _passwordController.text;

                        // Check credentials
                        bool isValid = await _validateLogin(email, password);
                        if (isValid) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainTabView(userEmail: email)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Invalid email or password')),
                          );
                        }
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
                        onTap: () {},
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
                          await _loginWithFacebook(context);
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
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Don’t have an account yet? ",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Register",
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
            child: const Text("Login Successful"),
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

  Future<bool> _validateLogin(String email, String password) async {
    final dbHelper = DatabaseHelper();
    List<User> userList = await dbHelper.users();

    for (var user in userList) {
      if (user.email == email && user.password == password) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
