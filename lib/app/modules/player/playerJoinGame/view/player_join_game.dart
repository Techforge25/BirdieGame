import 'package:bierdygame/app/modules/player/playerDashBoard/view/widget/continue_game_container.dart';
import 'package:bierdygame/app/modules/player/playerJoinGame/view/game_board.dart';
import 'package:bierdygame/app/modules/player/playerJoinGame/widgets/join_game_card.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:bierdygame/app/widgets/custom_modal.dart';
import 'package:bierdygame/app/widgets/status_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PlayerJoinGame extends StatelessWidget {
  const PlayerJoinGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        centerTitle: true,
        title: Text("Game", style: AppTextStyles.bodyMedium2),
      ),

      /// 🔹 BODY
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            JoinGameCard(
              onTap: () {
                Get.to(() => GameBoardView());
              },
            ),
            SizedBox(height: 10.h),
            ContinueGameContainer(),
            SizedBox(height: 20.h),
            Text("Active Games", style: AppTextStyles.subHeading),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderColorLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("GreenShot Tournament", style: AppTextStyles.bodyMedium),
                  Text(
                    'Summit Point Golf Club - Sat, July 15 @ 9 : 00 AM',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(Icons.person_2_outlined),
                      SizedBox(width: 5.w),
                      Text(
                        "12/16 Players",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.borderColor,
                        ),
                      ),
                      Spacer(),
                      StatusContainer(
                        status: "Join",
                        onTap: () {
                          Get.bottomSheet(
                            CustomModal(
                              titleStyle: AppTextStyles.bodyMedium2.copyWith(
                                fontSize: 20,
                              ),
                              title: "Join Game",
                              content: CustomFormField(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: AppColors.borderColorLight,
                                ),
                                hint: "Enter PassKey",
                              ),
                              actions: [
                                CustomElevatedButton(
                                  onPressed: () {
                                    Get.to(() => GameBoardView());
                                  },
                                  btnName: "Join Game",
                                  borderRadius: 12.r,
                                  fontSize: 20,
                                ),
                              ],
                            ),
                          );
                        },
                        color: AppColors.flashyGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
