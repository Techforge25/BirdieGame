import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GolfClubController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> clubStream(String clubId) {
    return _firestore.collection('clubs').doc(clubId).snapshots();
  }

  Future<void> setClubStatus(String clubId, bool isActive) async {
    final status = isActive ? 'active' : 'blocked';
    await _firestore.collection('clubs').doc(clubId).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

void removeClub()  {
    Get.dialog(
     Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16,),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: AppColors.flashyRed,
            border: Border.all(color: AppColors.darkRed),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.flashyRed,
                      radius: 40.r,
                      child: Icon(Icons.delete,color: AppColors.darkRed,size: 40,),
                    ),
                    Text(
                      "Remove Club",
                      style: AppTextStyles.bodyMedium2.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                onPressed: () {},
                btnName: "Remove Club",
                backColor: AppColors.darkRed,
                textColor: AppColors.white,
                borderRadius: 15.r,
              ),
              SizedBox(height: 10.h),
              CustomElevatedButton(
                onPressed: () {
                  Get.back();
                },
                btnName: "Cancel",
                backColor: AppColors.flashyRed,
                textColor: AppColors.darkRed,
                borderColor: AppColors.darkRed,
                borderRadius: 15.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void blockClub()  {
    Get.dialog(
     Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16,),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: AppColors.flashyYellow,
            border: Border.all(color: AppColors.secondary),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      
                      backgroundColor: AppColors.flashyYellow,
                      radius: 40.r,
                      child: Icon(Icons.block,color: AppColors.secondary,size: 40,),
                    ),
                    Text(
                      "Block Club",
                      style: AppTextStyles.bodyMedium2.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
             
              SizedBox(height: 10.h),
              CustomElevatedButton(
                onPressed: () {
                  Get.back();
                },
                btnName: "Cancel",
                backColor: AppColors.flashyYellow,
                textColor: AppColors.secondary,
                borderColor: AppColors.secondary,
                borderRadius: 15.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
