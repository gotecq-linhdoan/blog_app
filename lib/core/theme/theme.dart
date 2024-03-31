import 'package:flutter/material.dart';
import 'package:flutter_blog_app/core/theme/app_pallete.dart';

class AppTheme {
  static _boder([Color color = AppPallete.borderColor]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      );
  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(backgroundColor: AppPallete.backgroundColor),
    chipTheme: const ChipThemeData(
      color: MaterialStatePropertyAll(AppPallete.backgroundColor),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: _boder(),
      border: _boder(),
      errorBorder: _boder(AppPallete.errorColor),
      focusedBorder: _boder(AppPallete.gradient2),
    ),
  );
}
