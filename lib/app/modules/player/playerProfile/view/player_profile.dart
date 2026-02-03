import 'package:bierdygame/app/modules/player/playerProfile/controller/player_profile_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert';

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
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseAuth.instance.currentUser == null
                        ? const Stream<
                            DocumentSnapshot<Map<String, dynamic>>
                          >.empty()
                        : FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data() ?? {};
                      final name =
                          (data['displayName'] ?? data['name'] ?? 'Player')
                              .toString();
                      final email = (data['email'] ?? '').toString();
                      final photoBase64 = (data['photoBase64'] ?? '')
                          .toString();
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 50.r,
                            backgroundImage: photoBase64.isNotEmpty
                                ? MemoryImage(base64Decode(photoBase64))
                                : const AssetImage(
                                        "assets/images/dashboard_img.png",
                                      )
                                      as ImageProvider,
                          ),
                          Text(
                            name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textBlack,
                            ),
                          ),
                          if (email.isNotEmpty) Text(email),
                        ],
                      );
                    },
                  ),
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
