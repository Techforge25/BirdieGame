import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bierdygame/app/theme/app_colors.dart';

class GamePlayersGrid extends StatefulWidget {
  const GamePlayersGrid({super.key});

  @override
  State<GamePlayersGrid> createState() => _GamePlayersGridState();
}

class _GamePlayersGridState extends State<GamePlayersGrid> {
  final List<GridItem> gridItems = [
    GridItem(number: 1, name: '(You)', isSelected: false),
    GridItem(number: 2, name: '(You)', isSelected: false),
    GridItem(number: 3, name: 'Emily', isSelected: false),
    GridItem(number: 4, name: 'Ryan', isSelected: false),
    GridItem(number: 5, name: '(You)', isSelected: false),
    GridItem(number: 6, name: '(You)', isSelected: false),
    GridItem(number: 7, name: 'Emily', isSelected: false),
    GridItem(number: 8, name: '(You)', isSelected: false),
    GridItem(number: 9, name: '(You)', isSelected: false),
    GridItem(number: 10, name: '(You)', isSelected: false),
    GridItem(number: 11, name: '(You)', isSelected: false),
    GridItem(number: 12, name: 'Emma', isSelected: false),
    GridItem(number: 13, name: 'Emma', isSelected: false),
    GridItem(number: 14, name: '(You)', isSelected: false),
    GridItem(number: 15, name: '(You)', isSelected: false),
    GridItem(number: 16, name: '(You)', isSelected: false),
    GridItem(number: 17, name: '(You)', isSelected: false),
    GridItem(number: 18, name: 'Emily', isSelected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 1.5,
      crossAxisCount: 3,
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(gridItems.length, (index) {
        final item = gridItems[index];

        return GestureDetector(
          onTap: item.isDisabled
              ? null
              : () {
                  setState(() {
                    item.isSelected = !item.isSelected;
                  });
                },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.borderColorLight,
              borderRadius: BorderRadius.circular(14.r),
              border: item.isSelected
                  ? Border.all(color: AppColors.primary, width: 1.4)
                  : null,
            ),
            child: Stack(
              children: [
                /// ✅ CHECK ICON
                if (item.isSelected)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                /// 🔹 NUMBER + NAME
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.number.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.name ?? '',
                        style: AppTextStyles.bodyMedium2.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// 🔹 MODEL
class GridItem {
  final int number;
  final String? name;
  bool isSelected;
  final bool isDisabled;

  GridItem({
    required this.number,
    this.name,
    this.isSelected = false,
    this.isDisabled = false,
  });
}
