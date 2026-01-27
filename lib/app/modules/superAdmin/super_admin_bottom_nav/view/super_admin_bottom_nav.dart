import 'package:bierdygame/app/modules/superAdmin/super_admin_bottom_nav/controller/super_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuperAdminBottomNav extends StatelessWidget {
  SuperAdminBottomNav({super.key});

  final SuperAdminBotNavController controller =
      Get.find<SuperAdminBotNavController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (controller.currentIndex.value != 0) {
          controller.changeTab(0);
        }
      },
      child: Scaffold(
        body: Obx(() => controller.screens[controller.currentIndex.value]),
      
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 26),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_outlined,
                label: "Home",
                index: 0,
                ),
              _navItem(
                icon: Icons.sports_golf,
                label: "Clubs",
                index: 1,
                ),
              _navItem(
                icon: Icons.add_outlined,
                label: "New Club",
                index: 2,
                ),
              _navItem(
                icon: Icons.admin_panel_settings_outlined,
                label: "Admins",
                index: 3,
              ),
              _navItem(
                icon: Icons.person_outline,
                label: "Profile", 
                index: 4,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return Obx(() {
      bool isSelected = controller.currentIndex.value == index;

      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green top indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 5),
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.bottomIconColor,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.bottomIconColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}
