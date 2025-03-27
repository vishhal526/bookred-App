import 'package:bookred/All_API_List/call_auth_api.dart';
import 'package:bookred/All_API_List/call_user_api.dart';
import 'package:bookred/ResetpasswordPage.dart';
import 'package:bookred/SignInPage.dart';
import 'package:bookred/reuseable_methods/EmailService.dart';
import 'package:bookred/reuseable_methods/buildTextfield.dart';
import 'package:bookred/reuseable_methods/PhoneService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/androidmanagement/v1.dart';

class VerifyPasscodePage extends StatefulWidget {
  final String emailOrPhone;
  final bool isforgot;
  bool? isupdateEmail = false;
  final String code;

  VerifyPasscodePage({
    Key? key,
    required this.emailOrPhone,
    this.isupdateEmail,
    required this.isforgot,
    // required this.isEmail,
    required this.code,
  }) : super(key: key);

  @override
  State<VerifyPasscodePage> createState() => _VerifyPasscodeState();
}

class _VerifyPasscodeState extends State<VerifyPasscodePage> {
  final EmailService _emailService = EmailService();
  final PhoneService _phoneService = PhoneService();
  final AuthService auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  late String _code;

  @override
  void initState() {
    super.initState();
    _code = widget.code; // Initialize with the provided code
  }

  void _sendCode() {
    setState(() {
      _code = _emailService.generateVerificationCode();
    });

    // widget.isEmail?
    _emailService.sendEmail(widget.emailOrPhone, _code);
    // : _phoneService.sendOTP('+91${widget.emailOrPhone}', "Your BookRed OTP is $_code");

    print("New OTP sent: $_code");
  }

  void _validateCodeAndNavigate() async {
    if (_codeController.text.trim() == _code) {
      if (widget.isupdateEmail!) {
        int response = await auth.changeEmail(widget.emailOrPhone);
        if(response == 1){
          Navigator.pop(context,"verified");
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget.isforgot
                ? ResetpasswordPage(email: widget.emailOrPhone)
                : SigninPage(
                    emailOrPhone: widget.emailOrPhone,
                    // isEmail: widget.isEmail,
                  ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect code. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter the Confirmation Code",
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins"),
            ),
            Text(
              "To confirm your account, enter the 6-digit code sent to your email ${widget.emailOrPhone}",
              style: const TextStyle(fontFamily: "Poppins"),
            ),
            SizedBox(height: 20),

            TextFormField(
              controller: _codeController,
              maxLength: 6,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: "",
                hintText: 'Enter confirmation code',
                hintStyle: const TextStyle(
                    fontSize: 15, fontFamily: "Poppins", color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              ),
              validator: (value) => (value == null || value.length != 6)
                  ? 'Code must be 6 digits'
                  : null,
            ),
            if (_codeController.text.length != 6 &&
                _codeController.text.length != 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  "Code must be 6 digits",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13,
                    color: Colors.red, // Make error text red
                  ),
                ),
              ),

            //Next Button
            _buildButton("Next", _validateCodeAndNavigate,
                const Color(0xFF1A1D32), Colors.white),
            _buildButton("I didn't receive the code", _sendCode, Colors.white,
                Colors.black,
                isOutlined: true),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, VoidCallback onPressed, Color bgColor, Color textColor,
      {bool isOutlined = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: isOutlined
          ? BoxDecoration(
              border: Border.all(width: 2, color: const Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Text(text,
              style: TextStyle(
                  fontSize: 16, color: textColor, fontFamily: "Poppins")),
        ),
      ),
    );
  }
}
