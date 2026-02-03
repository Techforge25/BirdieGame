import 'package:bierdygame/app/modules/clubAdmin/create_team/controller/create_team_controller.dart';
import 'package:get/get.dart';

class CreateTeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateTeamController>(() => CreateTeamController(), fenix: true);
  }
}
