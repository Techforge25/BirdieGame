import 'package:bierdygame/app/modules/superAdmin/addClubs/controller/add_clubs_controller.dart';
import 'package:get/get.dart';

class AddClubsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AddClubsController());
  }
}
