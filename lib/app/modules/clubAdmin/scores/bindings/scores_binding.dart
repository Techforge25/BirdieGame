import 'package:bierdygame/app/modules/clubAdmin/scores/controller/scores_controller.dart';
import 'package:get/get.dart';

class ScoresBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScoresController>(() => ScoresController());
  }
}
