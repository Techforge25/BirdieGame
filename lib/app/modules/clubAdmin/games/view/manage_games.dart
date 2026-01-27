import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/games/view/game_detail_view.dart';
import 'package:bierdygame/app/modules/clubAdmin/games/widgets/custom_tabbar.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/controller/new_game_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ManageClubsGames extends GetView<ManageClubsController> {
  ManageClubsGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.showGameDetail.value &&
          controller.selectedGame.value != null) {
        return GameDetailView(
          game: controller.selectedGame.value!,
          onBack: controller.backToGames,
        );
      }

      // =============================
      // NORMAL MANAGE GAMES SCREEN
      // =============================
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 55),
        child: Column(
          children: [
            Text("Manage Games", style: AppTextStyles.miniHeadings),

            SizedBox(height: 10.h),

            CustomTextField(
              hintText: "Search games by name",
              controller: controller.searchController,
              prefixIcon: const Icon(Icons.search),
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),

            SizedBox(height: 10.h),

            CustomElevatedButton(
              btnName: "Create Game",
              onPressed: () {
                final nav = Get.find<ClubAdminBottomNavController>();
                if (!nav.guardClubAccess()) return;
                _ensureNewGameController().resetForm();
                nav.changeTab(2);
              },
            ),
            SizedBox(height: 10.h),

            // TABBAR
            Obx(
              () => CustomTabbar(
                title1: "All",
                title2: "Active",
                title3: "Draft",
                title4: "Completed",
                selectedIndex: controller.selectedTab.value,
                onChanged: controller.changeTab,
              ),
            ),

            // LIST OF GAMES
            Expanded(
              child: Obx(() {
                final games = controller.filteredGames;
                if (games.isEmpty) {
                  return const Center(child: Text("No Games Found"));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    return _gameCard(games[index]);
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  /// ====================================
  /// SINGLE GAME CARD
  /// ====================================
  Widget _gameCard(GameModel game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                game.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              _statusChip(game.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(game.date, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 10),

          // PASSKEY
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.key_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                const Text("Passkey: "),
                Text(
                  game.passkey,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),

          // ACTIONS: VIEW / REMOVE
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    final nav = Get.find<ClubAdminBottomNavController>();
                    if (!nav.guardClubAccess()) return;
                    controller.openGame(game);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility,
                          color: AppColors.borderColor, size: 18),
                      SizedBox(width: 4.w),
                      Text(
                        "View",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: AppColors.borderColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 15.h,
                width: 2.w,
                color: AppColors.borderColor,
              ),
              if (game.status == GameStatus.draft) ...[
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final nav = Get.find<ClubAdminBottomNavController>();
                    if (!nav.guardClubAccess()) return;
                    await _ensureNewGameController().loadDraftById(game.id);
                    nav.changeTab(2);
                  },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined,
                            color: AppColors.borderColor, size: 18),
                        SizedBox(width: 4.w),
                        Text(
                          "Edit",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            color: AppColors.borderColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 15.h,
                  width: 2.w,
                  color: AppColors.borderColor,
                ),
              ],
              Expanded(
                child: InkWell(
                  onTap: () {
                    final nav = Get.find<ClubAdminBottomNavController>();
                    if (!nav.guardClubAccess()) return;
                    _showRemoveDialog(game);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_outlined,
                          color: AppColors.darkRed, size: 18),
                      SizedBox(width: 4.w),
                      Text(
                        "Remove",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkRed,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  NewGameController _ensureNewGameController() {
    if (Get.isRegistered<NewGameController>()) {
      return Get.find<NewGameController>();
    }
    return Get.put(NewGameController());
  }

  void _showRemoveDialog(GameModel game) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: AppColors.flashyRed,
            border: Border.all(color: AppColors.darkRed),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.flashyRed,
                      radius: 40.r,
                      child: Icon(
                        Icons.delete_outline,
                        color: AppColors.darkRed,
                        size: 40,
                      ),
                    ),
                    Text(
                      "Remove Game?",
                      style: AppTextStyles.bodyMedium2.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      game.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                onPressed: () async {
                  Get.back();
                  await controller.removeGame(game);
                },
                btnName: "Remove",
                backColor: AppColors.darkRed,
                textColor: AppColors.white,
                borderRadius: 15.r,
              ),
              SizedBox(height: 10.h),
              CustomElevatedButton(
                onPressed: () {
                  Get.back();
                },
                btnName: "Cancel",
                backColor: AppColors.flashyRed,
                textColor: AppColors.darkRed,
                borderColor: AppColors.darkRed,
                borderRadius: 15.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ====================================
  /// STATUS CHIP
  /// ====================================
  Widget _statusChip(GameStatus status) {
    switch (status) {
      case GameStatus.active:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.flashyGreen,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            "Live",
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case GameStatus.draft:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.flashyYellow,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Text(
            "Draft",
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case GameStatus.completed:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.borderColorLight,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.borderColorLight),
          ),
          child: Text(
            "Completed",
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }
}
