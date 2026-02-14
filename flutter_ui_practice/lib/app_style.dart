import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

Color yellowColor = HexColor("#f7ad19");
Color greenColor = HexColor("#2ea96d");
Color blueGreyColor = HexColor("#429ebd");
Color indigoColor = HexColor("#053f5c");
Color orangeColor = HexColor("#f27f0c");
Color lightBlueColor = HexColor("#aceaff");
Color redColor = HexColor("#ff8989");
Color whiteColor = Colors.white;
Color blackColor = Colors.black;
Color? grey100 = Colors.grey[100];
Color grey300 = const Color(0xFFE8E8E0);
Color greyColor = Colors.grey;

class Styles {
  static TextStyle headlineStyle1 = TextStyle(
    fontSize: 15,
    color: blackColor,
    fontWeight: FontWeight.w500,
  );
  static TextStyle headlineStyle2 = TextStyle(fontSize: 18, color: blackColor);
  static TextStyle headlineStyle3 = TextStyle(
    fontSize: 18,
    color: blackColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle headlineStyle4 = TextStyle(
    fontSize: 20,
    color: blackColor,
    fontWeight: FontWeight.w500,
  );
  static TextStyle headlineStyle5 = TextStyle(
    fontSize: 22,
    color: blackColor,
    fontWeight: FontWeight.w500,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
  );
}

