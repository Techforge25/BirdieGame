import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final Color? bgcolor;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool? isLarge;
  final TextStyle? hintStyle;
  final String? Function(String?)? validator;
  final bool? enable;
  final BorderSide borderSide;
  final BorderRadius? borderRadius;
  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.prefixIcon,
    this.bgcolor,
    this.suffixIcon,
    this.maxLines,
    this.isLarge,
    this.validator,
    this.enable,
    this.hintStyle,
    this.borderSide = BorderSide.none,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    
    final bool expand = isLarge ?? false;
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      enabled: enable ?? true,
      maxLines: expand ? (maxLines ?? 3) : 1,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        
        
        
        hintText: hintText,
        hintStyle:
            hintStyle ??
            TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              color: AppColors.hintTextColor,
            ),
        fillColor: bgcolor ?? Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        // Remove borders from TextField
        border: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(5.r),
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(5.r),
          borderSide: borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(5.r),
          borderSide: borderSide,
        ),
      ),
      validator: validator,
    );
  }
}
