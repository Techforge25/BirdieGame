import 'package:bierdygame/app/modules/player/playerJoinGame/view/game_board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerJoinGameController extends GetxController {
  var currentIndex = 0.obs;

  final List<Widget> screens = [
    GameBoardView(),
  ];

  void changeTab(int index) {
    if (index >= 0 && index < screens.length) {
      currentIndex.value = index;
    }
  }
}
