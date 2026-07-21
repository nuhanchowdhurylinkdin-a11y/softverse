import 'package:flutter/material.dart';

class AppElevatedButtonTheme {
  AppElevatedButtonTheme._();

  static final ElevatedButtonThemeData lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all(0),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      backgroundColor: WidgetStateProperty.all(Colors.blue),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 18)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    ),
  );

  static final ElevatedButtonThemeData darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all(0),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      backgroundColor: WidgetStateProperty.all(Colors.blueGrey),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 18)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    ),
  );
}
