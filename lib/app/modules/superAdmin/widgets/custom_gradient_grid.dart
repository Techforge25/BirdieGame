import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/modules/superAdmin/super_admin_bottom_nav/controller/super_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomGradientGrid extends StatelessWidget {

  const CustomGradientGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final SuperAdminBotNavController bottomNavController = Get.find();
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isNarrow ? 1 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 9,
          childAspectRatio: isNarrow ? 2.2 : 1.2,
          children: [
            _buildStatCard(
              onTap: () {
                bottomNavController.changeTab(2);
              },
              color1: Color(0xffE3F2FD),
              color2: Color(0xffBBDEFB),
              title: "Add New Clubs",
              subTitle: "Create a new club and assign admins.",
              iconBgColor: Color(0xff1A4FA3),
              icon: Icons.add,
            ),
            _buildStatCard(
              onTap: () {
                bottomNavController.changeTab(1);
              },
              color1: Color(0xffF1F8E9),
              color2: Color(0xffDCEDC8),
              iconBgColor: Color(0xff254F2C),
              title: "Manage Clubs",
              subTitle: "View, edit, block, or remove clubs.",
              icon: Icons.sports_golf,
            ),
            _buildStatCard(
              onTap: () {
                bottomNavController.changeTab(3);
              },
              color1: Color(0xffFFF3E0),
              color2: Color(0xffFFE0B2),
              iconBgColor: AppColors.secondary,
              title: "Manage Admins",
              subTitle: "Control club admins, roles, and access.",
              icon: Icons.settings,
            ),
            _buildStatCard(
              onTap: () {
                Get.toNamed(Routes.REPORTS_AND_ANALYTICS_SUPER_ADMIN);
              },
              color1: Color(0xffF3E5F5),
              color2: Color(0xffE1BEE7),
              iconBgColor: Color(0xff7A2BAA),
              title: "Analytics",
              subTitle: "Track performance and view statistics.",
              icon: Icons.bar_chart,
              valueColor: Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String subTitle,
    required IconData icon,
    required Color iconBgColor,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
    Color? valueColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentGeometry.topLeft,
            end: AlignmentGeometry.bottomRight,
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColorLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium2.copyWith(color: iconBgColor),
            ),
            SizedBox(height: 4.h),
            Expanded(
              child: Text(
                subTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: iconBgColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
