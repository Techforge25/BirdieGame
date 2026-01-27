import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';

class AdminController extends GetxController {
  RxBool status = false.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final clubNameController = TextEditingController();
  final roleController = TextEditingController();
  final photoBase64 = ''.obs;
  String adminId = '';
  String clubId = '';
  bool _loaded = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void loadFromArgs(Map<String, dynamic>? args) {
    if (_loaded || args == null) return;
    adminId = (args['adminId'] ?? '').toString();
    clubId = (args['clubId'] ?? '').toString();
    nameController.text = (args['name'] ?? '').toString();
    emailController.text = (args['email'] ?? '').toString();
    clubNameController.text = (args['clubName'] ?? '').toString();
    roleController.text = (args['role'] ?? '').toString();
    photoBase64.value = (args['photoBase64'] ?? '').toString();

    if (args.containsKey('isActive')) {
      status.value = args['isActive'] == true;
    } else if (args.containsKey('status')) {
      status.value = args['status'].toString().toLowerCase() == 'active';
    } else {
      status.value = true;
    }
    _loaded = true;
  }

  Future<void> saveChanges() async {
    if (adminId.isEmpty) {
      Get.snackbar("Error", "Missing admin id");
      return;
    }
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final clubName = clubNameController.text.trim();

    try {
      await _firestore.collection('users').doc(adminId).set({
        'displayName': name,
        'email': email,
        'clubName': clubName,
        'isActive': status.value,
        'status': status.value ? 'active' : 'inactive',
        if (photoBase64.value.isNotEmpty) 'photoBase64': photoBase64.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (clubId.isNotEmpty && clubName.isNotEmpty) {
        await _firestore.collection('clubs').doc(clubId).set({
          'name': clubName,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      final normalizedRole =
          roleController.text.trim().toLowerCase().isEmpty
              ? 'club_admin'
              : roleController.text.trim().toLowerCase();
      await _firestore
          .collection('users')
          .doc(adminId)
          .collection(normalizedRole)
          .doc('profile')
          .set({
        'displayName': name,
        'email': email,
        'clubName': clubName,
        'role': normalizedRole,
        'status': status.value ? 'active' : 'inactive',
        if (photoBase64.value.isNotEmpty) 'photoBase64': photoBase64.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser != null && authUser.uid == adminId) {
        if (name.isNotEmpty && authUser.displayName != name) {
          await authUser.updateDisplayName(name);
        }
        if (email.isNotEmpty && authUser.email != email) {
          await authUser.verifyBeforeUpdateEmail(email);
        }
        await authUser.reload();
      } else {
        Get.snackbar(
          "Note",
          "Firestore updated. Auth updates require the user to be signed in or an admin backend.",
        );
      }

      Get.snackbar("Saved", "Admin updated");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Auth error", e.message ?? "Failed to update auth user");
    } catch (e) {
      Get.snackbar("Error", "Failed to save changes");
    }
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await File(picked.path).readAsBytes();
    photoBase64.value = base64Encode(bytes);
  }
  void resetPassword() {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
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
                  final email = emailController.text.trim();
                  if (email.isEmpty) {
                    Get.snackbar("Error", "Admin email is missing");
                    return;
                  }
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  Get.back();
                  Get.snackbar("Sent", "Password reset email sent");
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

  void deleteAccount() {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: AppColors.flashyRed,
            border: Border.all(color: AppColors.darkRed),
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
                      backgroundColor: AppColors.flashyRed2,
                      radius: 40.r,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.darkRed,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Delete Admin",
                      style: AppTextStyles.bodyMedium2.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Text(
                      "This action is permanent and cannot be undone\nAll system access will be removed instantly.",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                onPressed: () async {
                  if (adminId.isEmpty) {
                    Get.snackbar("Error", "Missing admin id");
                    return;
                  }
                  try {
                    final clubsSnapshot =
                        await _firestore.collection('clubs').get();
                    for (final clubDoc in clubsSnapshot.docs) {
                      final clubData = clubDoc.data();
                      final admins = clubData['admins'];
                      Map<String, dynamic>? target;
                      if (admins is List) {
                        for (final entry in admins) {
                          if (entry is Map<String, dynamic> &&
                              entry['uid']?.toString() == adminId) {
                            target = entry;
                            break;
                          }
                        }
                      }
                      if (target != null) {
                        await clubDoc.reference.set({
                          'admins': FieldValue.arrayRemove([target]),
                          'updatedAt': FieldValue.serverTimestamp(),
                        }, SetOptions(merge: true));
                      }
                    }

                    final normalizedRole =
                        roleController.text.trim().toLowerCase().isEmpty
                            ? 'club_admin'
                            : roleController.text.trim().toLowerCase();
                    final userRef =
                        _firestore.collection('users').doc(adminId);
                    final batch = _firestore.batch();
                    batch.delete(userRef);
                    batch.delete(userRef.collection(normalizedRole).doc('profile'));
                    await batch.commit();

                    final authUser = FirebaseAuth.instance.currentUser;
                    if (authUser != null && authUser.uid == adminId) {
                      await authUser.delete();
                    }

                    Get.back();
                    Get.snackbar("Deleted", "Admin removed from database");
                  } catch (e) {
                    Get.snackbar("Error", "Failed to delete admin");
                  }
                },
                btnName: "Delete Admin",
                backColor: AppColors.darkRed,
                textColor: AppColors.white,
                borderRadius: 15.r,
              ),
              SizedBox(height: 10.h),
              CustomElevatedButton(
                onPressed: () {
                  Get.back();
                },
                btnName: "Cancel",
                backColor: AppColors.flashyRed,
                textColor: AppColors.darkRed,
                borderColor: AppColors.darkRed,
                borderRadius: 15.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void suspendAccount() {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: AppColors.flashyYellow,
            border: Border.all(color: AppColors.secondary),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.flashyYellow,
                      radius: 40.r,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.secondary,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Suspend Admin Account",
                      style: AppTextStyles.bodyMedium2.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Text(
                      "This admin will temporarily lose access to the system.",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 8.h,),
                    Text(
                      textAlign: TextAlign.center,
                      "You can unsuspend them anytime from Admin Management.",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 13.sp,
                      ),
                    ),
                    
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                onPressed: () async {
                  if (adminId.isEmpty) {
                    Get.snackbar("Error", "Missing admin id");
                    return;
                  }
                  status.value = false;
                  await _firestore.collection('users').doc(adminId).set({
                    'isActive': false,
                    'status': 'inactive',
                    'updatedAt': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                  Get.back();
                  Get.snackbar("Suspended", "account suspended");
                },
                btnName: "Suspend Admin",
                backColor: AppColors.secondary,
                textColor: AppColors.white,
                borderRadius: 15.r,
              ),
              SizedBox(height: 10.h),
              CustomElevatedButton(
                onPressed: () {
                  Get.back();
                },
                btnName: "Cancel",
                backColor: AppColors.flashyYellow,
                textColor: AppColors.secondary,
                borderColor: AppColors.secondary,
                borderRadius: 15.r,
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    clubNameController.dispose();
    roleController.dispose();
    super.onClose();
  }
}
