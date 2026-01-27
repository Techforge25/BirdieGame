import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_tab_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ClubAdminReportsAndAnalyticsView extends StatelessWidget {
  ClubAdminReportsAndAnalyticsView({
    super.key,
    required this.onBackToDashboard,
  });

  final VoidCallback onBackToDashboard;
  final RxInt _selectedTab = 0.obs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onBackToDashboard,
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 80.w),
                Text(
                  "Reports & Analytics",
                  style: AppTextStyles.miniHeadings,
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Obx(
              () => CustomStatusTabBar(
                title1: "Weekly",
                title2: "Monthly",
                title3: "Yearly",
                selectedIndex: _selectedTab.value,
                onChanged: (index) => _selectedTab.value = index,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid ?? 'missing')
                    .snapshots(),
                builder: (context, userSnapshot) {
                  final userData = userSnapshot.data?.data() ?? const {};
                  final clubIdFromUser = (userData['clubId'] ?? '').toString();
                  final navClubId =
                      Get.find<ClubAdminBottomNavController>().clubId;
                  final clubId =
                      clubIdFromUser.isNotEmpty ? clubIdFromUser : navClubId;

                  if (clubId.isEmpty) {
                    return const Center(child: Text("No club assigned"));
                  }

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('games')
                        .where('clubId', isEqualTo: clubId)
                        .snapshots(),
                    builder: (context, gamesSnapshot) {
                      if (gamesSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (gamesSnapshot.hasError) {
                        return const Center(
                          child: Text("Failed to load reports"),
                        );
                      }

                      final games = gamesSnapshot.data?.docs ?? const [];
                      final stats = _aggregateStats(games);

                      return Obx(() {
                        switch (_selectedTab.value) {
                          case 1:
                            return _reportsBody(
                              stats,
                              label: "This Month",
                            );
                          case 2:
                            return _reportsBody(
                              stats,
                              label: "This Year",
                            );
                          default:
                            return _reportsBody(
                              stats,
                              label: "This Week",
                            );
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            CustomElevatedButton(
              onPressed: () {},
              btnName: "Export CSV / PDF",
              backColor: AppColors.primary,
              borderRadius: 10,
              icon: const Icon(Icons.download_outlined, color: Colors.white),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _reportsBody(_ReportStats stats, {required String label}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lineCard(stats: stats, label: label),
          const SizedBox(height: 14),
          _barCard(stats: stats, label: label),
          const SizedBox(height: 14),
          _pieCard(stats: stats),
          const SizedBox(height: 16),
          Text(
            "Top Winning Teams",
            style: AppTextStyles.bodyLarge.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 10),
          ...stats.topTeamsByWins.take(3).toList().asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _topTeamTile(
                    team: entry.value,
                    rank: entry.key + 1,
                  ),
                ),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _lineCard({required _ReportStats stats, required String label}) {
    final maxY = (stats.weeklyActivePlayers.isEmpty
            ? stats.activePlayers
            : stats.weeklyActivePlayers.reduce((a, b) => a > b ? a : b))
        .toDouble();
    final safeMaxY = maxY <= 0 ? 4.0 : maxY + 2.0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Active Players",
            style: AppTextStyles.heading.copyWith(
              color: AppColors.borderColor,
              fontSize: 16,
            ),
          ),
          Text(
            "${stats.activePlayers} Players",
            style: AppTextStyles.heading.copyWith(fontSize: 22),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.borderColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180.h,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 3,
                minY: 0,
                maxY: safeMaxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        const labels = ["W1", "W2", "W3", "W4"];
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          labels[index],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textBlack,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      4,
                      (i) => FlSpot(
                        i.toDouble(),
                        stats.weeklyActivePlayers[i].toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.flashyGreen.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barCard({required _ReportStats stats, required String label}) {
    final maxY = stats.weeklyGamesPlayed.reduce((a, b) => a > b ? a : b);
    final safeMaxY = (maxY <= 0 ? 4 : maxY + 2).toDouble();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Games Played",
            style: AppTextStyles.heading.copyWith(
              color: AppColors.borderColor,
              fontSize: 16,
            ),
          ),
          Text(
            "${stats.gamesPlayed} Games",
            style: AppTextStyles.heading.copyWith(fontSize: 22),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.borderColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: safeMaxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        const labels = ["W1", "W2", "W3", "W4"];
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textBlack,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  4,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: stats.weeklyGamesPlayed[index].toDouble(),
                        width: 36.w,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pieCard({required _ReportStats stats}) {
    final totalMatches = stats.topTeamsByBirdies.fold<int>(
      0,
      (sum, team) => sum + team.matches,
    );

    final sections = List.generate(3, (index) {
      final team = index < stats.topTeamsByBirdies.length
          ? stats.topTeamsByBirdies[index]
          : null;
      final value = (team?.matches ?? 0).toDouble();
      final safeValue = totalMatches == 0 ? 1.0 : value;
      final colors = [
        const Color(0xff00B67A),
        const Color(0xffE6874E),
        const Color(0xff2F80ED),
      ];

      final percent = totalMatches == 0
          ? 0
          : ((value / totalMatches) * 100).round();

      return PieChartSectionData(
        color: colors[index],
        value: safeValue,
        title: percent == 0 ? "" : "$percent",
        radius: 28,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    });

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Most Active Teams",
            style: AppTextStyles.heading.copyWith(
              color: AppColors.borderColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                borderData: FlBorderData(show: false),
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._buildPieIndicators(stats),
        ],
      ),
    );
  }

  List<Widget> _buildPieIndicators(_ReportStats stats) {
    final colors = [
      const Color(0xff00B67A),
      const Color(0xffE6874E),
      const Color(0xff2F80ED),
    ];
    final items = stats.topTeamsByBirdies.take(3).toList();

    if (items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Text("No team data yet"),
        ),
      ];
    }

    return List.generate(items.length, (index) {
      final team = items[index];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                team.name,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            Text(
              "${team.matches} Matches",
              style: AppTextStyles.bodySmall.copyWith(
                color: colors[index],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _topTeamTile({required _TeamAgg team, required int rank}) {
    final winRate = team.matches == 0
        ? 0
        : ((team.totalWins / team.matches) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Wins: ${team.totalWins} | Win Rate: $winRate%",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.borderColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$rank",
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  _ReportStats _aggregateStats(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> games,
  ) {
    final now = DateTime.now();

    final weeklyGames = List<int>.filled(4, 0);
    final weeklyPlayersSets =
        List<Set<String>>.generate(4, (_) => <String>{});

    final teamAgg = <String, _TeamAgg>{};
    final activePlayerIds = <String>{};

    for (final doc in games) {
      final data = doc.data();
      final createdAt = _asDateTime(data['createdAt']) ??
          _asDateTime(data['updatedAt']);
      final weekIndex = _weekIndex(now, createdAt);
      if (weekIndex != null) {
        weeklyGames[weekIndex] += 1;
      }

      final status = (data['status'] ?? '').toString().toLowerCase();
      final isActiveGame = status == 'active' || status.isEmpty;

      final rawTeams = data['teams'];
      if (rawTeams is! List) continue;

      for (final rawTeam in rawTeams) {
        if (rawTeam is! Map) continue;
        final team = Map<String, dynamic>.from(rawTeam);
        final name = (team['name'] ?? 'Team').toString();
        final totalWins = _asInt(team['totalWins']);
        final birdies = _asInt(team['teamBirdies']);

        final current = teamAgg[name] ??
            _TeamAgg(name: name, matches: 0, totalWins: 0, birdies: 0);
        teamAgg[name] = current.copyWith(
          matches: current.matches + 1,
          totalWins: current.totalWins + totalWins,
          birdies: current.birdies + birdies,
        );

        final members = team['members'];
        if (members is! List) continue;
        for (final rawMember in members) {
          if (rawMember is! Map) continue;
          final member = Map<String, dynamic>.from(rawMember);
          final uid = (member['uid'] ?? member['email'] ?? '').toString();
          if (uid.isEmpty) continue;

          if (isActiveGame) {
            activePlayerIds.add(uid);
          }
          if (weekIndex != null) {
            weeklyPlayersSets[weekIndex].add(uid);
          }
        }
      }
    }

    final weeklyActivePlayers = weeklyPlayersSets.map((s) => s.length).toList();
    final gamesPlayed = games.length;
    final activePlayers = activePlayerIds.isEmpty
        ? weeklyPlayersSets.expand((s) => s).toSet().length
        : activePlayerIds.length;

    final teams = teamAgg.values.toList();
    teams.sort((a, b) => b.birdies.compareTo(a.birdies));
    final topTeamsByBirdies = teams.take(3).toList();

    final teamsByWins = teamAgg.values.toList()
      ..sort((a, b) => b.totalWins.compareTo(a.totalWins));

    return _ReportStats(
      gamesPlayed: gamesPlayed,
      activePlayers: activePlayers,
      weeklyGamesPlayed: weeklyGames,
      weeklyActivePlayers: weeklyActivePlayers,
      topTeamsByBirdies: topTeamsByBirdies,
      topTeamsByWins: teamsByWins,
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  int? _weekIndex(DateTime now, DateTime? createdAt) {
    if (createdAt == null) return null;
    final diffDays = now.difference(createdAt).inDays;
    if (diffDays < 0 || diffDays >= 28) return null;
    final indexFromNow = diffDays ~/ 7; // 0=this week, 3=oldest
    return 3 - indexFromNow; // map to W1..W4 left-to-right
  }
}

class _ReportStats {
  const _ReportStats({
    required this.gamesPlayed,
    required this.activePlayers,
    required this.weeklyGamesPlayed,
    required this.weeklyActivePlayers,
    required this.topTeamsByBirdies,
    required this.topTeamsByWins,
  });

  final int gamesPlayed;
  final int activePlayers;
  final List<int> weeklyGamesPlayed;
  final List<int> weeklyActivePlayers;
  final List<_TeamAgg> topTeamsByBirdies;
  final List<_TeamAgg> topTeamsByWins;
}

class _TeamAgg {
  const _TeamAgg({
    required this.name,
    required this.matches,
    required this.totalWins,
    required this.birdies,
  });

  final String name;
  final int matches;
  final int totalWins;
  final int birdies;

  _TeamAgg copyWith({
    int? matches,
    int? totalWins,
    int? birdies,
  }) {
    return _TeamAgg(
      name: name,
      matches: matches ?? this.matches,
      totalWins: totalWins ?? this.totalWins,
      birdies: birdies ?? this.birdies,
    );
  }
}

