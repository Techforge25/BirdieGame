import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

Widget buildWidgetStatus({
  required bool status,
  required Function(bool value) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
       Text(
        "Status",
        style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
      ),
      const SizedBox(height: 8),
      Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            _statusItem(
              title: "Active",
              isSelected: status,
              onTap: () => onChanged(true),
              color: AppColors.primary
            ),
            _statusItem(
              color: AppColors.darkRed,
              title: "Inactive",
              isSelected: !status,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ),
    ],
  );
}
Widget _statusItem({
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
  required Color color
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
