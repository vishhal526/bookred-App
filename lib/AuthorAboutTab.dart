import 'package:flutter/material.dart';

class AuthorAboutTab extends StatefulWidget {
  final String about;

  AuthorAboutTab({Key? key, required this.about}) : super(key: key);

  @override
  State<AuthorAboutTab> createState() => _AuthorAboutTabState();
}

class _AuthorAboutTabState extends State<AuthorAboutTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Text(
          widget.about,
          style: TextStyle(fontSize: 18, fontFamily: "Poppins"),
        ),
      ),
    );
  }
}
