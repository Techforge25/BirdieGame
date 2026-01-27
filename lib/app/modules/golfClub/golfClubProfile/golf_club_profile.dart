import 'package:bierdygame/app/modules/golfClub/components/custom_club_profile_card.dart';
import 'package:bierdygame/app/modules/golfClub/controller/golf_club_controller.dart';
import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class GolfClubProfilePage extends StatelessWidget {
  final String clubId;
  final String nameOfClub;
  final String? clubLocation;
  const GolfClubProfilePage({
    super.key,
    this.clubId = '',
    required this.nameOfClub,
    this.clubLocation,
  });

  @override
  Widget build(BuildContext context) {
    final GolfClubController controller =
        Get.isRegistered<GolfClubController>()
            ? Get.find<GolfClubController>()
            : Get.put(GolfClubController());
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userStream = currentUserId.isEmpty
        ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
        : FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 22,
            color: AppColors.primary,
          ),
        ),
        title: Text("Club Information", style: AppTextStyles.miniHeadings),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: userStream,
            builder: (context, userSnapshot) {
              final role =
                  userSnapshot.data?.data()?['role']?.toString().toLowerCase();
              final isSuperAdmin =
                  role == 'super_admin' || role == 'superadmin';
              final isClubAdmin = role == 'club_admin';
              final canEditClub = isSuperAdmin || isClubAdmin;
              return ListView(
                children: [
                  clubId.isEmpty
                      ? customProfileContainer(
                          context: context,
                          nameOfClub: nameOfClub,
                          clubId: clubId,
                          clubLocation: clubLocation,
                          showEdit: canEditClub,
                        )
                      : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: controller.clubStream(clubId),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.data();
                            final logoPath = data?['logoPath']?.toString();
                            final logoBase64 = data?['logoBase64']?.toString();
                            final clubName =
                                (data?['name'] ?? nameOfClub).toString();
                            final location =
                                (data?['location'] ?? clubLocation).toString();
                            return customProfileContainer(
                              context: context,
                              nameOfClub: clubName,
                              clubId: clubId,
                              clubLocation: location,
                              clubLogoPath: logoPath,
                              clubLogoBase64: logoBase64,
                              showEdit: canEditClub,
                            );
                          },
                        ),
                  SizedBox(height: 16.h),
                  Text("Status", style: AppTextStyles.bodyMedium),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: clubId.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            child: Text("Club Status"),
                          )
                        : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: controller.clubStream(clubId),
                            builder: (context, snapshot) {
                              final data = snapshot.data?.data();
                              final status =
                                  (data?['status'] ?? 'active').toString();
                              final isActive = status == 'active';
                              return Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                    child: Container(
                                      height: 14.h,
                                      width: 14.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.darkRed,
                                      ),
                                    ),
                                  ),
                                  Text("Club Status"),
                                  Spacer(),
                                  Switch(
                                    value: isActive,
                                    onChanged: (!isSuperAdmin || clubId.isEmpty)
                                        ? null
                                        : (value) {
                                            controller.setClubStatus(
                                                clubId, value);
                                          },
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    trackColor:
                                        WidgetStateProperty.resolveWith(
                                      (states) {
                                        return isActive
                                            ? AppColors.primary
                                            : AppColors.scaffoldBackground;
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Club Admins",
                    style: AppTextStyles.subHeading.copyWith(fontSize: 20.w),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: AppColors.flashyGreen,
                    ),
                    child: clubId.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(12.r),
                            child: Text(
                              "No admins available",
                              style: AppTextStyles.bodySmall,
                            ),
                          )
                        : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('clubId', isEqualTo: clubId)
                                .where('role', isEqualTo: 'club_admin')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: EdgeInsets.all(12.r),
                                  child: Center(
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                );
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.all(12.r),
                                  child: Text(
                                    "No admins available",
                                    style: AppTextStyles.bodySmall,
                                  ),
                                );
                              }
                              final admins = snapshot.data!.docs;
                              return ListView.separated(
                                separatorBuilder: (context, index) =>
                                    Divider(indent: 20, endIndent: 20),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: admins.length,
                                itemBuilder: (context, index) {
                                  final doc = admins[index];
                                  final data = doc.data();
                                  final name = (data['displayName'] ?? 'Admin')
                                      .toString();
                                  final email =
                                      (data['email'] ?? '').toString();
                                  final photoBase64 =
                                      (data['photoBase64'] ?? '').toString();
                                  final canEdit =
                                      isSuperAdmin || doc.id == currentUserId;
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: photoBase64.isNotEmpty
                                            ? MemoryImage(
                                                base64Decode(photoBase64),
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        name,
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                      subtitle: Text(email),
                                      trailing: canEdit
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                              onPressed: () {
                                                Get.toNamed(
                                                  Routes.ADMIN_VIEW,
                                                  arguments: {
                                                    'adminId': doc.id,
                                                    'name': name,
                                                    'email': email,
                                                    'clubId': clubId,
                                                    'clubName': nameOfClub,
                                                    'role': 'club_admin',
                                                    'photoBase64':
                                                        photoBase64,
                                                  },
                                                );
                                              },
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Club Information",
                    style: AppTextStyles.subHeading.copyWith(fontSize: 20.w),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: AppColors.flashyGreen,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("location",
                                      style: AppTextStyles.bodySmall),
                                  Text(
                                    clubLocation ?? "Unknown",
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Joined Date",
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd-MM-yyyy',
                                    ).format(DateTime.now()).toString(),
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Games",
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text("1,124",
                                      style: AppTextStyles.bodyMedium),
                                ],
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Player",
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text("225",
                                      style: AppTextStyles.bodyMedium),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isSuperAdmin) ...[
                    SizedBox(height: 16.h),
                    CustomElevatedButton(
                      icon: Icon(Icons.logout, color: AppColors.white),
                      onPressed: () {
                        Get.dialog(
                          Dialog(
                            insetPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.h),
                              decoration: BoxDecoration(
                                color: AppColors.flashyGreen,
                                border: Border.all(color: AppColors.darkBlue),
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
                                          backgroundColor:
                                              AppColors.flashyGreen,
                                          radius: 40.r,
                                          child: Icon(
                                            Icons.logout,
                                            color: AppColors.primary,
                                            size: 40,
                                          ),
                                        ),
                                        Text(
                                          "Confirm Logout",
                                          style: AppTextStyles.bodyMedium2
                                              .copyWith(
                                            color: AppColors.textBlack,
                                            fontSize: 22.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  CustomElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await FirebaseAuth.instance.signOut();
                                        Get.offAllNamed(Routes.SIGN_IN);
                                      } catch (_) {
                                        Get.snackbar(
                                          "Logout failed",
                                          "Please try again.",
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      }
                                    },
                                    btnName: "Log Out",
                                    backColor: AppColors.primary,
                                    textColor: AppColors.white,
                                    borderRadius: 15.r,
                                  ),
                                  SizedBox(height: 10.h),
                                  CustomElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    btnName: "Stay Logged In",
                                    backColor: AppColors.flashyGreen,
                                    textColor: AppColors.primary,
                                    borderColor: AppColors.primary,
                                    borderRadius: 15.r,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      btnName: "Logout",
                      backColor: AppColors.primary,
                    ),
                  ],
                  if (isSuperAdmin) ...[
                    SizedBox(height: 16.h),
                    Text(
                      "Actions",
                      style:
                          AppTextStyles.subHeading.copyWith(fontSize: 20.w),
                    ),
                    SizedBox(height: 16.h),
                    Column(
                      spacing: 10.5.h,
                      children: [
                        CustomElevatedButton(
                          icon: Icon(Icons.save, color: AppColors.white),
                          onPressed: () {},
                          btnName: "Save",
                          backColor: AppColors.primary,
                        ),
                        CustomElevatedButton(
                          icon: Icon(Icons.block, color: AppColors.white),
                          onPressed: controller.blockClub,
                          btnName: "Block Club",
                          backColor: AppColors.secondary,
                        ),
                        CustomElevatedButton(
                          icon: Icon(Icons.delete, color: AppColors.white),
                          onPressed: controller.removeClub,
                          btnName: "Remove Club",
                          backColor: AppColors.darkRed,
                        ),
                        CustomElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          btnName: "Cancel",
                          textColor: AppColors.primary,
                          backColor: Colors.transparent,
                          borderColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 20.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
