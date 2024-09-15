import 'package:fit_pair/view/on_boarding/starting_view.dart';
import 'package:flutter/material.dart';
import 'common/colo_extension.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitPair',
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(
            primaryColor: TColor.primaryColor1,
            fontFamily: "Poppins"),
      
      home: const StartingView(),
    );
  }
}
