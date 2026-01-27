import 'package:bierdygame/app/modules/superAdmin/profile/controller/edit_profiile_controller.dart';
import 'package:get/get.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
