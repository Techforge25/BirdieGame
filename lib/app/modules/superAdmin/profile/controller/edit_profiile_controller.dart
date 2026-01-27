import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class EditProfileController extends GetxController {
  /// ---------------- TEXT CONTROLLERS ----------------
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final photoUrl = ''.obs;
  final pickedImagePath = ''.obs;
  final photoBase64 = ''.obs;

  /// ---------------- STATES ----------------
  final isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ---------------- INIT ----------------
  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    nameController.text =
        (data['displayName'] ?? user.displayName ?? '').toString();
    emailController.text = (data['email'] ?? user.email ?? '').toString();
    phoneController.text = (data['phoneNumber'] ?? '').toString();
    photoUrl.value = (data['photoUrl'] ?? '').toString();
    photoBase64.value = (data['photoBase64'] ?? '').toString();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    pickedImagePath.value = picked.path;
  }

  /// ---------------- SAVE PROFILE ----------------
  void saveProfile() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          "Error",
          "User not found",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      String? nextPhotoBase64;
      final localPath = pickedImagePath.value;
      if (localPath.isNotEmpty) {
        final bytes = await File(localPath).readAsBytes();
        nextPhotoBase64 = base64Encode(bytes);
      }

      final name = nameController.text.trim();
      final email = emailController.text.trim().toLowerCase();
      final phone = phoneController.text.trim();

      await _firestore.collection('users').doc(user.uid).set({
        'displayName': name,
        'email': email,
        'phoneNumber': phone,
        if (nextPhotoBase64 != null) 'photoBase64': nextPhotoBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('super_admin')
          .doc('profile')
          .set({
        'displayName': name,
        'email': email,
        'phoneNumber': phone,
        if (nextPhotoBase64 != null) 'photoBase64': nextPhotoBase64,
        'role': 'super_admin',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (user.displayName != name) {
        await user.updateDisplayName(name);
      }
      if (user.email != email) {
        await user.verifyBeforeUpdateEmail(email);
      }



      Get.snackbar(
        "Success",
        "Profile updated successfully",
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back(); // go back to profile screen
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- RESET PASSWORD ----------------
  void resetPassword() async {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16,),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: AppColors.flashyblue,
            border: Border.all(color: AppColors.darkBlue),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reset Admin Password",
                style: AppTextStyles.bodyMedium2.copyWith(
                  color: AppColors.textBlack,
                  fontSize: 22.sp,
                ),
              ),
              Text("Enter New Password"),
              SizedBox(height: 15.h),
              CustomFormField(
                bgcolor: Colors.transparent,
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: AppColors.darkBlue, width: 1.5.w),
                hint: "Enter Current Password",
                label: "Current Password",
                labeltextStyle: AppTextStyles.bodyMedium2.copyWith(
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 15.h),
              CustomFormField(
                bgcolor: Colors.transparent,
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: AppColors.darkBlue, width: 1.5.w),
                hint: "Enter New Password",
                label: "New Password",
                labeltextStyle: AppTextStyles.bodyMedium2.copyWith(
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 15.h),
              CustomFormField(
                bgcolor: Colors.transparent,
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: AppColors.darkBlue, width: 1.5.w),
                hint: "Confirm New Password",
                label: "Confirm Password",
                labeltextStyle: AppTextStyles.bodyMedium2.copyWith(
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                "Password must be at least 8 characters",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.borderColor,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim().toLowerCase();
                  if (email.isEmpty) {
                    Get.snackbar(
                      "Error",
                      "Email is required",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  Get.back();
                  Get.snackbar(
                    "Sent",
                    "Password reset email sent",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                btnName: "Update Password",
                backColor: AppColors.darkBlue,
                textColor: AppColors.white,
                borderRadius: 15.r,
              ),
              SizedBox(height: 10.h),
              CustomElevatedButton(
                onPressed: () {
                  Get.back();
                },
                btnName: "Cancel",
                backColor: AppColors.flashyblue,
                textColor: AppColors.darkBlue,
                borderColor: AppColors.darkBlue,
                borderRadius: 15.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- DISPOSE ----------------
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
