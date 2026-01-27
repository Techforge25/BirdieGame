import 'package:bierdygame/app/modules/player/playerJoinGame/controller/player_join_game_controller.dart';
import 'package:bierdygame/app/modules/player/playerJoinGame/widgets/game_players_grid.dart';
import 'package:bierdygame/app/modules/player/playerJoinGame/widgets/game_progress_card.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GameBoardView extends GetView<PlayerJoinGameController> {
  final VoidCallback? onBack;
    const GameBoardView({super.key,this.onBack});


  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.bar_chart, color: AppColors.primary),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
        ),
        title: Text("Game", style: AppTextStyles.bodyMedium2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            children: [
              GameProgressCard(),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Team Name",
                        style: AppTextStyles.subHeading.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Divider(),
                    Text("Birdie", style: AppTextStyles.miniHeadings),
                    Text(
                      "Tap to mark your birdie",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.borderColor,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    GamePlayersGrid(),
                    SizedBox(height: 10.h),
                    CustomElevatedButton(
                      onPressed: () {},
                      btnName: "Save Game",
                      borderRadius: 16.r,
                    ),
                    SizedBox(height: 10.h),
                    CustomElevatedButton(
                      onPressed: () {},
                      btnName: "End Game",
                      borderRadius: 16.r,
                      textColor: AppColors.darkRed,
                      backColor: AppColors.flashyRed,
                      borderColor: AppColors.darkRed,
                      borderWidth: 1.5,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
