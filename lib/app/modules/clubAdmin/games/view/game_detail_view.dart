import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class GameDetailView extends GetView<ManageClubsController> {
  final GameModel game;
  final VoidCallback onBack;

  GameDetailView({super.key, required this.game, required this.onBack});

  bool showTeams = true;
  // Toggle Teams / Leaderboard
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('games')
              .doc(game.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data?.data() ?? {};
            final gameName = (data['name'] ?? game.name).toString();
            final statusStr = (data['status'] ?? game.status.name).toString();
            final status = GameStatus.values.firstWhere(
              (s) => s.name == statusStr,
              orElse: () => game.status,
            );
            final totalHoles =
                (data['totalHoles'] ?? game.totalHoles) as int? ?? 18;
            final currentHole =
                (data['currentHole'] ?? game.currentHole) as int? ?? 1;
            final par = (data['par'] ?? game.par) as int? ?? 3;
            final teams = _asTeams(data['teams']);
            final totalTeams = teams.length;
            final totalPlayers = teams.fold<int>(
              0,
              (sum, t) => sum + (t.members?.length ?? 0),
            );
            final totalTeamBirdies = teams.fold<int>(
              0,
              (sum, t) => sum + (t.birdies ?? 0),
            );
            final matchProgress = totalHoles == 0
                ? 0.0
                : (totalTeamBirdies / totalHoles).clamp(0.0, 1.0);
            final teamRank = [...teams]
              ..sort((a, b) => (b.birdies ?? 0).compareTo(a.birdies ?? 0));
            final playerRank = _buildPlayerRank(teams);

            return Obx(() {
              if (controller.gameDetailPage.value == 1) {
                return _teamDetailView(
                  team: controller.selectedTeamDetail.value,
                  totalHoles: totalHoles,
                  onBack: controller.backToGameDetail,
                  onPlayerTap: (player) {
                    controller.openPlayerDetail(player);
                  },
                );
              }
              if (controller.gameDetailPage.value == 2) {
                return _playerDetailView(
                  player: controller.selectedPlayerDetail.value,
                  totalHoles: totalHoles,
                  onBack: controller.backToTeamDetail,
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                  /// ===================
                  /// TOP GREEN HEADER
                  /// ===================
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: onBack,
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          gameName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Hole $currentHole of $totalHoles • Par $par",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statusChip(status),
                            Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "02:14:30",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// ===================
                  /// END GAME BUTTON
                  /// ===================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.darkRed),
                          backgroundColor: AppColors.flashyRed,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.exit_to_app,
                                color: Colors.red, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              "End Game",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// ===================
                  /// TEAMS / LEADERBOARD TOGGLE
                  /// ===================
                  Obx(() {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          _primaryTab(
                            title: "Teams",
                            index: 0,
                            selectedIndex: controller.selectedGameTab.value,
                            onChanged: controller.changeGameTab,
                          ),
                          _primaryTab(
                            title: "Leaderboard",
                            index: 1,
                            selectedIndex: controller.selectedGameTab.value,
                            onChanged: controller.changeGameTab,
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 16.h),

                  Obx(() {
                    if (controller.selectedGameTab.value == 0) {
                      return ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statCard("Teams", totalTeams.toString()),
                                _statCard("Players", totalPlayers.toString()),
                                _statCard(
                                  "Team Birdied",
                                  "$totalTeamBirdies / $totalHoles",
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

                          /// MATCH PROGRESS
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.h),
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Match Progress",
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      SizedBox(height: 15.h),
                                      LinearProgressIndicator(
                                        value: matchProgress,
                                        backgroundColor: Colors.green.shade100,
                                        color: Colors.green,
                                        minHeight: 8.h,
                                      ),
                                      SizedBox(height: 6.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Teams are working to birdie all $totalHoles holes.",
                                              style: TextStyle(
                                                color: AppColors.textBlack,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "${(matchProgress * 100).round()}%",
                                            style: TextStyle(
                                              color: AppColors.textBlack,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

                          /// TEAM PROGRESS LIST
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              children: teamRank.asMap().entries.map((entry) {
                                return _teamProgressCard(
                                  entry.value,
                                  totalHoles,
                                  onTap: () {
                                    controller.openTeamDetail(
                                      entry.value.toMap(rank: entry.key + 1),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }
                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                          Row(
                            children: [
                              _secondaryTab(
                                title: "Team Rank",
                                index: 0,
                                onChanged: controller.changeLeaderboardTab,
                                selectedIndex:
                                    controller.selectedLeaderboardTab.value,
                              ),
                              SizedBox(width: 20.w),
                              _secondaryTab(
                                title: "Players Rank",
                                index: 1,
                                onChanged: controller.changeLeaderboardTab,
                                selectedIndex:
                                    controller.selectedLeaderboardTab.value,
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Obx(() {
                            if (controller.selectedLeaderboardTab.value == 0) {
                              return Column(
                                children: teamRank.asMap().entries.map((entry) {
                                  return _teamRankCard(
                                    rank: entry.key + 1,
                                    team: entry.value,
                                  );
                                }).toList(),
                              );
                            }
                            return Column(
                              children: playerRank.asMap().entries.map((entry) {
                                return _playerRankCard(
                                  rank: entry.key + 1,
                                  player: entry.value,
                                );
                              }).toList(),
                            );
                          }),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 50.h),
                ],
              ),
            );
            });
          },
        ),
      ),
    );
  }

  /// =====================================
  /// STATUS BADGE
  /// =====================================
  Widget _statusChip(GameStatus status) {
    switch (status) {
      case GameStatus.active:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
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

  /// =====================================
  /// STAT CARD
  /// =====================================
  Widget _statCard(String title, String value) {
    return Container(
      width: 120.w,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  /// =====================================
  /// TEAM PROGRESS CARD
  /// =====================================
  Widget _teamProgressCard(_TeamData team, int totalHoles,
      {VoidCallback? onTap}) {
    final progress = totalHoles == 0
        ? 0.0
        : ((team.birdies ?? 0) / totalHoles).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                team.name ?? "Team",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp
                ),
              ),
              Text(
                "${team.birdies ?? 0} Birdies",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text("Players: ${team.members?.length ?? team.playersCount ?? 0}"),
          SizedBox(height: 4.h),
          LinearProgressIndicator(
            value: progress,
            color: Colors.green,
            backgroundColor: Colors.green.shade100,
            minHeight: 8.h,
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress: ${(totalHoles - (team.holesRemaining ?? (totalHoles - (team.birdies ?? 0))))} / $totalHoles",
                style: AppTextStyles.bodySmall.copyWith(fontSize: 12.sp),
              ),
              Text(
                "${(progress * 100).round()}%",
                style: AppTextStyles.bodySmall.copyWith(fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "${team.holesRemaining ?? (totalHoles - (team.birdies ?? 0))} Holes Remaining",
            style: AppTextStyles.bodySmall.copyWith(fontSize: 12.sp),
          ),
        ],
      ),
    ),
    );
  }

  Widget _primaryTab({
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
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryTab({
    required String title,
    required int index,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onChanged(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 2.h,
            width: 80.w,
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _teamRankCard({required int rank, required _TeamData team}) {
    final color = rank == 1
        ? AppColors.flashyGreen
        : (rank == 2 ? AppColors.flashyYellow : AppColors.flashyblue);
    final border = rank == 1
        ? AppColors.primary
        : (rank == 2 ? AppColors.secondary : AppColors.darkBlue);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team.name ?? "Team", style: AppTextStyles.bodyMedium2),
                Text(
                  "${team.members?.length ?? 0} Players",
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
              Text("${team.birdies ?? 0}", style: AppTextStyles.bodyMedium2),
              Text(
                "${team.holesRemaining ?? ''} Holes Left",
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

  Widget _playerRankCard({required int rank, required _PlayerData player}) {
    final color = rank == 1
        ? AppColors.flashyGreen
        : (rank == 2 ? AppColors.flashyYellow : AppColors.flashyblue);
    final border = rank == 1
        ? AppColors.primary
        : (rank == 2 ? AppColors.secondary : AppColors.darkBlue);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: AppTextStyles.bodyMedium2),
                Text(
                  player.teamName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.borderColor,
                  ),
                ),
              ],
            ),
          ),
          Text("${player.birdies} B", style: AppTextStyles.bodyMedium2),
        ],
      ),
    );
  }

  Widget _teamDetailView({
    required Map<String, dynamic>? team,
    required int totalHoles,
    required VoidCallback onBack,
    required ValueChanged<Map<String, dynamic>> onPlayerTap,
  }) {
    if (team == null) {
      return Center(child: Text("No team selected"));
    }
    final members =
        (team['members'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
            [];
    final birdies = (team['teamBirdies'] ?? team['birdies'] ?? 0) as int? ?? 0;
    final holesRemaining =
        (team['holesRemaining'] ?? (totalHoles - birdies)) as int? ??
            (totalHoles - birdies);
    final teamRank = (team['rank'] ?? 0).toString();
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  size: 18.sp, color: AppColors.primary),
              onPressed: onBack,
            ),
            Expanded(
              child: Center(
                child: Text(
                  "Manage Games",
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(width: 36.w),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _smallStatCard(
              value: birdies.toString(),
              label: "Total Birdies",
              isPrimary: true,
            ),
            SizedBox(width: 10.w),
            _smallStatCard(
              value: holesRemaining.toString(),
              label: "Holes Remaining",
            ),
            SizedBox(width: 10.w),
            _smallStatCard(
              value: teamRank,
              label: "Team Rank (Live)",
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          "Team Players (${members.length})",
          style: AppTextStyles.bodyLarge.copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 10.h),
        ...members.map((member) {
          final name = (member['name'] ?? 'Player').toString();
          final birdiesVal = (member['birdies'] ?? 0).toString();
          final updated = _formatLastUpdated(member['updatedAt']);
          return GestureDetector(
            onTap: () => onPlayerTap({
              ...member,
              'teamName': team['name'] ?? 'Team',
              'teamBirdies': birdies,
              'holesRemaining': holesRemaining,
            }),
            child: Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(name, style: AppTextStyles.bodyMedium2),
                            SizedBox(width: 6.w),
                            Container(
                              height: 18.h,
                              width: 18.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 10.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Last update: $updated",
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "$birdiesVal B",
                    style: AppTextStyles.bodyMedium2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _playerDetailView({
    required Map<String, dynamic>? player,
    required int totalHoles,
    required VoidCallback onBack,
  }) {
    if (player == null) {
      return Center(child: Text("No player selected"));
    }
    final name = (player['name'] ?? 'Player').toString();
    final teamName = (player['teamName'] ?? 'Team').toString();
    final birdies = (player['birdies'] ?? 0) as int? ?? 0;
    final remaining = (totalHoles - birdies).clamp(0, totalHoles);
    final holesBirdied = (player['holesBirdied'] as List?)
            ?.whereType<num>()
            .map((e) => e.toInt())
            .toList() ??
        [];
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  size: 18.sp, color: AppColors.primary),
              onPressed: onBack,
            ),
            Expanded(
              child: Center(
                child: Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(width: 36.w),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.flashyGreen,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Column(
                  children: [
                    Text(
                      birdies.toString(),
                      style: AppTextStyles.bodyMedium2,
                    ),
                    Text("Birdies", style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  children: [
                    Text(
                      remaining.toString(),
                      style: AppTextStyles.bodyMedium2,
                    ),
                    Text("Remaining", style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          "Hole Contribution Grid",
          style: AppTextStyles.bodyLarge.copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      teamName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "$birdies",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                "Total",
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Text("Score", style: AppTextStyles.bodyMedium),
        Text(
          "PAR 4  •  00:28:42",
          style: AppTextStyles.bodySmall,
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: List.generate(totalHoles, (index) {
            final holeNumber = index + 1;
            final isBirdied = holesBirdied.contains(holeNumber);
            return Container(
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      holeNumber.toString().padLeft(2, '0'),
                      style: AppTextStyles.bodySmall,
                    ),
                    if (isBirdied)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 16.w,
                          width: 16.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _smallStatCard({
    required String value,
    required String label,
    bool isPrimary = false,
  }) {
    return Expanded(
      child: Container(
        height: 70.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.flashyGreen : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isPrimary ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: AppTextStyles.bodyMedium2),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated(dynamic raw) {
    if (raw == null) return "--";
    DateTime? time;
    if (raw is Timestamp) {
      time = raw.toDate();
    } else if (raw is String) {
      time = DateTime.tryParse(raw);
    }
    if (time == null) return "--";
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} mins ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";
    return "${diff.inDays} days ago";
  }

  List<_TeamData> _asTeams(dynamic raw) {
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().map((team) {
      final members = team['members'];
      final memberList = <_PlayerData>[];
      if (members is List) {
        for (final member in members) {
          if (member is Map<String, dynamic>) {
            memberList.add(
              _PlayerData(
                uid: (member['uid'] ?? '').toString(),
                name: (member['name'] ?? 'Player').toString(),
                teamName: (team['name'] ?? 'Team').toString(),
                birdies: (member['birdies'] ?? 0) as int? ?? 0,
              ),
            );
          }
        }
      }
      return _TeamData(
        name: (team['name'] ?? 'Team').toString(),
        birdies: (team['teamBirdies'] ?? team['birdies'] ?? 0) as int? ?? 0,
        holesRemaining: (team['holesRemaining'] ?? 0) as int? ?? 0,
        members: memberList,
      );
    }).toList();
  }

  List<_PlayerData> _buildPlayerRank(List<_TeamData> teams) {
    final players = <_PlayerData>[];
    for (final team in teams) {
      if (team.members != null) {
        players.addAll(team.members!);
      }
    }
    players.sort((a, b) => b.birdies.compareTo(a.birdies));
    return players;
  }
}

class _TeamData {
  final String? name;
  final int? birdies;
  final int? holesRemaining;
  final List<_PlayerData>? members;
  final int? playersCount;
  final int? rank;

  _TeamData({
    this.name,
    this.birdies,
    this.holesRemaining,
    this.members,
    this.playersCount,
    this.rank,
  });

  Map<String, dynamic> toMap({int? rank}) {
    return {
      'name': name,
      'teamBirdies': birdies ?? 0,
      'holesRemaining': holesRemaining ?? 0,
      'members': members?.map((m) => m.toMap()).toList() ?? [],
      if (rank != null) 'rank': rank,
    };
  }
}

class _PlayerData {
  final String uid;
  final String name;
  final String teamName;
  final int birdies;

  _PlayerData({
    required this.uid,
    required this.name,
    required this.teamName,
    required this.birdies,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'teamName': teamName,
      'birdies': birdies,
    };
  }
}
