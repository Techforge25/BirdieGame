import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 151),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/green_logo.png',
              ),
            ),
            CustomElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.SIGN_UP);
              },
              btnName: "Create an Account",
              borderRadius: 40,
              backColor: AppColors.white,
              textColor: AppColors.primary,
              fontSize: 16,
            ),
            SizedBox(height: 10.h),
            CustomElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.SIGN_IN);
              },
              btnName: "Login",
              borderRadius: 40,
              borderColor: AppColors.white,
              textColor: AppColors.white,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}
