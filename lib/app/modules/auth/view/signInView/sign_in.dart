import 'package:bierdygame/app/modules/auth/controller/auth_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_text_field.dart';
import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignInView extends GetView<AuthController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 51, vertical: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/images/white_logo.png')),
            SizedBox(height: 40.h),
            Center(child: Text("Welcome Back", style: AppTextStyles.bodyLarge)),
            Center(
              child: Text(
                "Sign in to continue your game",
                style: AppTextStyles.bodyMedium,
              ),
            ),
            SizedBox(height: 30.h),
            CustomTextField(
              controller: controller.emailController,
              hintText: "Enter your email",
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
                controller: controller.passwordController,
                hintText: "Enter Your Password",
                isPassword: controller.isPasswordHidden.value,
                prefixIcon: Icon(
                  Icons.password_outlined,
                  color: AppColors.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.isPasswordHidden.toggle,
                ),
                bgcolor: AppColors.textFieldBgColor,
                borderSide: BorderSide(
                  color: AppColors.borderColorLight,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 10.h),
            Text(
              "Forget Password ?",
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 40.h),
            Obx(
              () => CustomElevatedButton(
                onPressed: controller.signIn,
                btnName: "Login",
                isLoading: controller.isLoading.value,
              ),
            ),

            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account ? ",
                  style: AppTextStyles.bodySmall,
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.SIGN_UP);
                  },
                  child: Text(
                    "Sign Up",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
