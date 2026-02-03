import 'package:bierdygame/app/modules/clubAdmin/create_team/controller/create_team_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/create_team/createteamform/create_team_form.dart';
import 'package:bierdygame/app/modules/clubAdmin/create_team/teamroasterfrom/team_roaster_form.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert';

class CreateTeamView extends GetView<CreateTeamController> {
  const CreateTeamView({super.key});

  Future<String?> _loadClubId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return userDoc.data()?['clubId']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Obx(() {
          if (controller.showRosterForm.value) {
            return TeamRoasterForm(controller: controller);
          }
          if (controller.showCreateForm.value) {
            return CreateTeamForm(controller: controller);
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Team Creation',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium2,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                SizedBox(height: 10.h),
                Text('Teams Overview', style: AppTextStyles.subHeading),
                SizedBox(height: 6.h),
                Text(
                  'Manage up to 8 teams for the tournament',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.openCreateForm,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Create Team',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                FutureBuilder<String?>(
                  future: _loadClubId(),
                  builder: (context, snapshot) {
                    final clubId = snapshot.data;
                    if (clubId == null || clubId.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('teams')
                          .where('clubId', isEqualTo: clubId)
                          .snapshots(),
                      builder: (context, teamSnap) {
                        if (teamSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (!teamSnap.hasData || teamSnap.data!.docs.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Text(
                              'No teams found',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        final docs = teamSnap.data!.docs;
                        return Column(
                          children: [
                            ...docs.map((doc) {
                              final data = doc.data();
                              final name = (data['name'] ?? 'Team').toString();
                              final members = data['members'];
                              final memberList = members is List
                                  ? members
                                  : const [];
                              final count = memberList.length;
                              final teamId = doc.id;
                              return Container(
                                margin: EdgeInsets.only(bottom: 10.h),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.borderColorLight,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        _teamLogoAvatar(
                                          base64Logo: (data['logoBase64'] ??
                                                  data['logo'] ??
                                                  '')
                                              .toString(),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style:
                                                    AppTextStyles.bodyMedium2,
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                '$count/4 Players',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            controller.prepareEditTeamFromFirestore(
                                              teamId: teamId,
                                              data: data,
                                            );
                                            await showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (sheetContext) {
                                                final height = MediaQuery.of(
                                                      sheetContext,
                                                    ).size.height -
                                                    kBottomNavigationBarHeight;
                                                return SizedBox(
                                                  height: height,
                                                  child: TeamRoasterForm(
                                                    controller: controller,
                                                    onClose: () =>
                                                        Navigator.of(
                                                          sheetContext,
                                                        ).pop(),
                                                    onSaved: () =>
                                                        Navigator.of(
                                                          sheetContext,
                                                        ).pop(),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            color: AppColors.borderColor,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Divider(
                                      color: AppColors.borderColorLight,
                                      height: 1,
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: List.generate(
                                        memberList.length.clamp(0, 6),
                                        (index) {
                                          final member = memberList[index];
                                          if (member is! Map<String, dynamic>) {
                                            return const SizedBox.shrink();
                                          }
                                          final memberName =
                                              (member['name'] ?? '').toString();
                                          final email = (member['email'] ?? '')
                                              .toString();
                                          final display = memberName.isEmpty
                                              ? email
                                              : memberName;
                                          final initial = display.isNotEmpty
                                              ? display[0].toUpperCase()
                                              : '?';
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: 6.w,
                                            ),
                                            child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor:
                                                  AppColors.flashyblue,
                                              child: Text(
                                                initial,
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 10.sp,
                                                    ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _teamCard(TeamPreview team, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColorLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.emoji_events, color: Colors.white),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name, style: AppTextStyles.bodyMedium2),
                    SizedBox(height: 2.h),
                    Text(
                      '${team.playersCount}/${team.maxPlayers} Players',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => controller.openEditTeam(index),
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppColors.borderColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.deleteTeam(index),
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.borderColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(color: AppColors.borderColorLight, height: 24.h),
          Row(
            children: team.playerInitials
                .map(
                  (initial) => Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.seaGreen,
                      child: Text(
                        initial,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _teamLogoAvatar({required String base64Logo}) {
    if (base64Logo.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.lightGreenColor,
        backgroundImage: MemoryImage(base64Decode(base64Logo)),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.emoji_events,
        color: Colors.white,
      ),
    );
  }
}
