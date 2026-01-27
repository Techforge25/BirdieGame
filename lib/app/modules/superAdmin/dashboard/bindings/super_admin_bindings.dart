import 'package:bierdygame/app/modules/superAdmin/clubs/bindings/super_admin_clubs_binding.dart';
import 'package:bierdygame/app/modules/superAdmin/dashboard/controller/super_admin_controller.dart';
import 'package:get/get.dart';

class SuperAdminBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperAdminController>(() => SuperAdminController());
    SuperAdminClubManagementBinding().dependencies();

  }
}