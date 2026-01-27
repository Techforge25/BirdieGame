import 'package:bierdygame/app/modules/golfClub/golfClubProfile/golf_club_profile.dart';
import 'package:bierdygame/app/modules/superAdmin/clubs/controller/super_admin_clubs_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/widgets/add_club_modal.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_tab_bar.dart';
import 'package:bierdygame/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert';

class SuperAdminClubManagement
    extends GetView<SuperAdminClubManagementController> {
  const SuperAdminClubManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Club Management", style: AppTextStyles.miniHeadings),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackground,
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.bottomSheet(
            AddClubModal(),
            ignoreSafeArea: true,
            isScrollControlled: true,
          );
        },
        child: Icon(Icons.add, color: AppColors.white, size: 28.h),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              CustomTextField(
                controller: controller.searchController,
                prefixIcon: const Icon(Icons.search),
                hintText: "Search for Clubs...",
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.borderColor,
                ),
                borderSide: const BorderSide(width: 1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              SizedBox(height: 15.h),
              Obx(
                () => CustomStatusTabBar(
                  title1: "All",
                  title2: "Active",
                  title3: "Blocked",
                  selectedIndex: controller.selectedTab.value,
                  onChanged: controller.changeTab,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  switch (controller.selectedTab.value) {
                    case 1:
                      return _clubsList(statusFilter: 'active');
                    case 2:
                      return _clubsList(statusFilter: 'blocked');
                    default:
                      return _clubsList();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clubsList({String? statusFilter}) {
    return Obx(() {
      final query = controller.searchQuery.value;
      return StreamBuilder(
        stream: controller.clubsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No clubs found"));
          }

          final clubs = snapshot.data!.docs.where((doc) {
            final data = doc.data();
            final status = (data['status'] ?? 'active').toString();
            final name = (data['name'] ?? '').toString().toLowerCase();
            final matchesQuery = query.isEmpty || name.contains(query);
            if (statusFilter == null) return true;
            return status == statusFilter && matchesQuery;
          }).toList();

          if (clubs.isEmpty) {
            return const Center(child: Text("No clubs found"));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final doc = clubs[index];
              final data = doc.data();
              final name = (data['name'] ?? '').toString();
              final location = (data['location'] ?? '').toString();
              final status = (data['status'] ?? 'active').toString();
              final logoBase64 = (data['logoBase64'] ?? '').toString();
              final isActive = status == 'active';

              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: AppColors.white,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: logoBase64.isNotEmpty
                          ? MemoryImage(base64Decode(logoBase64))
                          : null,
                    ),
                    title: Text(name),
                    subtitle: Text(location),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              controller.toggleClubStatus(doc.id, status),
                          child: Container(
                            height: 10.h,
                            width: 10.h,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => GolfClubProfilePage(
                                clubId: doc.id,
                                nameOfClub: name,
                                clubLocation: location,
                              ),
                              transition: Transition.rightToLeft,
                            );
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 22,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
}
