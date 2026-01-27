import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
class AnalyticsCard extends StatelessWidget {
  final String title, value, percentage,stats;
  final Widget chart;
  final TextStyle style;
  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.percentage,
    required this.chart, required this.stats, required this.style,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style:style),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
              const Spacer(),
              Text(percentage, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
           Text(stats, style: TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 20),
          // Chart yahan show hoga
          SizedBox(height: 100, child: chart),
        ],
      ),
    );
  }
}










