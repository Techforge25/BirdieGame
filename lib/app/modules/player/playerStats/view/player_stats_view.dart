import 'package:bierdygame/app/modules/clubAdmin/clubProfile/view/club_profile_view.dart';
import 'package:bierdygame/app/modules/player/playerStats/controller/player_stats_controller.dart';
import 'package:bierdygame/app/modules/player/playerStats/widgets/performance_overview_container.dart';
import 'package:bierdygame/app/modules/player/playerStats/widgets/teams_play_with_container.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_club_detail_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class PlayerStatsView extends GetView<PlayerStatsController> {
  final VoidCallback onBack;
  final Color? color;
  final Map<String, dynamic>? playerData;

  const PlayerStatsView({
    super.key,
    required this.onBack,
    required this.color,
    this.playerData,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(onPressed: onBack, icon: Icon(Icons.arrow_back_ios)),
          title: Text(
            "Stats",
            style: AppTextStyles.bodyMedium2.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                          "assets/images/dashboard_img.png",
                        ),
                      ),
                      Text(
                        (playerData?['name'] ?? "Player Name").toString(),
                        style: AppTextStyles.bodyLarge.copyWith(fontSize: 18),
                      ),
                      if ((playerData?['email'] ?? '').toString().isNotEmpty)
                        Text(
                          (playerData?['email'] ?? '').toString(),
                          style: AppTextStyles.bodySmall,
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xffCFE8DC),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          "Active button",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Stats Overview",
                    style: AppTextStyles.bodyMedium2,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xffCFE8DC), Color(0xffDCEDC8)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Team Birdies",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkGreen,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "315",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.darkGreen,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "All Time",
                            style: AppTextStyles.bodyMedium2.copyWith(
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                ClubsDetailGrid(
                  value1: 0.toString(),
                  value2: 1.toString(),
                  value3: 2.toString(),
                  value4: 9.toString(),
                  color: AppColors.darkGreen,
                  icon1: Icons.sports_golf_outlined,
                  icon2: Icons.trending_up_outlined,
                  icon3: FontAwesomeIcons.trophy,
                  icon4: Icons.star_border_outlined,
                  title1: "Total Games",
                  title2: "Avg Birdies",
                  title3: "Total Wins",
                  title4: "Highest Birdie",
                  textColor: AppColors.textBlack,
                ),
                SizedBox(height: 8.h),
                PerformanceOverviewContainer(),
                SizedBox(height: 8.h),
                ListTile(
                  trailing: IconButton(
                    onPressed: () {
                      Get.to(
                        () => TeamProfileView(
                          onBack: () {
                            Get.back();
                          },
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
                    ),
                  ),
                  tileColor: AppColors.white,
                  leading: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.sports_golf, color: AppColors.white),
                  ),
                  title: Text("Team Eagle", style: AppTextStyles.bodyMedium2),
                  subtitle: Text(
                    "member since 2023",
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Icon(Icons.star, color: AppColors.white, size: 12),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "Highlights",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.borderColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.flashyGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: AppColors.primary),
                          SizedBox(width: 8.w),
                          Text(
                            "Best : 9 Birdies",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.flashyGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "Best : 9 Birdies",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h,),
                Text(
                  "Team Play With",
                  style: AppTextStyles.bodyMedium2.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
                SizedBox(height: 15.h,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                       TeamsPlayWithContainer(
                            iconBgColor: AppColors.flashyPurple,
                            icon: Icon(Icons.golf_course,color: AppColors.darkPurple,),
                            teamName: "The Eagles",
                            gamesPerTeam: "6 Games",
                          ),
                          SizedBox(width: 10.w),
                           TeamsPlayWithContainer(
                            iconBgColor: AppColors.flashyYellow,
                            icon: Icon(Icons.golf_course,color: AppColors.secondary,),
                            teamName: "The Tigers",
                            gamesPerTeam: "6 Games",
                          ),
                          SizedBox(width: 10.w),
                           TeamsPlayWithContainer(
                            iconBgColor: AppColors.textBlack,
                            icon: Icon(Icons.golf_course,color: AppColors.borderColorLight,),
                            teamName: "The Crows",
                            gamesPerTeam: "4 Games",
                          ),
                          SizedBox(width: 10.w),
                          TeamsPlayWithContainer(
                            iconBgColor: AppColors.flashyGreen,
                            icon: Icon(Icons.golf_course,color: AppColors.primary,),
                            teamName: "The Frogs",
                            gamesPerTeam: "6 Games",
                          ),
                    ],
                  ),
                ),
             
              ],
            ),
          ),
        ),
      ),
    );
  }
}
