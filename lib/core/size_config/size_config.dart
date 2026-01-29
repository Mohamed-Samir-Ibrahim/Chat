// import 'dart:math';
// import 'package:flutter/material.dart';

// class SizeConfig {
//   static late MediaQueryData _mediaQueryData;
//   static late double screenWidth;
//   static late double screenHeight;
//   static late double diagonal;

//   static void init(BuildContext context) {
//     _mediaQueryData = MediaQuery.of(context);
//     screenWidth = _mediaQueryData.size.width;
//     screenHeight = _mediaQueryData.size.height;
//     diagonal = sqrt((screenWidth * screenWidth) + (screenHeight * screenHeight));
//   }

//   static double getFontSize(double percent) => screenWidth * percent;
//   static double getRadius(double percent) => screenWidth * percent;
//   static double getFromDiagonal(double percent) => diagonal * percent;
// }
