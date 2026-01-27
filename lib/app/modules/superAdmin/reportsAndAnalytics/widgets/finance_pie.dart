import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinancePieChart extends StatelessWidget {
  final String title;
  final String indicatorText1;
  final String indicatorText2;
  final String? indicatorText3;
  final String? indicatorText4;
  final String? indicatorText5;
  final Color? color;
  final Color? color2;
  final Color? color3;
  final Color? color4;
  final Color? color5;
  final int? playersPerClub;
  final List<PieChartSectionData> sections;

  const FinancePieChart({
    super.key,
    required this.sections,
    required this.title,
    required this.indicatorText1,
    required this.indicatorText2,
    this.indicatorText3,
    this.color,
    this.indicatorText4,
    this.color2,
    this.indicatorText5,
    this.color3,
    this.color4,
    this.color5,
    this.playersPerClub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8.r)),
      
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.heading.copyWith(
                color: Colors.black,
                fontSize: 18.sp,
              ),
            ),
            Text(
              playersPerClub.toString(),
              style: AppTextStyles.heading.copyWith(
                color: Colors.black,
                fontSize: 22.sp,
              ),
            ),
            Divider(thickness: 0.8),
            SizedBox(height: 10.h),
            SizedBox(
              height: 200.h,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 60,
                  sections: sections,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Indicator(
                  color: color ?? AppColors.primary,
                  text: indicatorText1,
                ),
                SizedBox(width: 8),
                _Indicator(
                  color: color2 ?? Colors.red.shade400,
                  text: indicatorText2,
                ),
                SizedBox(width: 8),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Indicator(
                  color: color3 ?? Colors.transparent,
                  text: indicatorText3 ?? "",
                ),
                SizedBox(width: 8),
                _Indicator(
                  color: color4 ?? Colors.transparent,
                  text: indicatorText4 ?? "",
                ),
                SizedBox(width: 8),
                _Indicator(
                  color: color5 ?? Colors.transparent,
                  text: indicatorText5 ?? "",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
