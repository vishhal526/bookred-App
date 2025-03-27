import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Widget buildScrolltext(String name,Color backgroundColor,Color fontColor) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 20),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
        color: backgroundColor, borderRadius: BorderRadius.circular(15)),
    child: Text(name,style: TextStyle(color:fontColor,fontFamily: "Poppins"),),
  );
}
