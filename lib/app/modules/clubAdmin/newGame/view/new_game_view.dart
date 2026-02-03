import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/controller/new_game_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/view/team_setup_view.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/widgets/counter_widget.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NewGameView extends GetView<NewGameController> {
  const NewGameView({super.key});

  @override
  Widget build(BuildContext context) {
    final hasController = Get.isRegistered<NewGameController>();
    return GetBuilder<NewGameController>(
      init: hasController ? null : NewGameController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),

                        /// TITLE
                        Center(
                          child: Text(
                            "Create a Game",
                            style: AppTextStyles.miniHeadings,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        /// GAME NAME
                        CustomFormField(
                          label: "Game Name",
                          labeltextStyle: AppTextStyles.bodyMedium,
                          controller: controller.nameController,
                          hint: "Enter game name",
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.borderColorLight,
                          ),
                          bgcolor: AppColors.white,
                        ),

                        SizedBox(height: 16.h),

                        Row(
                          children: [
                            Expanded(
                              child: _pickerField(
                                label: "Date:",
                                value: controller.formattedDate,
                                icon: Icons.calendar_today_outlined,
                                onTap: () => controller.pickDate(context),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _pickerField(
                                label: "Time:",
                                value: controller.formattedTime,
                                icon: Icons.access_time,
                                onTap: () => controller.pickTime(context),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        /// COUNTER BOX
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(
                              color: AppColors.borderColorLight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              CounterSettingTile(
                                title: "Number of Teams",
                                subtitle: "Total teams playing",
                                value: controller.teams,
                                minValue: 2,
                                maxValue: 8,
                                icon: Icons.groups,
                                iconBgColor: AppColors.primary,
                                onIncrement: controller.incrementTeams,
                                onDecrement: controller.decrementTeams,
                              ),

                              SizedBox(height: 12.h),

                              CounterSettingTile(
                                title: "Players per Team",
                                subtitle: "Size of each team",
                                value: controller.playersPerTeam,
                                minValue: 2,
                                maxValue: 4,
                                icon: Icons.person,
                                iconBgColor: AppColors.darkBlue,
                                onIncrement: controller.incrementPlayersPerTeam,
                                onDecrement: controller.decrementPlayersPerTeam,
                              ),

                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        Text(
                          "Game Rules (Optional)",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderColorLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller.rulesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Write a game rules",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(14.w),
                            ),
                          ),
                        ),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  child: CustomElevatedButton(
                    btnName: controller.isEditingDraft
                        ? "Save Game"
                        : "Create Game",
                    onPressed: () {
                      if (controller.isEditingDraft) {
                        controller.saveDraftIfNeeded();
                        final nav = Get.find<ClubAdminBottomNavController>();
                        nav.changeTab(1);
                      } else {
                        Get.to(() => const TeamSetupView());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _pickerField({
  required String label,
  required String value,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 8.h),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColorLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: value.startsWith('Select')
                        ? AppColors.textSecondary
                        : AppColors.textBlack,
                  ),
                ),
              ),
              Icon(icon, color: AppColors.borderColor),
            ],
          ),
        ),
      ),
    ],
  );
}
