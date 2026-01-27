import 'package:bierdygame/app/modules/golfClub/controller/golf_club_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/addClubs/controller/add_clubs_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/clubs/controller/super_admin_clubs_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/manageAdmins/controller/manage_admin_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/notifications/controller/notification_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/profile/controller/edit_profiile_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/profile/controller/super_admin_profile_controller.dart';
import 'package:get/get.dart';
import '../controller/super_admin_bot_nav_controller.dart';

class SuperAdminBottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SuperAdminBotNavController(), permanent: true);
    Get.lazyPut<ManageAdminsController>(() => ManageAdminsController());
    Get.lazyPut<SuperAdminClubManagementController>(
      () => SuperAdminClubManagementController(),
    );
    Get.lazyPut<SuperAdminProfileController>(
      () => SuperAdminProfileController(),
    );
    Get.lazyPut<AddClubsController>(() => AddClubsController());
    Get.lazyPut<EditProfileController>(() => EditProfileController());
    Get.lazyPut<NotificationController>(() => NotificationController());
    Get.lazyPut<GolfClubController>(() => GolfClubController());
  }
}
