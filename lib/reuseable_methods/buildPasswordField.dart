import 'package:flutter/material.dart';

Widget buildPasswordField(TextEditingController controller, String hintText,
    bool isObscured, VoidCallback toggleVisibility) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          fontFamily: "Poppins",
          color: Colors.grey,
        ),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        suffixIcon: IconButton(
          icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey),
          onPressed: toggleVisibility,
        ),
      ),
    ),
  );
}
