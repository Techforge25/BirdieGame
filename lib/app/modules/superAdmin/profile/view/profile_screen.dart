import 'package:bierdygame/app/modules/superAdmin/profile/controller/super_admin_profile_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/profile/bindings/edit_profile_binding.dart';
import 'package:bierdygame/app/modules/superAdmin/profile/view/edit_profile_screen.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileScreen extends GetView<SuperAdminProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.white,
        title: Text("Profile", style: AppTextStyles.miniHeadings),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 18.h),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: controller.photoBytes.value != null
                            ? MemoryImage(controller.photoBytes.value!)
                            : controller.photoUrl.value.isNotEmpty
                                ? NetworkImage(controller.photoUrl.value)
                                    as ImageProvider
                                : const AssetImage(
                                    "assets/images/white_logo.png",
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Text(
                      controller.displayName.value.isNotEmpty
                          ? controller.displayName.value
                          : "Super Admin",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Super Admin",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomElevatedButton(
                    onPressed: () {
                      Get.to(
                        () => EditProfileScreen(),
                        binding: EditProfileBinding(),
                      );
                    },
                    btnName: "Edit",
                    icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                    textColor: AppColors.primary,
                    width: 140.w,
                    height: 40,
                    borderRadius: 50.r,
                    backColor: Colors.transparent,
                    borderColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Obx(
                () => Column(
                  children: [
                    _InfoTile(
                      icon: Icons.person,
                      label: "Full Name",
                      value: controller.displayName.value,
                    ),
                    Divider(),
                    _InfoTile(
                      icon: Icons.email,
                      label: "Email",
                      value: controller.email.value,
                    ),
                    Divider(),
                    _InfoTile(
                      icon: Icons.phone,
                      label: "Phone Number",
                      value: controller.phoneNumber.value,
                    ),
                    Divider(),
                    _InfoTile(
                      icon: Icons.business,
                      label: "Organization",
                      value: "Birdie Game",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: _cardDecoration(),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: controller.logout,
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
