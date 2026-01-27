import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/widgets/status_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

Widget buildAdminDetailCard({
  required String name,
  required String clubName,
  required String role,
  required bool isActive,
  String? photoBase64,
  VoidCallback? onAvatarTap,
}) {
  ImageProvider avatarProvider = AssetImage("assets/images/dashboard_img.png",);
  if (photoBase64 != null && photoBase64.isNotEmpty) {
    avatarProvider = MemoryImage(base64Decode(photoBase64));
  }
  return Container(
    padding: EdgeInsets.symmetric(vertical: 30.h),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.primary),
      color: AppColors.flashyGreen,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: avatarProvider,
                ),
              ),
              if (onAvatarTap != null)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Text(name),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10.w,
          children: [
            Text(clubName),
            Container(
              height: 10,
              width: 2,
              color: AppColors.borderColor,
            ),
            Text(role),
          ],
        ),
        SizedBox(height: 20.h),
        StatusContainer(status: isActive ? "Active" : "Inactive"),
      ],
    ),
  );
}
