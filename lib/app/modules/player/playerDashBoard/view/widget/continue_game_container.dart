import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/status_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContinueGameContainer extends StatelessWidget {
  const ContinueGameContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 7.0.w),
                ),
              ),
              child: Column(
                children: [
                  //game team row
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Game Name", style: AppTextStyles.subHeading.copyWith(fontSize: 26.sp)),
        
                          Text(
                            "Team Name",
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 20.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      StatusContainer(status: "live"),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  //progreess row
                  Row(
                    children: [
                      Text("Progress: 15/18",style: TextStyle(fontSize: 18.sp),),
                      Spacer(),
                      Text(
                        "total Birdies",
                        style: AppTextStyles.bodyMedium2.copyWith(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    minHeight: 10.h,
                    borderRadius: BorderRadius.circular(12),
                    value: 0.4,
                    color: AppColors.primary,
                    backgroundColor: AppColors.flashyGreen,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Holes Remaining",style: TextStyle(fontSize: 16),),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {},
                      child: Text(
                        "Continue Game ",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 16
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
  }
}