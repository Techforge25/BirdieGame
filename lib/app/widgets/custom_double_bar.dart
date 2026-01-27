import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_analytics_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class CustomDoubleBar extends StatelessWidget {
  const CustomDoubleBar({super.key});

  List<String> _recentMonthLabels() {
    final now = DateTime.now();
    return List.generate(4, (index) {
      final date = DateTime(now.year, now.month - (3 - index), 1);
      return _monthLabel(date.month);
    });
  }

  String _monthLabel(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  DateTime? _extractDate(Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) return createdAt.toDate();
    final updatedAt = data['updatedAt'];
    if (updatedAt is Timestamp) return updatedAt.toDate();
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 200;
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final labels = _recentMonthLabels();
            final now = DateTime.now();
            final monthKeys = List.generate(4, (i) {
              final date = DateTime(now.year, now.month - (3 - i), 1);
              return '${date.year}-${date.month}';
            });

            final counts = <String, int>{};
            for (final key in monthKeys) {
              counts[key] = 0;
            }

            for (final doc in docs) {
              final date = _extractDate(doc.data());
              if (date == null) continue;
              final key = '${date.year}-${date.month}';
              if (counts.containsKey(key)) {
                counts[key] = (counts[key] ?? 0) + 1;
              }
            }

            final values = monthKeys.map((k) => counts[k] ?? 0).toList();
            final current = values.isNotEmpty ? values.last : 0;
            final prev = values.length > 1 ? values[values.length - 2] : 0;
            final percent = prev == 0
                ? 0
                : (((current - prev) / prev) * 100).round();
            final percentLabel = percent >= 0 ? "+$percent%" : "$percent%";

            Widget userChart = LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= labels.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
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
                      values.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        values[index].toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.flashyGreen.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );

            final usersCard = AnalyticsCard(
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
              title: "Monthly User Growth",
              value: "${current} Users",
              percentage: percentLabel,
              chart: userChart,
              stats: 'This month',
            );

            final gamesCard = AnalyticsCard(
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
              stats: "This month",
              title: "Games Played",
              value: "0",
              percentage: "+0%",
              chart: _buildScrollableMonthBarChart(),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Reports & Analytics", style: AppTextStyles.subHeading),
                SizedBox(height: 15),
                if (isNarrow)
                  Column(
                    children: [
                      usersCard,
                      const SizedBox(height: 12),
                      gamesCard,
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: usersCard),
                      const SizedBox(width: 15),
                      Expanded(child: gamesCard),
                    ],
                  ),
                const SizedBox(height: 20),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.toNamed(Routes.REPORTS_AND_ANALYTICS_SUPER_ADMIN);
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
          },
        );
      },
    );
  }

  Widget _buildScrollableMonthBarChart() {
    final months = _recentMonthLabels();
    final values = List<double>.generate(months.length, (_) => 0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: months.length * 42, // controls scrolling
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: false),

            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= months.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        months[value.toInt()],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            barGroups: List.generate(
              values.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: values[index],
                    width: 22,
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
