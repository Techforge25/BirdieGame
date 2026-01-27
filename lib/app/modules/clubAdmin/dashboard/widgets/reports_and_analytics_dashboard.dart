import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_analytics_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportsAndAnalyticsDashboard extends StatelessWidget {
  const ReportsAndAnalyticsDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reports & Analytics", style: AppTextStyles.subHeading),
        SizedBox(height: 15),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid ?? 'missing')
              .snapshots(),
          builder: (context, userSnapshot) {
            final userData = userSnapshot.data?.data() ?? const {};
            final clubId = (userData['clubId'] ?? '').toString();

            if (clubId.isEmpty) {
              return _analyticsRow(
                activePlayers: 0,
                gamesPlayed: 0,
                weeklyPlayers: const [0, 0, 0, 0],
                activePlayersDelta: 0,
                monthlyGames: const [0, 0, 0, 0],
                monthLabels: const ["Jan", "Feb", "Mar", "Apr"],
                gamesDelta: 0,
              );
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('games')
                  .where('clubId', isEqualTo: clubId)
                  .snapshots(),
              builder: (context, gamesSnapshot) {
                if (gamesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final games = gamesSnapshot.data?.docs ?? const [];
                final stats = _aggregateStats(games);

                return _analyticsRow(
                  activePlayers: stats.activePlayers,
                  gamesPlayed: stats.gamesPlayed,
                  weeklyPlayers: stats.weeklyActivePlayers,
                  activePlayersDelta: stats.activePlayersDelta,
                  monthlyGames: stats.monthlyGames,
                  monthLabels: stats.monthLabels,
                  gamesDelta: stats.gamesDelta,
                );
              },
            );
          },
        ),
        // 5. View All Button
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              final nav = Get.find<ClubAdminBottomNavController>();
              if (!nav.guardClubAccess()) return;
              nav.openReportsFromDashboard();
            },
            icon: const Icon(Icons.grid_view, size: 18),
            label: const Text("View All"),
            
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              
            ),
          ),
        ),
      ],
    );
  }

  Widget _analyticsRow({
    required int activePlayers,
    required int gamesPlayed,
    required List<int> weeklyPlayers,
    required double activePlayersDelta,
    required List<int> monthlyGames,
    required List<String> monthLabels,
    required double gamesDelta,
  }) {
    final safeWeeklyPlayers = _padToFour(weeklyPlayers);
    final safeMonthlyGames = _padToFour(monthlyGames);
    final safeMonthLabels = _padLabelsToFour(monthLabels);

    return Row(
      children: [
        Expanded(
          child: AnalyticsCard(
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
            title: "Active Players",
            value: "$activePlayers Players",
            percentage: _formatDelta(activePlayersDelta),
            stats: "This Week",
            chart: _buildMiniLineChart(safeWeeklyPlayers),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: AnalyticsCard(
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
            stats: "This Month",
            title: "Games Played",
            value: "$gamesPlayed Games",
            percentage: _formatDelta(gamesDelta),
            chart: _buildMiniBarChart(safeMonthlyGames, safeMonthLabels),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniLineChart(List<int> weeklyPlayers) {
    final maxY = weeklyPlayers.reduce((a, b) => a > b ? a : b).toDouble();
    final safeMaxY = maxY <= 0 ? 4.0 : maxY + 2.0;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 3,
        minY: 0,
        maxY: safeMaxY,
        gridData: const FlGridData(show: false),
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
              reservedSize: 26,
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
                      fontSize: 11,
                      color: AppColors.textBlack,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              4,
              (i) => FlSpot(i.toDouble(), weeklyPlayers[i].toDouble()),
            ),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.flashyGreen.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBarChart(List<int> monthlyGames, List<String> labels) {
    final maxY = monthlyGames.reduce((a, b) => a > b ? a : b).toDouble();
    final safeMaxY = maxY <= 0 ? 4.0 : maxY + 2.0;

    return BarChart(
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
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[index],
                    style: const TextStyle(
                      fontSize: 11,
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
                toY: monthlyGames[index].toDouble(),
                width: 18,
                borderRadius: BorderRadius.circular(4),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _MiniStats _aggregateStats(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> games,
  ) {
    final now = DateTime.now();
    final weeklyGames = List<int>.filled(4, 0);
    final weeklyPlayersSets =
        List<Set<String>>.generate(4, (_) => <String>{});
    final activePlayerIds = <String>{};
    final monthStarts = _lastFourMonthStarts(now);
    final monthlyGames = List<int>.filled(4, 0);

    for (final doc in games) {
      final data = doc.data();
      final createdAt = _asDateTime(data['createdAt']) ??
          _asDateTime(data['updatedAt']);
      final weekIndex = _weekIndex(now, createdAt);
      if (weekIndex != null) {
        weeklyGames[weekIndex] += 1;
      }
      final monthIndex = _monthIndex(monthStarts, createdAt);
      if (monthIndex != null) {
        monthlyGames[monthIndex] += 1;
      }

      final status = (data['status'] ?? '').toString().toLowerCase();
      final isActiveGame = status == 'active' || status.isEmpty;

      final rawTeams = data['teams'];
      if (rawTeams is! List) continue;

      for (final rawTeam in rawTeams) {
        if (rawTeam is! Map) continue;
        final team = Map<String, dynamic>.from(rawTeam);
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
    final activePlayersDelta = _percentChangeFromList(weeklyActivePlayers);
    final gamesDelta = _percentChangeFromList(monthlyGames);
    final monthLabels = monthStarts.map(DateFormat('MMM').format).toList();

    return _MiniStats(
      gamesPlayed: gamesPlayed,
      activePlayers: activePlayers,
      weeklyGamesPlayed: weeklyGames,
      weeklyActivePlayers: weeklyActivePlayers,
      activePlayersDelta: activePlayersDelta,
      monthlyGames: monthlyGames,
      monthLabels: monthLabels,
      gamesDelta: gamesDelta,
    );
  }

  List<int> _padToFour(List<int> values) {
    if (values.length >= 4) return values.take(4).toList();
    return [...values, ...List<int>.filled(4 - values.length, 0)];
  }

  List<String> _padLabelsToFour(List<String> labels) {
    final padded = labels.take(4).toList();
    if (padded.length == 4) return padded;
    return [...padded, ...List<String>.filled(4 - padded.length, "")];
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  List<DateTime> _lastFourMonthStarts(DateTime now) {
    final currentMonthStart = DateTime(now.year, now.month, 1);
    return List.generate(4, (i) {
      final dt = DateTime(currentMonthStart.year, currentMonthStart.month - (3 - i), 1);
      return DateTime(dt.year, dt.month, 1);
    });
  }

  int? _monthIndex(List<DateTime> monthStarts, DateTime? createdAt) {
    if (createdAt == null) return null;
    for (var i = 0; i < monthStarts.length; i++) {
      final start = monthStarts[i];
      final end = DateTime(start.year, start.month + 1, 1);
      final isInRange =
          (createdAt.isAtSameMomentAs(start) || createdAt.isAfter(start)) &&
              createdAt.isBefore(end);
      if (isInRange) return i;
    }
    return null;
  }

  int? _weekIndex(DateTime now, DateTime? createdAt) {
    if (createdAt == null) return null;
    final diffDays = now.difference(createdAt).inDays;
    if (diffDays < 0 || diffDays >= 28) return null;
    final indexFromNow = diffDays ~/ 7;
    return 3 - indexFromNow;
  }

  double _percentChangeFromList(List<int> values) {
    final safe = _padToFour(values);
    final prev = safe[2];
    final curr = safe[3];
    if (prev <= 0) {
      return curr <= 0 ? 0 : 100;
    }
    return ((curr - prev) / prev) * 100;
  }

  String _formatDelta(double delta) {
    final sign = delta >= 0 ? "+" : "";
    return "$sign${delta.toStringAsFixed(1)}%";
  }
}

class _MiniStats {
  const _MiniStats({
    required this.gamesPlayed,
    required this.activePlayers,
    required this.weeklyGamesPlayed,
    required this.weeklyActivePlayers,
    required this.activePlayersDelta,
    required this.monthlyGames,
    required this.monthLabels,
    required this.gamesDelta,
  });

  final int gamesPlayed;
  final int activePlayers;
  final List<int> weeklyGamesPlayed;
  final List<int> weeklyActivePlayers;
  final double activePlayersDelta;
  final List<int> monthlyGames;
  final List<String> monthLabels;
  final double gamesDelta;
}
