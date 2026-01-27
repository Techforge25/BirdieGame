import 'package:bierdygame/app/modules/player/playerBottomNav/controller/player_bottom_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerBottomNav extends StatelessWidget {
  PlayerBottomNav({super.key});

  final PlayerBottomController controller = Get.find<PlayerBottomController>();

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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(
                icon: Icons.dashboard_outlined,
                label: "Home",
                index: 0,
                ),
              _navItem(
                icon: Icons.trending_up_outlined,
                label: "LeaderBoard",
                index: 1,
                ),
              _navItem(
                icon: Icons.sports_golf,
                label: "Join Game",
                index: 2,
                ),
              _navItem(
                icon: Icons.leaderboard_outlined,
                label: "My Stats",
                index: 3,
                ),
                
              _navItem(
                icon: Icons.person_2_outlined,
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
              size: 24,
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
