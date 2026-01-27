import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildContainerClubAdmin({
  required IconData icon,
  required String title,
  required Color bgColor,
  required VoidCallback onTap
}){
  return Column(
    children: [
      Container(
        height: 56.h,
        width: 56.w,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.r)
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Icon(icon,color: AppColors.white,),
        ),
      ),
      SizedBox(height: 10.h,),
      Text(title,style: AppTextStyles.bodySmall,),
    ],
  );
}