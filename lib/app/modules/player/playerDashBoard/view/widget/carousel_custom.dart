import 'package:bierdygame/app/modules/player/playerDashBoard/controller/player_dashboard_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CarouselCard extends GetView<PlayerDashboardController> {
  final String image;
  final String title;
  final String subTitle;
  const CarouselCard({super.key, required this.image,required this.title,required this.subTitle, });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
           
            /// Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withOpacity(0.85),
                  ],
                ),
              ),
            ),

            /// Text Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    subTitle,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  SizedBox(height: 20.h,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
