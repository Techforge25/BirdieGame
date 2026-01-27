import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CounterSettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final int minValue;
  final int maxValue;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color iconBgColor;
  final IconData icon;

  const CounterSettingTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    required this.iconBgColor,
    required this.icon,
    this.minValue = 1,
    this.maxValue = 99,
  });

  @override
  Widget build(BuildContext context) {
    final bool canDecrease = value > minValue;
    final bool canIncrease = value < maxValue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),

          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // COUNTER
          Row(
            children: [
              _actionButton(
                icon: Icons.remove,
                enabled: canDecrease,
                onTap: onDecrement,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _actionButton(
                icon: Icons.add,
                enabled: canIncrease,
                onTap: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.black : Colors.grey.shade400,
        ),
      ),
    );
  }
}
