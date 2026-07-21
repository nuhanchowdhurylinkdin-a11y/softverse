import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App_BarTheme {
  App_BarTheme._();

  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    foregroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
    actionsIconTheme: IconThemeData(color: Colors.black),
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );

  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    foregroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    backgroundColor: Color(0xFF1E1E1E),
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
    actionsIconTheme: IconThemeData(color: Colors.white),
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );
}
