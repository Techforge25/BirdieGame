import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
Widget CustomDropDownWidget({
  bool error = true,
  String? title,
  required List list,
  Key? key,
  bool? showSearchBOX,
  required ValueChanged valChanged,
  String? selectedItem,
  Color? selectedTextColor,
  bool? enable,
  int? color,
  BorderRadius? borderRadius,
  Color? selectedItemColor,
  Color? backgroundColor,
  Color? iconColor,
  Color? borderColor,
  Color? disabledBorderColor,
  Future<bool?> Function(dynamic)? onBeforePopupOpening,
  String? Function(dynamic)? validator,
}) {
  return CustomDropdown.search(
    hintText: title,
    decoration: CustomDropdownDecoration(
      closedBorder: Border.all(color: borderColor ?? AppColors.borderColor),
      
      listItemDecoration: ListItemDecoration(
        selectedColor: AppColors.primary
      ),
      closedBorderRadius: BorderRadius.circular(8),
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textBlack),
      headerStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textBlack),
    ),
    enabled: enable ?? true,
    key: key,
    onChanged: valChanged,
    validator: validator,
    initialItem: selectedItem,
    items: list,
  );
}
