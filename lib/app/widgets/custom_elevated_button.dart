import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String btnName;
  final double borderRadius;
  final double fontSize;
  final double width;
  final double? height;
  final double horizontalPadding;
  final Color? backColor;
  final Color? borderColor;
  final double? borderWidth;
  final Color? textColor;
  final bool isLoading;
  final Widget? child;
  final Icon? icon;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.btnName,
    this.borderRadius = 4,
    this.fontSize = 14,
    this.width = double.infinity,
    this.height = 46,
    this.horizontalPadding = 8,
    this.backColor,
    this.textColor = Colors.white,
    this.isLoading = false,
    this.borderColor,
    this.child,
    this.borderWidth,this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),

            side: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: borderWidth ?? 1.0,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: horizontalPadding,
          ),
          backgroundColor: backColor,
          elevation: 0,
        ),

        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : child ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon ?? SizedBox.shrink(),
                      SizedBox(width: 8.w,),
                      Text(
                        btnName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
