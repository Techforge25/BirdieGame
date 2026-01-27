import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GridStatsCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final Color iconBgColor;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;
  final Color? valueColor;

  const GridStatsCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.iconBgColor,
    required this.color1,
    required this.color2,
    required this.onTap,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderColorLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),

            SizedBox(height: 15.h),

            /// 🔹 Title
            Text(
              title,
              style: AppTextStyles.bodyMedium2.copyWith(
                color: iconBgColor,
              ),
            ),

            SizedBox(height: 4.h),

            /// 🔹 Subtitle
            Text(
              subTitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: iconBgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
