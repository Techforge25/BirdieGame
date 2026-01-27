import 'package:bierdygame/app/modules/superAdmin/addClubs/view/add_clubs_screen.dart';
import 'package:bierdygame/app/modules/superAdmin/clubs/view/club_management_super_admin.dart';
import 'package:bierdygame/app/modules/superAdmin/dashboard/view/super_admin.dart';
import 'package:bierdygame/app/modules/superAdmin/manageAdmins/views/manage_admins.dart';
import 'package:bierdygame/app/modules/superAdmin/profile/view/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuperAdminBotNavController extends GetxController {
  var currentIndex = 0.obs;
  var bottomNavIndex = 0.obs;

  final List<Widget> screens = [
    const SuperAdminDashboard(),
    SuperAdminClubManagement(),
    AddClubsScreen(),
    ManageAdmins(),
    ProfileScreen(),
  ];
  void changeTab(int index) {
    currentIndex.value = index;
    if (index >= 0 && index < 5) {
      bottomNavIndex.value = index;
    }
  }
}
