import 'package:bierdygame/app/modules/admins/adminController/admin_controller.dart';
import 'package:get/get.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
  }
}
