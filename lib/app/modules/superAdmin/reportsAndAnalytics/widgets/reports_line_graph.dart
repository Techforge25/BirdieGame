import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_analytics_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget buildLineGraph({
  required int activePlayers,
  String percentage = "+0%",
  String stats = "This Week",
}) {
  return AnalyticsCard(
    style: AppTextStyles.heading.copyWith(
      color: AppColors.borderColor,
      fontSize: 16,
    ),
    title: "Active Players",
    value: "$activePlayers Players",
    percentage: percentage,
    chart: LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const labels = ["W1", "W2", "W3", "W4"];
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Text(
                    labels[value.toInt()],
                    style: const TextStyle(fontSize: 12, color: AppColors.textBlack),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 1),
              FlSpot(1, 3),
              FlSpot(2, 2),
              FlSpot(3, 5),
            ],
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
    ),
    stats: stats,
  );
}
