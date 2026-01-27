import 'package:bierdygame/app/modules/auth/controller/auth_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_text_field.dart';
import 'package:bierdygame/app/widgets/social_login_button.dart';
import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpView extends GetView<AuthController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 70),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Create Your Account",
                  style: AppTextStyles.bodyLarge,
                ),
              ),
              Text(
                "Get started with your golf scoreboard.",
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 30.h),
              _buildAddPhoto(),
              SizedBox(height: 30.h),
              CustomTextField(
                controller: controller.nameController,
                hintText: "Enter your full name",
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.borderColor,
                ),
                prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                bgcolor: AppColors.textFieldBgColor,
                borderSide: BorderSide(
                  color: AppColors.borderColorLight,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                controller: controller.emailController,
                hintText: "Enter your email",
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.borderColor,
                ),
                prefixIcon: Icon(Icons.mail_outline, color: AppColors.primary),
                bgcolor: AppColors.textFieldBgColor,
                borderSide: BorderSide(
                  color: AppColors.borderColorLight,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              SizedBox(height: 20.h),
              Obx(
                () => CustomTextField(
                  isPassword: controller.isPasswordHidden.value,
                  controller: controller.passwordController,
                  hintText: "Enter Your Password",
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.borderColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.isPasswordHidden.toggle,
                  ),
                  prefixIcon: Icon(
                    Icons.password_outlined,
                    color: AppColors.primary,
                  ),
                  bgcolor: AppColors.textFieldBgColor,
                  borderSide: BorderSide(
                    color: AppColors.borderColorLight,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),
              Obx(
                () => CustomTextField(
                  isPassword: controller.isConfirmPasswordHidden.value,
                  controller: controller.confirmPasswordController,
                  hintText: "Enter Your Confirm Password",
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.borderColor,
                  ),
                  prefixIcon: Icon(
                    Icons.password_outlined,
                    color: AppColors.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordHidden.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.isConfirmPasswordHidden.toggle,
                  ),
                  bgcolor: AppColors.textFieldBgColor,
                  borderSide: BorderSide(
                    color: AppColors.borderColorLight,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),
              Obx(
                () => CustomElevatedButton(
                  onPressed: controller.signUp,
                  btnName: "Sign Up",
                  isLoading: controller.isLoading.value,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "I already have an account. ",
                    style: AppTextStyles.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.SIGN_IN);
                    },
                    child: Text(
                      "Log In",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  const Expanded(
                    child: Divider(thickness: 2, color: AppColors.hintTextColor),
                  ),
                  Text(
                    '  Continue with  ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.borderColor,
                    ),
                  ),
                  const Expanded(
                    child: Divider(thickness: 2, color: AppColors.hintTextColor),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              SocialLoginButton(
                assetPath: "assets/icons/google.png",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPhoto() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Outer Border Circle
            Container(
              height: 100.w,
              width: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: Center(
                child: Container(
                  height: 90.w,
                  width: 90.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 55.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),

            // Green Plus Button
            Positioned(
              bottom: -2,
              right: -2,
              child: GestureDetector(
                onTap: () {
                  // open image picker
                },
                child: Container(
                  height: 32.w,
                  width: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(Icons.add, color: AppColors.white, size: 22.sp),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
