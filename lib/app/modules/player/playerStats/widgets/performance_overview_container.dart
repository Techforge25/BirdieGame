import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PerformanceOverviewContainer extends StatelessWidget {
  const PerformanceOverviewContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.borderColorLight),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Performance Overview",
                      style: AppTextStyles.bodyMedium2,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          "Birdies Success rate",
                          style: AppTextStyles.bodySmall,
                        ),
                        Spacer(),
                        Text(
                          "68%",
                          style: AppTextStyles.bodyMedium2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h,),
                    LinearProgressIndicator(
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(12.r),
                      value: 0.68,
                      color: AppColors.primary,
                      backgroundColor: AppColors.flashyGreen,
                    ),
                    SizedBox(height: 8.h,),
                    Row(
                      children: [
                        Text(
                          "Win rate",
                          style: AppTextStyles.bodySmall,
                        ),
                        Spacer(),
                        Text(
                          "38%",
                          style: AppTextStyles.bodyMedium2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h,),
                    LinearProgressIndicator(
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(12.r),
                      value: 0.38,
                      color: AppColors.primary,
                      backgroundColor: AppColors.flashyGreen,
                    ),
                  ],
                ),
              );
}}