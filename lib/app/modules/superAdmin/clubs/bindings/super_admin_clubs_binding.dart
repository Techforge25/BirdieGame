import 'package:bierdygame/app/modules/superAdmin/clubs/controller/super_admin_clubs_controller.dart';
import 'package:get/get.dart';

class SuperAdminClubManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SuperAdminClubManagementController());
  }
}