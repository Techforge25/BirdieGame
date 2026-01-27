import 'package:bierdygame/app/modules/superAdmin/reportsAndAnalytics/controller/reports_and_analytics_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/reportsAndAnalytics/widgets/custom_bar_graph.dart';
import 'package:bierdygame/app/modules/superAdmin/reportsAndAnalytics/widgets/custom_report_pie_chart.dart';
import 'package:bierdygame/app/modules/superAdmin/reportsAndAnalytics/widgets/reports_line_graph.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_tab_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ReportsAndAnalytics extends GetView<ReportsAndAnalyticsController> {
  const ReportsAndAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 100.w),
                  Text(
                    "Reports And Analytics",
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
                  selectedIndex: controller.selectedTab.value,
                  onChanged: controller.changeTab,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  switch (controller.selectedTab.value) {
                    case 0:
                      return _weeklyStats();
                    case 1:
                      return _monthlyStats();
                    default:
                      return _yearlyStats();
                  }
                }),
              ),
                            SizedBox(height: 30.h,),

              CustomElevatedButton(onPressed: (){}, btnName: "Export CSV / PDF"),
            ],
          ),
        ),
      ),
    );
  }

  /// List of All Clubs
  Widget _weeklyStats() {
    return SingleChildScrollView(
      child: Column(
        spacing: 10.0,
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'player')
                .snapshots(),
            builder: (context, playersSnapshot) {
              final players = playersSnapshot.data?.docs ?? [];
              final activePlayers = players.where((doc) {
                final data = doc.data();
                final isActive = data['isActive'] == true;
                final status =
                    (data['status'] ?? '').toString().toLowerCase();
                return isActive || status == 'active';
              }).length;
              return buildLineGraph(activePlayers: activePlayers);
            },
          ),
          buildBarGraph(title: "Games Played", gamesplayed: 0),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
            builder: (context, clubsSnapshot) {
              final clubs = clubsSnapshot.data?.docs ?? [];
              final clubNames = <String, String>{};
              for (final club in clubs) {
                clubNames[club.id] =
                    (club.data()['name'] ?? 'Club').toString();
              }
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'player')
                    .snapshots(),
                builder: (context, playersSnapshot) {
                  final players = playersSnapshot.data?.docs ?? [];
                  final counts = <String, int>{};
                  for (final doc in players) {
                    final clubId = (doc.data()['clubId'] ?? '').toString();
                    if (clubId.isEmpty) continue;
                    counts[clubId] = (counts[clubId] ?? 0) + 1;
                  }

                  final totalPlayers = counts.values.fold(0, (a, b) => a + b);
                  final avgPlayersPerClub = clubs.isEmpty
                      ? 0
                      : (totalPlayers / clubs.length).round();

                  final topEntries = counts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final top3 = topEntries.take(3).toList();
                  final colors = [
                    const Color(0xffE6874E),
                    const Color(0xff00B67A),
                    AppColors.darkBlue,
                  ];

                  double percentFor(int value) {
                    if (totalPlayers == 0) return 0;
                    return (value / totalPlayers) * 100;
                  }

                  final sections = List.generate(3, (index) {
                    final value =
                        index < top3.length ? top3[index].value : 0;
                    final percent = percentFor(value);
                    return PieChartSectionData(
                      color: colors[index],
                      value: totalPlayers == 0 ? 1 : value.toDouble(),
                      title: percent.round().toString(),
                      radius: 25,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  });

                  final indicator1 = top3.isNotEmpty
                      ? clubNames[top3[0].key] ?? 'Club'
                      : 'N/A';
                  final indicator2 = top3.length > 1
                      ? clubNames[top3[1].key] ?? 'Club'
                      : 'N/A';
                  final indicator3 = top3.length > 2
                      ? clubNames[top3[2].key] ?? 'Club'
                      : 'N/A';

                  return buildPieChart(
                    playersPerClub: avgPlayersPerClub,
                    percent1: 0,
                    percent2: 0,
                    title: "Players Per Club",
                    indicatorText1: indicator1,
                    indicatorText2: indicator2,
                    indicatorText3: indicator3,
                    color3: AppColors.darkBlue,
                    sections: sections,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Active Clubs placeholder
  Widget _monthlyStats() => const Text("Monthly Stats");

  /// Blocked Clubs placeholder
  Widget _yearlyStats() => const Text("Yealry Stats");
}
