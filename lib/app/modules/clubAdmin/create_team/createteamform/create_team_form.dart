import 'package:bierdygame/app/modules/clubAdmin/create_team/controller/create_team_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreateTeamForm extends StatelessWidget {
  const CreateTeamForm({super.key, required this.controller});

  final CreateTeamController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          centerTitle: true,
          title: Text('Create Team', style: AppTextStyles.bodyMedium2),
          leading: IconButton(
            onPressed: controller.closeCreateForm,
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            children: [
              Text('Create Team', style: AppTextStyles.subHeading),
              SizedBox(height: 6.h),
              Text(
                'Set up a team for this game',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Team Name',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.teamNameController,
                decoration: InputDecoration(
                  hintText: 'e.g. King Golf',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderColorLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderColorLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Team Emoji (Optional)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              Obx(() {
                final selected = controller.selectedEmojiIndex.value;
                return Row(
                  children: List.generate(5, (index) {
                    final isSelected = selected == index;

                    return Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: GestureDetector(
                        onTap: () => controller.selectEmoji(index),
                        child: Container(
                          width: 52.w,
                          height: 52.w,
                          decoration: BoxDecoration(
                            color: AppColors.lightGreenColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.sports_golf,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.seaGreen,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.openRosterForm,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Create Team & Add Player',
                    style: TextStyle(color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF5B8DFF)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      color: const Color(0xFF2F5FEA),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Each team must have 4 players and 1 captain to be eligible for the game start.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF2F5FEA),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
