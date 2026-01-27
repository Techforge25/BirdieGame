import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameProgressCard extends StatelessWidget {
  const GameProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Progress 15/18"),
                        Spacer(),
                        Text(
                          "15 Birdies",
                          style: AppTextStyles.bodyMedium2.copyWith(
                            color: AppColors.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    LinearProgressIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.flashyGreen,
                      minHeight: 10,
                      value: 0.76,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    SizedBox(height: 8),
                    Text("3 Holes Remaining"),
                  ],
                ),
              );
  }
}