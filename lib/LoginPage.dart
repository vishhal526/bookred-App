import 'package:bookred/All_API_List/call_auth_api.dart';
import 'package:bookred/reuseable_methods/buildPasswordField.dart';
import 'package:bookred/reuseable_methods/buildTextfield.dart';
import 'package:bookred/Splash_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookred/EmailVerifyPage.dart';
import 'package:bookred/ResetpasswordPage.dart';
import 'package:bookred/MainPage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService auth = AuthService();

  final RegExp passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*]).{12,}$');
  final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscured = true;
  bool isPasswordValid = true;
  bool isLoading = false;

  String? errorMessage;

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured; // Toggle obscure state
    });
  }

  void loginandNavigate(
      {required String loginId, required String password}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    bool isEmail = emailRegex.hasMatch(loginId);

    if (isPasswordValid) {
      String signInStatus = await auth.login(
        username: isEmail ? null : loginId,
        email: isEmail ? loginId : null,
        password: passwordController.text,
      );

      if (signInStatus == "S") {
        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setBool(SplashScreenState.keylogin, true);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Mainpage()));
      } else {
        setState(() {
          errorMessage = signInStatus;
        });
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(),
        body: Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Column(children: [
              Expanded(
                child: Column(
                  children: [
                    // App Name
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              "Book",
                              style: TextStyle(
                                  fontFamily: "Poiret",
                                  fontSize: 50,
                                  color: Color(0xFF1A1D32),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            child: Text(
                              "Red",
                              style: TextStyle(
                                  fontFamily: "Poiret",
                                  fontSize: 50,
                                  color: Color(0xFFD0312D),
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    ),

                    //Input Fields
                    Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            //Username , Email Address or Phone Number
                            buildTextField(
                                controller: usernameController,
                                hintText: "UserName or Email"),

                            //Password
                            buildPasswordField(passwordController, "Password",
                                _isObscured, _toggleVisibility),
                            if (!isPasswordValid)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "Password must contain at least 12 characters, 1 uppercase, 1 lowercase, 1 number, and 1 special character.",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Poppins",
                                      color: Colors.red),
                                ),
                              ),
                            if (errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.red),
                                ),
                              ),

                            //Login Button
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        isPasswordValid = passwordRegex
                                            .hasMatch(passwordController.text);
                                      });
                                      if (isPasswordValid) {
                                        loginandNavigate(
                                            loginId: usernameController.text,
                                            password: passwordController.text);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1D32),
                                // Set the button background color
                                padding: EdgeInsets.zero,
                                // Remove padding from ElevatedButton
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                // Ensure everything is centered
                                child: isLoading
                                    ? Container(
                                        width: double.infinity,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 6),
                                        // Set the width of the loading container
                                        height: 45,
                                        decoration: BoxDecoration(
                                            color: Color(0xFF1A1D32),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        // Set the height to match button size
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth:
                                                2.5, // Optional: tweak the stroke width
                                          ),
                                        ),
                                      )
                                    : Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Poppins",
                                              color: Colors.white),
                                        ),
                                      ),
                              ),
                            ),

                            //Forgot Password
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EmailVerifyPage(
                                            isforgot: true,
                                          )),
                                );
                              },
                              child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.black45,
                                              width: 2))),
                                  child: Text(
                                    "Forgot Password ?",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 15,
                                    ),
                                  )),
                            ),
                          ],
                        )),

                    //Sign In Text
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don’t have an account? ",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 18,
                                color: Color(0xFFA2A2A2)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EmailVerifyPage(
                                          isforgot: false,
                                        )),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 18,
                                color: Color(0xFF1A1D32),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ])));
  }
}
