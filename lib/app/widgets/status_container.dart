import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusContainer extends StatelessWidget {
  final String status;
  final VoidCallback? onTap;
  final Color? color;
  const StatusContainer({super.key, required this.status, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary, width: 1.3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 5,
                            width: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 5.w,),
                          Text(
                            status,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}