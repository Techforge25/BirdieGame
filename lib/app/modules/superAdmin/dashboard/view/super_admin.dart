import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_club_detail_grid.dart';
import 'package:bierdygame/app/widgets/custom_double_bar.dart';
import 'package:bierdygame/app/widgets/custom_profile_bar.dart';
import 'package:bierdygame/app/modules/superAdmin/widgets/custom_gradient_grid.dart';
import 'package:bierdygame/app/modules/superAdmin/profile/controller/super_admin_profile_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/super_admin_bottom_nav/controller/super_admin_bot_nav_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<SuperAdminProfileController>();
    final navController = Get.find<SuperAdminBotNavController>();
    return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListView(
            children: [
              SizedBox(height: 20.h),
              Obx(
                () => CustomProfileBar(
                  onTap: () {
                    Get.toNamed(Routes.NOTIFICATIONS);
                  },
                  onAvatarTap: () {
                    navController.changeTab(4);
                  },
                  bgImg: 'assets/images/dashboard_img.png',
                  name: profileController.displayName.value.isNotEmpty
                      ? profileController.displayName.value
                      : 'Super Admin',
                  imageProvider: profileController.photoBytes.value != null
                      ? MemoryImage(profileController.photoBytes.value!)
                      : null,
                  imageUrl: profileController.photoUrl.value,
                ),
              ),
              SizedBox(height: 20.h),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('clubs')
                    .snapshots(),
                builder: (context, clubsSnapshot) {
                  final clubs = clubsSnapshot.data?.docs ?? [];
                  final totalClubs = clubs.length;
                  final blockedClubs = clubs.where((doc) {
                    final status =
                        (doc.data()['status'] ?? 'active').toString();
                    return status == 'blocked';
                  }).length;
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'club_admin')
                        .snapshots(),
                    builder: (context, adminsSnapshot) {
                      final admins = adminsSnapshot.data?.docs ?? [];
                      final activeAdmins = admins.where((doc) {
                        final data = doc.data();
                        final isActive = data['isActive'] == true;
                        final status =
                            (data['status'] ?? '').toString().toLowerCase();
                        return isActive || status == 'active';
                      }).length;
                      return ClubsDetailGrid(
                        value1: totalClubs.toString(),
                        value2: activeAdmins.toString(),
                        value3: "0",
                        value4: blockedClubs.toString(),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20.h),
              CustomGradientGrid(),
              SizedBox(height: 20.h),
              CustomDoubleBar(),
              SizedBox(height: 20.h),
              Text("Recent Activity",style: AppTextStyles.subHeading,),
              Text(
                textAlign: TextAlign.center,
                "Your Recent Activities will appear here"
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      );
    
  }

  
}
