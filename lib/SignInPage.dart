import 'package:bookred/MainPage.dart';
import 'package:bookred/All_API_List/call_auth_api.dart';
import 'package:bookred/reuseable_methods/buildTextfield.dart';
import 'package:bookred/reuseable_methods/buildPasswordField.dart';
import 'package:bookred/Splash_Screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninPage extends StatefulWidget {
  final String emailOrPhone;

  const SigninPage({Key? key, required this.emailOrPhone}) : super(key: key);

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final AuthService auth = AuthService();
  final RegExp passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*]).{12,}$');

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isObscured = true;
  bool isPasswordValid = true;
  bool isLoading = false;
  int isUserExists = 0;
  String? errorMessage;

  void _toggleVisibility() => setState(() => _isObscured = !_isObscured);

  Future<void> _checkUserExists(String input) async {
    if (usernameController.text.isNotEmpty) {
      isUserExists = await auth.checkUserExist(username: input);
      setState(() {});
    }
  }

  Future<void> _signin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    if (isUserExists == 0 && isPasswordValid) {
      String signInStatus = await auth.signin(
        username: usernameController.text,
        password: passwordController.text,
        name: nameController.text,
        email: widget.emailOrPhone,
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
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                children: [

                  //Password Info
                  Text(
                    "Enter a Unique Username and Password",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins"),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  //Name Field
                  buildTextField(hintText: "Full Name", controller: nameController),

                  //Username Field
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        _checkUserExists(usernameController.text);
                      }
                    },
                    child: buildTextField(
                      controller: usernameController,
                      hintText: "Username",
                    ),
                  ),
                  if (isUserExists == 1)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "This Username is already taken Use another one",
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Poppins",
                            color: Colors.red),
                      ),
                    ),

                  //Password field
                  buildPasswordField(passwordController, "Password",_isObscured,_toggleVisibility),
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
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),

                  //Sign Up Button
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              isPasswordValid = passwordRegex
                                  .hasMatch(passwordController.text);
                            });
                            if (isPasswordValid) {
                              _signin();
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
                              padding: EdgeInsets.symmetric(vertical: 8),
                              // Set the width of the loading container
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Color(0xFF1A1D32),
                                  borderRadius: BorderRadius.circular(8)),
                              // Set the height to match button size
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth:
                                      2.5, // Optional: tweak the stroke width
                                ),
                              ),
                            )
                          : Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Poppins",
                                  color: Colors.white),
                            ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
