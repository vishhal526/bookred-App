import 'package:bookred/All_API_List/call_auth_api.dart';
import 'package:bookred/LoginPage.dart';
import 'package:bookred/ResetpasswordPage.dart';
import 'package:bookred/SignInPage.dart';
import 'package:bookred/reuseable_methods/EmailService.dart';
import 'package:bookred/reuseable_methods/buildPasswordField.dart';
import 'package:bookred/reuseable_methods/PhoneService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetpasswordPage extends StatefulWidget {
  final String email;

  const ResetpasswordPage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ResetpasswordPage> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<ResetpasswordPage> {
  final AuthService auth = AuthService();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  bool isPasswordValid = true;
  bool isObscured = true;
  bool isLoading = false;
  bool isPasswordStable = true;

  String? errorMessage;

  final RegExp passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*]).{12,}$');

  void toggleVisibility() {
    setState(() {
      isObscured = !isObscured; // Toggle obscure state
    });
  }

  void _validateCodeAndNavigate(String password) async {
    if (passwordRegex.hasMatch(password)) {
      int passwordReset =
          await auth.resetPassword(email: widget.email, password: password);

      if (passwordReset == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        setState(() {
          errorMessage = "An Error Occured";
        });
      }
    } else {
      setState(() {
        isPasswordValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Instruction
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
                child: Text(
                  "Enter new Password to save",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Poppins",
                  ),
                ),
              ),

              //Password
              buildPasswordField(_passwordController, "Enter Password",
                  isObscured, toggleVisibility),
              SizedBox(
                height: 10,
              ),

              //Confirm Password
              buildPasswordField(_confirmpasswordController, "Confirm Password",
                  isObscured, toggleVisibility),
              if (!isPasswordValid)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Password must contain at least 12 characters, 1 uppercase, 1 lowercase, 1 number, and 1 special character.",
                    style: TextStyle(
                        fontSize: 12, fontFamily: "Poppins", color: Colors.red),
                  ),
                ),
              if (!isPasswordStable)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Password and Confirm Password must match",
                    style: TextStyle(
                        fontSize: 12, fontFamily: "Poppins", color: Colors.red),
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
              SizedBox(
                height: 10,
              ),

              //Next Button
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (isPasswordStable) {
                          setState(() {
                            isPasswordStable = true;
                          });
                          _validateCodeAndNavigate(_passwordController.text);
                        } else {
                          setState(() {
                            isPasswordStable = false;
                          });
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
                          padding: EdgeInsets.symmetric(vertical: 6),
                          // Set the width of the loading container
                          height: 45,
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
                      : Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Next",
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Poppins",
                                color: Colors.white),
                          ),
                        ),
                ),
              )
            ],
          ),
        ));
  }
}
