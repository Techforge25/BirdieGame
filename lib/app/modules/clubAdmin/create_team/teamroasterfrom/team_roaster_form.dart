import 'package:bierdygame/app/modules/clubAdmin/create_team/controller/create_team_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';

class TeamRoasterForm extends StatelessWidget {
  const TeamRoasterForm({
    super.key,
    required this.controller,
    this.onClose,
    this.onSaved,
  });

  final CreateTeamController controller;
  final VoidCallback? onClose;
  final VoidCallback? onSaved;

  Future<void> _showAddPlayersDialog(
    BuildContext context, {
    int slots = 4,
  }) async {
    final controllers = List.generate(slots, (_) => TextEditingController());
    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add Players',
                        style: AppTextStyles.bodyMedium2,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      icon: Icon(Icons.close, color: AppColors.borderColor),
                    ),
                  ],
                ),
                Divider(color: AppColors.borderColorLight),
                SizedBox(height: 6.h),
                ...List.generate(slots, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email (Player ${index + 1})',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: controllers[index],
                          decoration: InputDecoration(
                            hintText: 'Enter Email Address',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 14.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.borderColorLight,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.borderColorLight,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 6.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final emails = controllers
                          .map((c) => c.text.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      Navigator.of(dialogContext).pop(emails);
                    },
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
                    child: Text(
                      'Send Invite & Add Player',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!context.mounted) {
      return;
    }
    if (result != null && result.isNotEmpty) {
      await controller.addRosterPlayersFromDialog(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    const limit = 4;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.white,
            elevation: 0,
            centerTitle: true,
            title: Text('Profile Edit', style: AppTextStyles.bodyMedium2),
            leading: IconButton(
              onPressed: onClose ?? controller.closeRosterForm,
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
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderColorLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textBlack.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Obx(() {
                            final path = controller.teamLogoPath.value;
                            final base64Logo = controller.teamLogoBase64.value;
                            if (path != null &&
                                path.isNotEmpty &&
                                File(path).existsSync()) {
                              return Container(
                                width: 52.w,
                                height: 52.w,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreenColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                            if (base64Logo != null && base64Logo.isNotEmpty) {
                              return Container(
                                width: 52.w,
                                height: 52.w,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreenColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    base64Decode(base64Logo),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                            return Container(
                              width: 52.w,
                              height: 52.w,
                              decoration: BoxDecoration(
                                color: AppColors.lightGreenColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.sports_golf,
                                color: AppColors.primary,
                              ),
                            );
                          }),
                          Positioned(
                            right: -6,
                            bottom: -6,
                            child: GestureDetector(
                              onTap: controller.pickTeamLogo,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.borderColorLight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: controller.rosterTeamNameController,
                              style: AppTextStyles.bodyMedium2,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Team Name',
                                hintStyle: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Container(
                                  width: 10.w,
                                  height: 10.w,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '#1255838',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Player Roster',
                        style: AppTextStyles.subHeading,
                      ),
                    ),
                    Obx(() {
                      final remaining = limit - controller.rosterPlayers.length;
                      if (remaining <= 0) {
                        return const SizedBox.shrink();
                      }
                      return ElevatedButton.icon(
                        onPressed: () =>
                            _showAddPlayersDialog(context, slots: remaining),
                        icon: Icon(Icons.add, color: AppColors.white, size: 18),
                        label: Text(
                          'Add Players',
                          style: TextStyle(color: AppColors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                SizedBox(height: 14.h),
                Obx(() {
                  if (!controller.rosterReady.value) {
                    return Container(
                      width: double.infinity,
                      height: 160.h,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'No players added yet',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  final roster = controller.rosterPlayers;
                  return Column(
                    children: [
                      ...List.generate(roster.length, (index) {
                        final player = roster[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
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
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.flashyblue,
                                child: Text(
                                  player.initials,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    Text(
                                      player.email,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDFF7E8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Joined',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              IconButton(
                                onPressed: () => controller
                                    .removeRosterPlayerFromTeam(index),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.borderColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 6),
                      SizedBox(height: 10.h),
                      Text(
                        'Assign Team Captain',
                        style: AppTextStyles.subHeading,
                      ),
                      SizedBox(height: 12.h),
                      ...List.generate(roster.length, (index) {
                        return Row(
                          children: [
                            Obx(() {
                              return Radio<int>(
                                value: index,
                                groupValue:
                                    controller.selectedCaptainIndex.value,
                                activeColor: AppColors.primary,
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.selectCaptain(value);
                                  }
                                },
                              );
                            }),
                            Text(
                              roster[index].name,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await controller.saveTeamSetup();
                  onSaved?.call();
                },
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
                child: Text(
                  'Save Team Setup',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
