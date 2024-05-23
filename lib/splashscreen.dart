import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_list_1/onboard.dart';


class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash>{
  @override
  void initState() {
    super.initState();
    // Add a delay before navigating to the Onboard screen
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Onboard()), // Navigate to Onboard screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            "assets/logoKnote.png",
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width / 1.68,
            height: MediaQuery.of(context).size.height / 1.9,
          ),
        ),
      ),
    );
  }
}
