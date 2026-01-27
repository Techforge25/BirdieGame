import 'package:bierdygame/app/modules/golfClub/clubEdit/controller/club_edit_controller.dart';
import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:bierdygame/app/widgets/custom_modal.dart';
import 'package:bierdygame/app/widgets/custom_text_field.dart';
import 'package:bierdygame/app/widgets/modal_footer_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

class ClubEditModal extends GetView<ClubEditController> {
  const ClubEditModal({super.key});

  Widget _adminsList() {
    final clubId = controller.clubId;
    if (clubId == null || clubId.isEmpty) {
      return Text("No admins available", style: AppTextStyles.bodySmall);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('clubId', isEqualTo: clubId)
          .where('role', isEqualTo: 'club_admin')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text("No admins available", style: AppTextStyles.bodySmall);
        }
        final admins = snapshot.data!.docs;
        if (controller.adminCount.value != admins.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              return;
            }
            controller.adminCount.value = admins.length;
          });
        }
        return Container(
          decoration: BoxDecoration(
            color: AppColors.flashyGreen,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const Divider(indent: 20, endIndent: 20),
            itemCount: admins.length,
            itemBuilder: (context, index) {
              final data = admins[index].data();
              final name = (data['displayName'] ?? 'Admin').toString();
              final email = (data['email'] ?? '').toString();
              final isCurrentUser =
                  admins[index].id == FirebaseAuth.instance.currentUser?.uid;
              final isActive =
                  data['isActive'] == null ? true : data['isActive'] == true;
              return ListTile(
                leading: const CircleAvatar(),
                title: Text(name, style: AppTextStyles.bodyMedium),
                subtitle: Text(email),
                trailing: isCurrentUser
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          Get.toNamed(
                            Routes.ADMIN_VIEW,
                            arguments: {
                              'adminId': admins[index].id,
                              'name': name,
                              'email': email,
                              'clubId': clubId,
                              'clubName': controller.initialName,
                              'role': 'club_admin',
                              'isActive': isActive,
                            },
                          );
                        },
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: "Profile Edit",
      content: SingleChildScrollView(
        child: Column(
          spacing: 10.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.h),
            CustomFormField(
              borderSide: BorderSide(
                width: 1,
                color: AppColors.borderColorLight,
              ),
              label: "Club Name",
              hint: "Enter Club Name",
              controller: controller.clubNameController,
              labeltextStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomFormField(
              borderSide: BorderSide(
                width: 1,
                color: AppColors.borderColorLight,
              ),
              label: "Location/City",
              hint: "Enter city",
              controller: controller.clubLocationController,
              labeltextStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Logo Upload",
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 39.0),
              child: GestureDetector(
                onTap: controller.pickLogo,
                child: DottedBorder(
                  options: RectDottedBorderOptions(
                    dashPattern: [6, 6],
                    color: AppColors.primary,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200.h,
                    child: Obx(() {
                      final path = controller.logoPath.value;
                      if (path != null && path.isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      }
                      final base64Logo = controller.logoBase64.value;
                      if (base64Logo != null && base64Logo.isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.memory(
                            base64Decode(base64Logo),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10.h,
                          children: [
                            Container(
                              height: 40.h,
                              width: 40.w,
                              decoration: BoxDecoration(
                                color: AppColors.flashyGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.upload_file_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              "Upload the Club Logo",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            Text(
                              controller.logoName.value ??
                                  "SVG,PNG,JPG (max. 400x400px)",
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            Text(
              "Club Admins",
              style: AppTextStyles.bodyLarge.copyWith(fontSize: 20.sp),
            ),
            _adminsList(),
            Obx(
              () => controller.showAddAdminForm.value
                  ? Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.borderColorLight),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Admin",
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Obx(
                                () => Checkbox(
                                  value: controller.isNewAdmin.value,
                                  onChanged: (checked) {
                                    controller.isNewAdmin.value =
                                        checked ?? true;
                                    if (!controller.isNewAdmin.value) {
                                      controller.adminNameController.clear();
                                      controller.adminPasswordController.clear();
                                    }
                                  },
                                ),
                              ),
                              Text("New Admin"),
                              SizedBox(width: 12.w),
                              Obx(
                                () => Checkbox(
                                  value: !controller.isNewAdmin.value,
                                  onChanged: (checked) {
                                    controller.isNewAdmin.value =
                                        !(checked ?? false);
                                    if (!controller.isNewAdmin.value) {
                                      controller.adminNameController.clear();
                                      controller.adminPasswordController.clear();
                                    }
                                  },
                                ),
                              ),
                              Text("Existing Admin"),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Obx(
                            () => CustomFormField(
                              label: "Admin Name",
                              hint: "Enter admin's full name",
                              controller: controller.adminNameController,
                              enable: controller.isNewAdmin.value,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          CustomFormField(
                            label: "Admin Email",
                            hint: "Enter admin's email address",
                            controller: controller.adminEmailController,
                          ),
                          Obx(() {
                            if (!controller.isNewAdmin.value) {
                              return SizedBox(height: 12.h);
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 12.h),
                                Text(
                                  "Admin Password",
                                  style: AppTextStyles.bodySmall,
                                ),
                                SizedBox(height: 4.h),
                                CustomTextField(
                                  controller:
                                      controller.adminPasswordController,
                                  hintText: "Enter admin's password",
                                  isPassword: true,
                                  borderSide: BorderSide(
                                    color: AppColors.borderColorLight,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ],
                            );
                          }),
                          SizedBox(height: 12.h),
                          CustomElevatedButton(
                            onPressed: controller.createAdmin,
                            btnName: "Add Admin",
                            backColor: AppColors.primary,
                            textColor: AppColors.white,
                            borderRadius: 12.r,
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: GestureDetector(
                onTap: controller.showAddAdmin,
                child: Container(
                  height: 40.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.flashyGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "+ Add another Admin",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                "Maximum of 5 admins per club.",
                style: AppTextStyles.bodySmall,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: AppColors.flashyGreen,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("location", style: AppTextStyles.bodySmall),
                            Text(
                              controller.initialLocation ?? "Unknown",
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Joined Date",
                              style: AppTextStyles.bodySmall,
                            ),
                            Text(
                              DateFormat('dd-MM-yyyy')
                                  .format(DateTime.now())
                                  .toString(),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Games",
                              style: AppTextStyles.bodySmall,
                            ),
                            Text("1,124", style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Player",
                              style: AppTextStyles.bodySmall,
                            ),
                            Text("225", style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        ModalFooterBtn(
          text1: "Save Changes",
          text2: "Cancel",
          onTap1: controller.saveChanges,
          onTap2: () => Get.back(),
        ),
      ],
    );
  }
}
