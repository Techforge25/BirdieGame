import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading = GoogleFonts.inter(
    color: AppColors.textBlack,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16.sp,
  );

  static TextStyle miniHeadings = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    fontFamily: 'Inter',
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    color: AppColors.textBlack,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle subHeading= GoogleFonts.inter(
    color: AppColors.textBlack,
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
  );
  static TextStyle bodyMedium2 = GoogleFonts.inter(
    color: AppColors.textBlack,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    color: Color(0xff2b2b2b),
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle bodyLarge = GoogleFonts.inter(
    color: AppColors.textBlack,
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
  );
}
