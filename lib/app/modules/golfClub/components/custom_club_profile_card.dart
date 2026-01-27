import 'package:bierdygame/app/modules/golfClub/clubEdit/bindings/club_edit_binding.dart';
import 'package:bierdygame/app/modules/golfClub/clubEdit/controller/club_edit_controller.dart';
import 'package:bierdygame/app/modules/golfClub/clubEdit/view/club_edit_modal.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';

Widget customProfileContainer({
  required BuildContext context,
  required String nameOfClub,
  String? clubId,
  String? clubLocation,
  String? clubLogoPath,
  String? clubLogoBase64,
  bool showEdit = true,
  VoidCallback? onEditTap,
}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading circle
          CircleAvatar(
            radius: 30,
            backgroundImage: clubLogoPath != null && clubLogoPath.isNotEmpty
                ? FileImage(File(clubLogoPath))
                : clubLogoBase64 != null && clubLogoBase64.isNotEmpty
                    ? MemoryImage(base64Decode(clubLogoBase64))
                    : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nameOfClub,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 20),
                ),
                SizedBox(height: 4),
                Text("Golf Club", style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          if (showEdit)
            GestureDetector(
              onTap: onEditTap ??
                  () {
                    if (Get.isRegistered<ClubEditController>()) {
                      Get.delete<ClubEditController>(force: true);
                    }
                    ClubEditBinding(
                      clubId: clubId,
                      initialName: nameOfClub,
                      initialLocation: clubLocation,
                      initialLogoPath: clubLogoPath,
                      initialLogoBase64: clubLogoBase64,
                    ).dependencies();
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const ClubEditModal(),
                    ).whenComplete(() {
                      if (Get.isRegistered<ClubEditController>()) {
                        Get.delete<ClubEditController>(force: true);
                      }
                    });
                  },
              child: Icon(Icons.edit_outlined, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
