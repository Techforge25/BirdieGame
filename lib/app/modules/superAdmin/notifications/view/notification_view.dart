import 'package:bierdygame/app/modules/superAdmin/notifications/controller/notification_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/notifications/widgets/notification_tab_bar.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 100.w),
                  Text("Notifications", style: AppTextStyles.miniHeadings),
                ],
              ),
              SizedBox(height: 15.h),
              Obx(
                () => NotificationTabBar(
                  title1: "All",
                  title2: "Active",
                  selectedIndex: controller.selectedTab.value,
                  onChanged: controller.changeTab,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  // If a club is selected, show profile, otherwise show list
                  switch (controller.selectedTab.value) {
                    case 0:
                      return _allNotifications();
                    default:
                      return _unreadNotifications();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// List of All Clubs
  Widget _allNotifications() {
  return Center(child: Text("All Notifications"),);
}


  /// Blocked Clubs placeholder
  Widget _unreadNotifications() => const Text("Unread Notifications");

  
}
