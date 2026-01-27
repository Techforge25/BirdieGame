import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PlayerProfileController extends GetxController {
  Future<void> logout() async {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: AppColors.flashyGreen,
            border: Border.all(color: AppColors.darkBlue),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.flashyGreen,
                      radius: 40.r,
                      child: Icon(
                        Icons.logout,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    Text(
                      "Confirm Logout",
                      style: AppTextStyles.bodyMedium2.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Get.offAllNamed(Routes.SIGN_IN);
                  } catch (_) {
                    Get.snackbar(
                      "Logout failed",
                      "Please try again.",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                btnName: "Log Out",
                backColor: AppColors.primary,
                textColor: AppColors.white,
                borderRadius: 15.r,
              ),
              SizedBox(height: 10.h),
              CustomElevatedButton(
                onPressed: () {
                  Get.back();
                },
                btnName: "Stay Logged In",
                backColor: AppColors.flashyGreen,
                textColor: AppColors.primary,
                borderColor: AppColors.primary,
                borderRadius: 15.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
