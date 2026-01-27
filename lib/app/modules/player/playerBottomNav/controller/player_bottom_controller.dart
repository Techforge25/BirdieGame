import 'package:bierdygame/app/modules/clubAdmin/scores/view/scores_view.dart';
import 'package:bierdygame/app/modules/player/playerDashBoard/view/player_dashboard_view.dart';
import 'package:bierdygame/app/modules/player/playerJoinGame/view/player_join_game.dart';
import 'package:bierdygame/app/modules/player/playerProfile/view/player_profile.dart';
import 'package:bierdygame/app/modules/player/playerStats/view/player_stats_view.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerBottomController extends GetxController {
  var currentIndex = 0.obs;
  var bottomNavIndex = 0.obs;

  final List<Widget> screens = [
    PlayerDashboardView(),
    ScoresView(),
    PlayerJoinGame(),
    PlayerStatsView(
      onBack: () => Get.find<PlayerBottomController>().changeTab(0),
      color: AppColors.white,
    ),
    PlayerProfile(),
  ];

  void changeTab(int index) {
    if (index >= 0 && index < screens.length) {
      currentIndex.value = index;
      bottomNavIndex.value = index;
    }
  }
}
