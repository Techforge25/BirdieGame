import 'package:bierdygame/app/modules/player/playerProfile/controller/player_profile_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PlayerProfile extends GetView<PlayerProfileController> {
  const PlayerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        centerTitle: true,
        title: Text("Profile", style: AppTextStyles.bodyMedium2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage:
                        AssetImage("assets/images/dashboard_img.png"),
                  ),
                  Text(
                    "Player Name",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textBlack,
                    ),
                  ),
                  Text("player123@gmail.com")
                ],
              ),
            ),
            SizedBox(height: 10.h),
            _buildProfileContainer(
              name: "Edit Profile",
              onTap: () {},
              icon: Icon(Icons.person_outline, size: 15),
            ),
            SizedBox(height: 10.h),
            _buildProfileContainer(
              name: "Notifications",
              onTap: () {},
              icon: Icon(Icons.notifications_outlined, size: 15),
            ),
            SizedBox(height: 10.h),
            _buildProfileContainer(
              name: "Settings",
              onTap: () {},
              icon: Icon(Icons.settings_outlined, size: 15),
            ),
            SizedBox(height: 10.h),
            _buildProfileContainer(
              name: "Help & Support",
              onTap: () {},
              icon: Icon(Icons.help_center_outlined, size: 15),
            ),
            SizedBox(height: 10.h),
            _buildProfileContainer(
              name: "Log Out",
              onTap: () => controller.logout(),
              icon: Icon(Icons.logout_outlined, size: 15),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProfileContainer({
    required String name,
    required VoidCallback onTap,
    required Icon icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.borderColorLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: 10.w),
            Text(
              name,
              style: AppTextStyles.bodyMedium2.copyWith(color: Colors.black),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 15),
          ],
        ),
      ),
    );
  }
}
