import 'package:bierdygame/app/modules/admins/adminController/admin_controller.dart';
import 'package:bierdygame/app/modules/admins/widget/admin_detail_card.dart';
import 'package:bierdygame/app/modules/admins/widget/status_container.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:bierdygame/app/widgets/modal_footer_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadFromArgs(Get.arguments as Map<String, dynamic>?);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userStream = currentUserId.isEmpty
        ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
        : FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userStream,
      builder: (context, snapshot) {
        final role = snapshot.data?.data()?['role']?.toString().toLowerCase();
        final isSuperAdmin = role == 'super_admin' || role == 'superadmin';

        if (!isSuperAdmin &&
            controller.adminId.isNotEmpty &&
            controller.adminId != currentUserId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Get.snackbar(
              "Access Denied",
              "You can only edit your own profile",
            );
            Get.back();
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBackground,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon:
                  Icon(Icons.arrow_back_ios, size: 18, color: AppColors.primary),
            ),
            title: Text(
              "Admin Edit",
              style: AppTextStyles.bodyMedium2.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Obx(
                        () => buildAdminDetailCard(
                          name: controller.nameController.text.isEmpty
                              ? "Admin"
                              : controller.nameController.text,
                          clubName: controller.clubNameController.text.isEmpty
                              ? "Unknown"
                              : controller.clubNameController.text,
                          role: controller.roleController.text.isEmpty
                              ? "club_admin"
                              : controller.roleController.text,
                          isActive: controller.status.value,
                          photoBase64: controller.photoBase64.value,
                          onAvatarTap: controller.pickPhoto,
                        ),
                      ),
                      SizedBox(height: 25.h),
                      Text("Edit Admin Details",
                          style: AppTextStyles.bodyMedium2),
                      SizedBox(height: 20.h),

                      CustomFormField(
                        label: "Full Name",
                        borderSide:
                            BorderSide(color: AppColors.borderColorLight),
                        hint: "Admin Name",
                        controller: controller.nameController,
                        borderRadius: BorderRadius.circular(12),
                        labeltextStyle: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 12.h),
                      CustomFormField(
                        label: "Email",
                        borderSide:
                            BorderSide(color: AppColors.borderColorLight),
                        borderRadius: BorderRadius.circular(12),
                        hint: "Admin email",
                        controller: controller.emailController,
                        labeltextStyle: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 12.h),
                      CustomFormField(
                        label: "Club Name",
                        borderSide:
                            BorderSide(color: AppColors.borderColorLight),
                        borderRadius: BorderRadius.circular(12),
                        hint: "Admin Club",
                        controller: controller.clubNameController,
                        enable: isSuperAdmin,
                        labeltextStyle: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 12.h),
                      CustomFormField(
                        label: "Role",
                        borderSide:
                            BorderSide(color: AppColors.borderColorLight),
                        borderRadius: BorderRadius.circular(12),
                        hint: "Admin Role",
                        controller: controller.roleController,
                        enable: false,
                        labeltextStyle: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      if (isSuperAdmin)
                        Obx(
                          () => buildWidgetStatus(
                            status: controller.status.value,
                            onChanged: (v) => controller.status.value = v,
                          ),
                        ),

                      if (isSuperAdmin) ...[
                        SizedBox(height: 20.h),
                        Text("Account Actions",
                            style: AppTextStyles.bodyMedium2),
                        SizedBox(height: 10.h),
                        _buildAccountActionCards(
                          title: "Reset Password",
                          subtitle: "Send a new Temporary Password",
                          onTap: controller.resetPassword,
                          icon: Icon(Icons.restore, color: AppColors.darkBlue),
                          borderColor: AppColors.darkBlue,
                          iconBgColor: AppColors.flashyblue,
                          bgColor: AppColors.flashyblue,
                        ),
                        SizedBox(height: 8.h),
                        _buildAccountActionCards(
                          title: "Suspend Account",
                          subtitle: "Disable login access for this Admin",
                          onTap: controller.suspendAccount,
                          icon: Icon(Icons.pause, color: AppColors.secondary),
                          borderColor: AppColors.secondary,
                          iconBgColor: AppColors.flashyYellow,
                          bgColor: AppColors.flashyYellow,
                        ),
                        SizedBox(height: 8.h),
                        _buildAccountActionCards(
                          title: "Delete Account",
                          subtitle: "Permanently remove this Admin",
                          onTap: controller.deleteAccount,
                          icon: Icon(Icons.delete, color: AppColors.darkRed),
                          borderColor: AppColors.darkRed,
                          iconBgColor: AppColors.flashyRed,
                          bgColor: AppColors.flashyRed,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 20.h),
                ModalFooterBtn(
                  borderColor: AppColors.primary,
                  text1: "Save Changes",
                  text2: "Cancel",
                  onTap1: controller.saveChanges,
                  onTap2: () {
                    Get.back();
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountActionCards({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Icon icon,
    required Color borderColor,
    required Color iconBgColor,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.5.w),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: iconBgColor, child: icon),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 16.sp,
            color: borderColor,
          ),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
