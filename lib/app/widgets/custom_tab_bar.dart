import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomStatusTabBar extends StatelessWidget {
  final String title1;
  final String title2;
  final String title3;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CustomStatusTabBar({
    super.key,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _tabItem(title1, 0),
          _tabItem(title2, 1),
          _tabItem(title3, 2),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
