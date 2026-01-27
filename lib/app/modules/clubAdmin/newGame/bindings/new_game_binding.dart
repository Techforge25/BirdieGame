import 'package:bierdygame/app/modules/clubAdmin/newGame/controller/new_game_controller.dart';
import 'package:get/get.dart';

class NewGameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewGameController>(() => NewGameController());
  }
}
