
  
  import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

  Widget buildCustomGrid({
  required int activeGames,
  required int totalTeams,
  required int totalPlayers,
  required int completedGames,
}) {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2, // 2 columns
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 181 / 151, // IMPORTANT: match card ratio
    children: [
      statCard(
        title: "Active Games",
        value: activeGames.toString(),
        imagePath: "assets/images/banda.png",
      ),
      statCard(
        title: "Total Teams",
        value: totalTeams.toString(),
        imagePath: "assets/images/golf_ball.png",
      ),
      statCard(
        title: "Total Players",
        value: totalPlayers.toString(),
        imagePath: "assets/images/excited_banda.png",

      ),
      statCard(
        title: "Completed",
        value: completedGames.toString(),
        imagePath: "assets/images/golf_ka_saman.png",
      ),
    ],
  );
}


Widget statCard({
  required String title,
  required String value,
  required String imagePath,
  Color stripColor = const Color(0xFF00833A),
}) {
  return Container(
    height: 151,
    width: 181,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 15,
          offset: const Offset(0, 5),
        )
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Left strip
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 7,
              color: stripColor,
            ),
          ),

          // Text
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 20, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Image
          Positioned(
            bottom: -40,
            right: 0,
            child: Image.asset(
              imagePath,
              height: 140.h,
            ),
          ),
        ],
      ),
    ),
  );
}
