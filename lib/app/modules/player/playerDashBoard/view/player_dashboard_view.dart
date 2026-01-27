import 'package:bierdygame/app/modules/player/playerBottomNav/controller/player_bottom_controller.dart';
import 'package:bierdygame/app/modules/player/playerDashBoard/view/widget/carousel_custom.dart';
import 'package:bierdygame/app/modules/player/playerDashBoard/view/widget/continue_game_container.dart';
import 'package:bierdygame/app/modules/player/playerDashBoard/view/widget/custom_grid_container.dart';
import 'package:bierdygame/app/modules/player/playerJoinGame/view/game_board.dart';
import 'package:bierdygame/app/modules/player/playerJoinGame/widgets/join_game_card.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/player_dashboard_controller.dart';

class PlayerDashboardView extends GetView<PlayerDashboardController> {
  const PlayerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    String username = "Alex";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage("assets/images/dashboard_img.png"),
              ),
              const SizedBox(width: 12),
              Text("Welcome, $username", style: AppTextStyles.bodyMedium2),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),

      /// 🔹 BODY
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 12),

            /// 🔹 Carousel Slider
            SizedBox(
              height: 250.h,
              child: Stack(
                children: [
                  /// 🔹 Carousel (slides)
                  CarouselSlider.builder(
                    itemCount: controller.sliders.length,
                    itemBuilder: (context, index, realIndex) {
                      return CarouselCard(
                        image: controller.sliders[index].image,
                        title: controller.sliders[index].title,
                        subTitle: controller.sliders[index].subtitle,
                      );
                    },
                    options: CarouselOptions(
                      height: 250.h,
                      viewportFraction: 1,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        controller.currentIndex.value = index;
                      },
                    ),
                  ),

                  /// 🔹 STATIC DOTS (overlay)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.sliders.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: controller.currentIndex.value == index
                                ? 10
                                : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: controller.currentIndex.value == index
                                  ? const Color.fromARGB(255, 21, 194, 99)
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ContinueGameContainer(),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: GridStatsCard(
                    title: "Join Game",
                    subTitle: "Enter a passcode to join an active match.",
                    icon: Icons.sports_golf_outlined,
                    iconBgColor: AppColors.darkGreen,
                    color1: Color(0xffF1F8E9),
                    color2: Color(0xffDCEDC8),
                    onTap: () {
                      Get.find<PlayerBottomController>().changeTab(2);
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: GridStatsCard(
                    title: "My Stats",
                    subTitle: "Track your games and birdies.",
                    icon: Icons.bar_chart_outlined,
                    iconBgColor: Color(0xff1A4FA3),
                    color1: Color(0xffE3F2FD),
                    color2: Color(0xffBBDEFB),
                    onTap: () {
                      Get.find<PlayerBottomController>().changeTab(3);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            JoinGameCard(
              onTap: () {
                Get.to(() => GameBoardView());
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
