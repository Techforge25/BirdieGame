import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JoinGameCard extends StatelessWidget {
    final VoidCallback? onTap;
  const JoinGameCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.flashyGreen,
                border: Border.all(color: AppColors.primary, width: 1.3.w),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Join Game", style: AppTextStyles.subHeading),
                  SizedBox(height: 5.h),
                  Text(
                    "Enter the passkey provided by the game\norganizer to join.",
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: 30.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CustomTextField(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: AppColors.borderColorLight),
                      hintText: "Enter Game PassKey",
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CustomElevatedButton(
                      onPressed: onTap ?? () {
                         //want to naviate on GameBoardView without hiding Bottom NAv
                      },
                      btnName: "Join Game",
                      backColor: AppColors.primary,
                      textColor: AppColors.white,
                      borderRadius: 18.r,
                    ),
                  ),
                ],
              ),
            );
  }
}