// import 'package:bookred/LoginPage.dart';
import 'package:bookred/All_API_List/call_auth_api.dart';
import 'package:bookred/VerifyPasscodePage.dart';
import 'package:bookred/reuseable_methods/EmailService.dart';
import 'package:bookred/reuseable_methods/buildTextfield.dart';
import 'package:bookred/reuseable_methods/PhoneService.dart';
import 'package:flutter/material.dart';

class EmailVerifyPage extends StatefulWidget {
  final bool isforgot;

  const EmailVerifyPage({Key? key, required this.isforgot}) : super(key: key);

  @override
  State<EmailVerifyPage> createState() => _SignPageState();
}

class _SignPageState extends State<EmailVerifyPage> {
  final EmailService _emailService = EmailService();
  final PhoneService _phoneService = PhoneService();

  AuthService auth = AuthService();

  final TextEditingController emailController = TextEditingController();

  final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // final RegExp emailRegex = RegExp(r'^[^@\s]+@gmail\.com$');
  final RegExp phoneRegex = RegExp(r'^\d{10}$');

  bool isInputValid = true;
  bool isLoading = false;
  bool isUserPresent = true;

  void _validateInputAndNavigate() async {
    String input = emailController.text.trim();
    if (emailRegex.hasMatch(input)) {
      setState(() {
        isInputValid = true;
        isLoading = true;
      });

      if (widget.isforgot) {
        int checkUser = await auth.checkUserExist(email: input);
        if (checkUser == 0) {
          setState(() {
            isUserPresent = false;
          });
        } else {
          setState(() {
            isUserPresent = true;
          });
        }
      }

      String _code = _emailService.generateVerificationCode();

      bool isOTPSent = await Future.delayed(Duration(seconds: 3), () async {
        return await _emailService.sendEmail(input, _code);
      });

      if (isOTPSent) {
        setState(() {
          isLoading = false;
        });

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyPasscodePage(
              emailOrPhone: input,
              isforgot: widget.isforgot,
              code: _code,
            ),
          ),
        );
        if (result == "verified") {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          isLoading = false; // Stop loading if sending OTP fails
        });
      }
    } else {
      setState(() {
        isInputValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Main Body
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Instrunctions
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    "What's Your Gmail Address?",
                    style: TextStyle(fontSize: 20, fontFamily: "Poppins"),
                  ),
                ),
                widget.isforgot
                    ? Text(
                        "Enter Email Address registered to your acccount",
                        style: TextStyle(fontFamily: "Poppins"),
                      )
                    : Text(
                        "Enter a valid Email Address",
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                SizedBox(height: 20),

                //Email Input
                buildTextField(
                    controller: emailController, hintText: "Email Address"),
                if (!isInputValid)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Enter Email address in a valid format",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13,
                        color: Colors.red, // Make error text red
                      ),
                    ),
                  ),
                if (!isUserPresent)
                  Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    child: Text(
                      "No Such user Exist",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13,
                        color: Colors.red, // Make error text red
                      ),
                    ),
                  ),
                SizedBox(height: (isInputValid || isUserPresent) ? 10 : 5),

                //Next Page Button
                ElevatedButton(
                  onPressed: isLoading ? null : _validateInputAndNavigate,
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

            //Already Have an Account
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Already have an account?"),
                        backgroundColor: Color(0xFFFFFFFF),
                        content: Text(
                          "Do you want to continue creating a new account or log in?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Continue Creating",
                              style: TextStyle(
                                  fontFamily: "Poppins", color: Colors.black),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontFamily: "Poppins", color: Colors.black),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "I Already have an account",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    color: Color(0xFF1A1D32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
