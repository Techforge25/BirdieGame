import 'package:bierdygame/app/modules/superAdmin/addClubs/controller/add_clubs_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:bierdygame/app/widgets/custom_modal.dart';
import 'package:bierdygame/app/widgets/custom_text_field.dart';
import 'package:bierdygame/app/widgets/modal_footer_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AddClubModal extends GetView<AddClubsController> {
  const AddClubModal({super.key});

  Widget _adminList() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.flashyGreen,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const Divider(indent: 20, endIndent: 20),
          itemCount: controller.admins.length,
          itemBuilder: (context, index) {
            final admin = controller.admins[index];
            return ListTile(
              leading: const CircleAvatar(),
              title: Text(admin.name, style: AppTextStyles.bodyMedium),
              subtitle: Text(admin.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () async {
                      await controller.deleteAdminByEmail(admin.email);
                      controller.removeAdminAt(index);
                    },
                    child: Icon(Icons.delete, color: AppColors.darkRed),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _addAdminForm() {
    return Container(
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
          CustomFormField(
            label: "Admin Name",
            hint: "Enter admin's full name",
            controller: controller.nameController,
          ),
          SizedBox(height: 12.h),
          CustomFormField(
            label: "Admin Email",
            hint: "Enter admin's email address",
            controller: controller.emailController,
          ),
          SizedBox(height: 12.h),
          Text(
            "Admin Password",
            style: AppTextStyles.bodySmall,
          ),
          SizedBox(height: 4.h),
          Obx(
            () => CustomTextField(
              controller: controller.passwordController,
              hintText: "Enter admin's password",
              isPassword: controller.isPasswordHidden.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordHidden.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.isPasswordHidden.toggle,
              ),
              borderSide: BorderSide(color: AppColors.borderColorLight),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Admin can log in with this password.",
            style: AppTextStyles.bodySmall,
          ),
          SizedBox(height: 12.h),
          CustomElevatedButton(
            onPressed: controller.sendAdminInvite,
            btnName: "Add Admin",
            backColor: AppColors.primary,
            textColor: AppColors.white,
            borderRadius: 12.r,
          ),
        ],
      ),
    );
  }

  Widget _pendingInvites() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: controller.pendingInvitesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              "No pending invites",
              style: AppTextStyles.bodySmall,
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const Divider(indent: 20, endIndent: 20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data();
            final email = (data['email'] ?? doc.id).toString();
            final name = (data['displayName'] ?? 'Admin').toString();
            final role = (data['role'] ?? 'club_admin').toString();
            return ListTile(
              leading: const CircleAvatar(),
              title: Text(name, style: AppTextStyles.bodyMedium),
              subtitle: Text("$email - $role"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: AppColors.primary),
                    onPressed: () => controller.resendInvite(email),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppColors.darkRed),
                    onPressed: () => controller.deleteInvite(email),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: "Club Edit",
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
                    child: Center(
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
                          Obx(
                            () => Text(
                              controller.logoName.value ??
                                  "SVG,PNG,JPG (max. 400x400px)",
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Master Admin Setup",
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 20.sp),
                ),
                Text(
                  "This will create the primary administrator account.",
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            _adminList(),
            Obx(
              () => controller.showAddAdminForm.value
                  ? _addAdminForm()
                  : SizedBox.shrink(),
            ),
            SizedBox(height: 10.h),
            Text(
              "Pending Invites",
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            _pendingInvites(),

            /// ---- ADD BUTTON ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: GestureDetector(
                onTap: controller.showAddAdminFormIfAllowed,
                child: Container(
                  height: 40.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.flashyGreen,
                    borderRadius: BorderRadius.circular(20),
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
          ],
        ),
      ),
      actions: [
        ModalFooterBtn(
          text1: "Create Club",
          text2: "Cancel",
          onTap1: () => controller.createClub(closeOnSuccess: true),
          onTap2: () => Get.back(),
        ),
      ],
    );
  }
}

