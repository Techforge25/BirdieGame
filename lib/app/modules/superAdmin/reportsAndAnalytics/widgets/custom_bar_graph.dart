import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildBarGraph({
  required String title,
  final Color? titleColor,
  final Color? barColor,
  final int? gamesplayed,
}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.heading.copyWith(color: titleColor ?? AppColors.borderColor,fontSize: 16)),
            Text(gamesplayed.toString(), style: AppTextStyles.heading.copyWith(color: titleColor ?? Colors.black,fontSize: 22),),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,

                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.round()}',
                          const TextStyle(color: Colors.black),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 19,
                        getTitlesWidget: (value, meta) {
                          // if (value % 3 == 0) {
                          //   return Text(value.toInt().toString());
                          // }
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('W1', style: style);
                              break;
                            case 1:
                              text = const Text('W2', style: style);
                              break;
                            case 2:
                              text = const Text('W3', style: style);
                              break;
                            case 3:
                              text = const Text('W4', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(meta: meta, child: text);
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      top: BorderSide.none,
                      right: BorderSide.none,
                      left: BorderSide(color: Colors.black38),
                      bottom: BorderSide(color: Colors.black38),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 9.5,
                          width: 50.w,
                          color: barColor ?? AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 12,
                          color: barColor ?? AppColors.primary,

                          width: 50.w,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 11,
                          color: barColor ?? AppColors.primary,

                          width: 50.w,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 11.5,
                          color: barColor ?? AppColors.primary,

                          width: 50.w,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    
    );
  }


