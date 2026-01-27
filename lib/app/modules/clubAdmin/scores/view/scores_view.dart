import 'package:bierdygame/app/modules/clubAdmin/clubProfile/view/club_profile_view.dart';
import 'package:bierdygame/app/modules/clubAdmin/scores/controller/scores_controller.dart';
import 'package:bierdygame/app/modules/player/playerStats/view/player_stats_view.dart';
import 'package:bierdygame/app/modules/superAdmin/notifications/widgets/notification_tab_bar.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ScoresView extends GetView<ScoresController> {
  ScoresView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.showGameDetail.value) {
        return TeamProfileView(
          onBack: controller.backToGames,
          teamData: controller.selectedTeam.value,
        );
      }
      if (controller.showPlayerRank.value) {
        return PlayerStatsView(
          onBack: controller.backToGames,
          color: AppColors.primary,
          playerData: controller.selectedPlayer.value,
        );
      }
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Leaderboard",
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 18),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    _rankTab(
                      title: "Teams Rank",
                      index: 0,
                      selectedIndex: controller.selectedTab.value,
                      onChanged: controller.changeTab,
                    ),
                    _rankTab(
                      title: "Players Rank",
                      index: 1,
                      selectedIndex: controller.selectedTab.value,
                      onChanged: controller.changeTab,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
                      return Center(child: Text("No club assigned"));
                    }
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('games')
                          .where('clubId', isEqualTo: clubId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Failed to load games"));
                        }
                        final games = snapshot.data?.docs ?? [];
                        if (games.isEmpty) {
                          return Center(child: Text("No games found"));
                        }

                        if (controller.selectedTab.value == 0) {
                          final teams = <Map<String, dynamic>>[];
                          for (final doc in games) {
                            final data = doc.data();
                          final gameName =
                              (data['name'] ?? 'Game').toString();
                          final status =
                              (data['status'] ?? 'active').toString();
                          final date = (data['date'] ?? '').toString();
                          final rawTeams = data['teams'];
                          if (rawTeams is List) {
                            for (final team in rawTeams) {
                              if (team is Map<String, dynamic>) {
                                teams.add({
                                  ...team,
                                  'gameName': gameName,
                                  'gameStatus': status,
                                  'gameDate': date,
                                  'gameId': doc.id,
                                });
                              }
                            }
                          }
                        }
                        teams.sort((a, b) {
                          final aBirdies =
                              (a['teamBirdies'] ?? 0) as num? ?? 0;
                          final bBirdies =
                              (b['teamBirdies'] ?? 0) as num? ?? 0;
                          return bBirdies.compareTo(aBirdies);
                        });
                        if (teams.isEmpty) {
                          return Center(child: Text("No teams found"));
                        }
                        return ListView.separated(
                          padding: EdgeInsets.only(top: 10.h),
                          itemCount: teams.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final team = teams[index];
                            final name =
                                (team['name'] ?? 'Team').toString();
                            final status =
                                (team['gameStatus'] ?? 'active').toString();
                            final wins = (team['totalWins'] ?? 0).toString();
                            return GestureDetector(
                              onTap: () {
                                controller.openTeamRank(
                                  name: (team['gameName'] ?? '').toString(),
                                  status: status,
                                  date: (team['gameDate'] ?? '').toString(),
                                  teamData: team,
                                );
                              },
                              child: _rankCard(
                                rank: index + 1,
                                title: name,
                                subtitle: null,
                                trailingValue: wins,
                                trailingLabel: "Wins",
                                rankType: _RankType.team,
                              ),
                            );
                          },
                        );
                      }

                      final players = <Map<String, dynamic>>[];
                      for (final doc in games) {
                        final data = doc.data();
                        final gameName = (data['name'] ?? 'Game').toString();
                        final status = (data['status'] ?? 'active').toString();
                        final date = (data['date'] ?? '').toString();
                        final rawTeams = data['teams'];
                        if (rawTeams is List) {
                          for (final team in rawTeams) {
                            if (team is Map<String, dynamic>) {
                              final members = team['members'];
                              if (members is List) {
                                for (final member in members) {
                                  if (member is Map<String, dynamic>) {
                                    players.add({
                                      ...member,
                                      'teamName':
                                          (team['name'] ?? 'Team').toString(),
                                      'gameName': gameName,
                                      'gameStatus': status,
                                      'gameDate': date,
                                      'gameId': doc.id,
                                    });
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                        if (players.isEmpty) {
                          return Center(child: Text("No players found"));
                        }
                      return ListView.separated(
                        padding: EdgeInsets.only(top: 10.h),
                        itemCount: players.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final name =
                              (player['name'] ?? 'Player').toString();
                          final teamName =
                              (player['teamName'] ?? '').toString();
                          final birdies =
                              (player['birdies'] ?? 0).toString();
                          return GestureDetector(
                            onTap: () {
                              controller.openPlayerRank(
                                name: (player['gameName'] ?? '').toString(),
                                status:
                                    (player['gameStatus'] ?? '').toString(),
                                date: (player['gameDate'] ?? '').toString(),
                                playerData: player,
                              );
                            },
                            child: _rankCard(
                              rank: index + 1,
                              title: name,
                              subtitle: teamName.isEmpty ? null : teamName,
                              trailingValue: birdies,
                              trailingLabel: "B",
                              rankType: _RankType.player,
                            ),
                          );
                        },
                      );
                    },
                  );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

enum _RankType { team, player }

Widget _rankTab({
  required String title,
  required int index,
  required int selectedIndex,
  required ValueChanged<int> onChanged,
}) {
  final isSelected = index == selectedIndex;
  return Expanded(
    child: GestureDetector(
      onTap: () => onChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _rankCard({
  required int rank,
  required String title,
  required String? subtitle,
  required String trailingValue,
  required String trailingLabel,
  required _RankType rankType,
}) {
  final color = rank == 1
      ? AppColors.flashyGreen
      : (rank == 2 ? AppColors.flashyYellow : AppColors.flashyblue);
  final border = rank == 1
      ? AppColors.primary
      : (rank == 2 ? AppColors.secondary : AppColors.darkBlue);
  return Container(
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: rank <= 3 ? color : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: rank <= 3 ? border : Colors.grey.shade300),
    ),
    child: Row(
      children: [
        Text(
          rank.toString(),
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium2),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.borderColor,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              trailingValue,
              style: AppTextStyles.bodyMedium2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              trailingLabel,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.borderColor,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
