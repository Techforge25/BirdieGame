import 'package:get/get.dart';
import '../controller/player_dashboard_controller.dart';

class PlayerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PlayerDashboardController(),permanent: true);
  }
}
