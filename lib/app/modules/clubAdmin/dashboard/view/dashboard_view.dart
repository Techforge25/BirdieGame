import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/controller/new_game_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/dashboard/widgets/club_admin_main_role_container.dart';
import 'package:bierdygame/app/modules/clubAdmin/dashboard/widgets/reports_and_analytics_dashboard.dart';
import 'package:bierdygame/app/modules/clubAdmin/dashboard/widgets/stat_card.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_profile_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ClubAdminDashboard extends StatelessWidget {
  const ClubAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15.sp),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid ?? 'missing')
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    final userData = userSnapshot.data?.data() ?? {};
                    final name = (userData['displayName'] ??
                            userData['name'] ??
                            'Club Admin')
                        .toString();
                    final photoBase64 =
                        (userData['photoBase64'] ?? '').toString();
                    return CustomProfileBar(
                      name: name,
                      onTap: () {},
                      bgImg: "assets/images/dashboard_img.png",
                      imageProvider: photoBase64.isNotEmpty
                          ? MemoryImage(base64Decode(photoBase64))
                          : null,
                    );
                  },
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildContainerClubAdmin(
                      icon: Icons.add,
                      bgColor: AppColors.primary,
                      onTap: () {
                        final nav = Get.find<ClubAdminBottomNavController>();
                        if (!nav.guardClubAccess()) return;
                        Get.find<NewGameController>().resetForm();
                        nav.changeTab(2);
                      },
                      title: "Create Game",
                    ),
                    buildContainerClubAdmin(
                      icon: CupertinoIcons.game_controller,
                      bgColor: AppColors.darkBlue,
                      onTap: () {
                        final nav = Get.find<ClubAdminBottomNavController>();
                        if (!nav.guardClubAccess()) return;
                        nav.changeTab(1);
                      },
                      title: "Manage Game",
                    ),
                    buildContainerClubAdmin(
                      icon: Icons.list,
                      bgColor: AppColors.secondary,
                      onTap: () {
                        final nav = Get.find<ClubAdminBottomNavController>();
                        if (!nav.guardClubAccess()) return;
                        nav.changeTab(3);
                      },
                      title: "LeaderBoard",
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid ?? 'missing')
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final userData = userSnapshot.data?.data() ?? {};
                    final clubId = (userData['clubId'] ?? '').toString();
                    if (clubId.isEmpty) {
                      return buildCustomGrid(
                        activeGames: 0,
                        totalTeams: 0,
                        totalPlayers: 0,
                        completedGames: 0,
                      );
                    }
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('games')
                          .where('clubId', isEqualTo: clubId)
                          .snapshots(),
                      builder: (context, gamesSnapshot) {
                        if (gamesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final games = gamesSnapshot.data?.docs ?? [];
                        int activeGames = 0;
                        int completedGames = 0;
                        int totalTeams = 0;
                        int totalPlayers = 0;

                        for (final doc in games) {
                          final data = doc.data();
                          final status =
                              (data['status'] ?? 'active').toString();
                          if (status == 'active') {
                            activeGames++;
                          }
                          if (status == 'completed') {
                            completedGames++;
                          }
                          final teams = data['teams'];
                          if (teams is List) {
                            totalTeams += teams.length;
                            for (final team in teams) {
                              if (team is Map<String, dynamic>) {
                                final members = team['members'];
                                if (members is List) {
                                  totalPlayers += members.length;
                                }
                              }
                            }
                          }
                        }

                        return buildCustomGrid(
                          activeGames: activeGames,
                          totalTeams: totalTeams,
                          totalPlayers: totalPlayers,
                          completedGames: completedGames,
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 10),
                ReportsAndAnalyticsDashboard(),
                Text(
                  "Recent Activity",
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 24),
                ),
                SizedBox(height: 12.h),
                _recentActivitySection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivitySection() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid ?? 'missing')
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final userData = userSnapshot.data?.data() ?? {};
        final clubId = (userData['clubId'] ?? '').toString();
        if (clubId.isEmpty) {
          return Text(
            "No club assigned",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.borderColor,
            ),
          );
        }
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('games')
              .where('clubId', isEqualTo: clubId)
              .orderBy('createdAt', descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, gamesSnapshot) {
            if (gamesSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (gamesSnapshot.hasError) {
              return Text(
                "Failed to load activity",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.borderColor,
                ),
              );
            }
            final games = gamesSnapshot.data?.docs ?? [];
            final activities = <_ActivityItem>[];

            for (final doc in games) {
              final data = doc.data();
              final gameName = (data['name'] ?? 'Game').toString();
              final createdAt = data['createdAt'];
              final gameDate = _toDateTime(createdAt);
              if (gameDate != null) {
                activities.add(
                  _ActivityItem(
                    title: "You created a game",
                    meta: gameName,
                    when: gameDate,
                  ),
                );
              }

              final teams = data['teams'];
              if (teams is List) {
                for (final team in teams) {
                  if (team is Map<String, dynamic>) {
                    final teamName = (team['name'] ?? 'Team').toString();
                    final teamCreated = _toDateTime(team['createdAt']);
                    if (teamCreated != null) {
                      activities.add(
                        _ActivityItem(
                          title: "You added a team",
                          meta: teamName,
                          when: teamCreated,
                        ),
                      );
                    }
                  }
                }
              }
            }

            activities.sort((a, b) => b.when.compareTo(a.when));
            final visible = activities.take(6).toList();
            if (visible.isEmpty) {
              return Text(
                "No recent activity",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.borderColor,
                ),
              );
            }
            return Column(
              children: visible.map(_activityCard).toList(),
            );
          },
        );
      },
    );
  }

  Widget _activityCard(_ActivityItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.flashyGreen,
            child: Text(
              "PG",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.bodyMedium2,
                ),
                SizedBox(height: 4.h),
                Text(
                  "${_formatActivityTime(item.when)}  •  ${item.meta}",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.borderColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.flashyGreen,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "Live",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _formatActivityTime(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(when.year, when.month, when.day);
    final time = DateFormat('hh:mm a').format(when);
    if (day == today) {
      return "Today, $time";
    }
    if (day == today.subtract(const Duration(days: 1))) {
      return "Yesterday, $time";
    }
    return DateFormat('MMM d, yyyy, hh:mm a').format(when);
  }
}

class _ActivityItem {
  final String title;
  final String meta;
  final DateTime when;

  _ActivityItem({
    required this.title,
    required this.meta,
    required this.when,
  });
}
