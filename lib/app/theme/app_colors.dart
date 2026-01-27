import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color scaffoldBackground = Color(0xFFF1F1F1);
  static const Color primary = Color(0xff00833A); // Yellow/Orange
  static const Color secondary = Color(0xffFF973A); // Yellow/Orange=

  static const Color textPrimary = Color(0xFF2497CD);
  static Color textSecondary = Color(0xFF858585);
  static const Color hintTextColor = Color(0xFFB0B0B0);

  static const Color textBlack = Color(0xFF000000);
  static Color borderColorLight = Colors.grey[300]!;
  static Color borderColor = Color(0xFF333333).withOpacity(0.6);
  static Color bottomIconColor = Color(0xff1B1B1B);

  static Color get white => Colors.white;
  static Color get lightGreenColor => Color(0xffDCFCE7);

  static Color flashyGreen = Color(0xffE2FFEF);
  static Color darkGreen = Color(0xff254F2C);
  static Color flashyYellow = Color(0xffFFF4E8);
  static Color flashyRed = Color(0xffFFECEE);
  static Color flashyRed2 = Color(0xffFECACA);
  static Color flashyPurple = Color(0xffE9D5FF);
  static Color darkPurple = Color(0xff8B5CF6);
  static Color flashyblue = Color(0xffDBF1FF);
  static Color darkRed = Color(0xffDC2626);
  static Color darkBlue = Color(0xff3B82F6);
  static Color textFieldBgColor = Color(0xffF2F2F2);
}

const defaultAppBarTheme = AppBarTheme(
  backgroundColor: AppColors.primary,
  iconTheme: IconThemeData(color: Colors.white),
  titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  elevation: 10,
);
var elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    textStyle: AppTextStyles.bodyMedium.copyWith(
      color: Colors.white,
      fontFamily: GoogleFonts.inter().fontFamily,
    ),
  ),
);
