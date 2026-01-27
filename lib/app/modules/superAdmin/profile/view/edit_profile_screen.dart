import 'package:bierdygame/app/modules/superAdmin/profile/controller/edit_profiile_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text("Edit Profile", style: AppTextStyles.miniHeadings),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// -------- PROFILE IMAGE ----------
            Column(
              children: [
                Obx(
                  () {
                    ImageProvider avatarProvider =
                        const AssetImage("assets/images/white_logo.png");
                    if (controller.pickedImagePath.value.isNotEmpty) {
                      avatarProvider = FileImage(
                        File(controller.pickedImagePath.value),
                      );
                    } else if (controller.photoBase64.value.isNotEmpty) {
                      avatarProvider = MemoryImage(
                        base64Decode(controller.photoBase64.value),
                      );
                    } else if (controller.photoUrl.value.isNotEmpty) {
                      avatarProvider = NetworkImage(controller.photoUrl.value);
                    }
                    return Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: avatarProvider,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.pickImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 16.h),

            /// -------- FORM ----------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  CustomTextField(
                    borderSide: BorderSide(color: AppColors.borderColorLight,width: 1.5),
                    hintText: "Full Name",
                    controller: controller.nameController,
                    prefixIcon: Icon(Icons.person, color: AppColors.primary),
                  ),
                  SizedBox(height: 12.h),
                  CustomTextField(
                    borderSide: BorderSide(color: AppColors.borderColorLight,width: 1.5),
                    hintText: "Email",
                    controller: controller.emailController,
                    prefixIcon: Icon(Icons.email, color: AppColors.primary),
                  ),
                  SizedBox(height: 12.h),
                  CustomTextField(
                    borderSide: BorderSide(color: AppColors.borderColorLight,width: 1.5),
                    hintText: "Phone Number",
                    controller: controller.phoneController,
                    prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            /// -------- ACCOUNT ACTIONS ----------
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Account Actions", style: AppTextStyles.bodyMedium2),
            ),

            SizedBox(height: 8.h),

            Container(
              decoration: BoxDecoration(
                color: AppColors.flashyblue,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.darkBlue,width: 1.5.w)
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.darkBlue.withOpacity(0.1),
                  child: Icon(Icons.refresh, color: AppColors.darkBlue),
                ),
                title:  Text("Reset Password",style: AppTextStyles.bodyMedium.copyWith(fontSize: 16.sp,color: AppColors.darkBlue),),
                subtitle: const Text("Send a new password to this admin"),
                onTap: controller.resetPassword,
              ),
            ),

            SizedBox(height: 24.h),

            Obx(
              () => CustomElevatedButton(
                onPressed: controller.saveProfile,
                isLoading: controller.isLoading.value,
                btnName: controller.isLoading.value ? "Saving..." : "Save",
                width: double.infinity,
                height: 48,
                backColor: AppColors.primary,
                borderRadius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
