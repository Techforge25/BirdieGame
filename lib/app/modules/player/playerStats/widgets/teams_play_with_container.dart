import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TeamsPlayWithContainer extends StatelessWidget {
  final Color iconBgColor;
  final Icon icon;
  final String teamName;
  final String gamesPerTeam;
  const TeamsPlayWithContainer({
    super.key,
    required this.iconBgColor,
    required this.icon,
    required this.teamName,
    required this.gamesPerTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          SizedBox(width: 20.w,),
          Column(
            children: [
              Text(
                teamName,
                style: AppTextStyles.bodyMedium2.copyWith(
                  color: AppColors.textBlack,
                ),
              ),

              Text(
                gamesPerTeam,
                style: AppTextStyles.bodyMedium2.copyWith(
                  color: AppColors.borderColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
