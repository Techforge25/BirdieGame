import 'package:bierdygame/app/modules/clubAdmin/scores/controller/scores_controller.dart';
import 'package:bierdygame/app/modules/player/playerBottomNav/controller/player_bottom_controller.dart';
import 'package:bierdygame/app/modules/player/playerDashBoard/controller/player_dashboard_controller.dart';
import 'package:bierdygame/app/modules/player/playerProfile/controller/player_profile_controller.dart';
import 'package:bierdygame/app/modules/player/playerStats/controller/player_stats_controller.dart';
import 'package:get/get.dart';

class PlayerBottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PlayerBottomController(), permanent: true);
    Get.lazyPut<ScoresController>(() => ScoresController()); 
    Get.lazyPut<PlayerDashboardController>(() => PlayerDashboardController());
    Get.lazyPut<PlayerProfileController>(() => PlayerProfileController());
    Get.lazyPut<PlayerStatsController>(() => PlayerStatsController());
  }
}
