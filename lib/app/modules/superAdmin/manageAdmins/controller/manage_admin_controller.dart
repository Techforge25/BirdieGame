import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ManageAdminsController extends GetxController {
  RxInt selectedTab = 0.obs;
  Rx<String?> selectedClub = Rx<String?>(null);
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedRole = 'club_admin'.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim().toLowerCase();
    });
  }

  void changeTab(int index) {
    selectedTab.value = index;
     selectedClub.value = null;
  }

  void openCreateAdminDialog() {
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
                        Icons.admin_panel_settings,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    Text(
                      "Create Admin Invite",
                      style: AppTextStyles.bodyMedium2.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomFormField(
                label: "Full Name",
                hint: "Enter admin name",
                controller: nameController,
              ),
              SizedBox(height: 12.h),
              CustomFormField(
                label: "Email",
                hint: "Enter admin email",
                controller: emailController,
              ),
              SizedBox(height: 12.h),
              Obx(
                () => CustomFormField(
                  label: "Role",
                  hint: selectedRole.value,
                  isDropdown: true,
                  items: const ["club_admin", "super_admin"],
                  onChanged: (value) {
                    if (value is String) {
                      selectedRole.value = value;
                    }
                  },
                ),
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                onPressed: createAdminInvite,
                btnName: "Create Invite",
                backColor: AppColors.primary,
                textColor: AppColors.white,
                borderRadius: 15.r,
              ),
              SizedBox(height: 10.h),
              CustomElevatedButton(
                onPressed: () {
                  Get.back();
                },
                btnName: "Cancel",
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

  Future<void> createAdminInvite() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    if (name.isEmpty || email.isEmpty) {
      Get.snackbar("Error", "Name and email are required");
      return;
    }

    await FirebaseFirestore.instance.collection('role_invites').doc(email).set({
      'displayName': name,
      'email': email,
      'role': selectedRole.value,
      'createdAt': FieldValue.serverTimestamp(),
    });

    nameController.clear();
    emailController.clear();
    Get.back();
    Get.snackbar("Success", "Invite created for $email");
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
