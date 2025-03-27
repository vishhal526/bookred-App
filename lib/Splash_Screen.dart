import 'package:bookred/LoginPage.dart';
import 'package:bookred/MainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<Splash_Screen> {
  static const String keylogin = "login";

  @override
  void initState() {
    super.initState();
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Image.asset('assets/images/Splash_Icon.png'), // Your logo
      ),
    );
  }

  void whereToGo() async {
    var sharedPref = await SharedPreferences.getInstance();

    var isLoggedin = sharedPref.getBool(keylogin);

    Future.delayed(const Duration(seconds: 2), () {
      if (isLoggedin != null) {
        if (isLoggedin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Mainpage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }
}
