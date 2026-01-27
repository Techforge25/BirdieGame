import 'package:bierdygame/app/modules/superAdmin/manageAdmins/controller/manage_admin_controller.dart';
import 'package:bierdygame/app/modules/superAdmin/manageAdmins/widgets/admin_card.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_text_field.dart';
import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert';

class ManageAdmins extends GetView<ManageAdminsController> {
  const ManageAdmins({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.white,
        title: Text("Admins Information", style: AppTextStyles.miniHeadings),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: controller.searchController,
              prefixIcon: const Icon(Icons.search),
              hintText: "Search Admin...",
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.borderColor,
              ),
              borderSide: const BorderSide(width: 1),
              borderRadius: BorderRadius.circular(30.r),
            ),
            SizedBox(height: 15.h),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'club_admin')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No admins found"));
                  }
                  return Obx(() {
                    final query = controller.searchQuery.value;
                    final admins = snapshot.data!.docs.where((doc) {
                      final data = doc.data();
                      final name =
                          (data['displayName'] ?? '').toString().toLowerCase();
                      final email =
                          (data['email'] ?? '').toString().toLowerCase();
                      return query.isEmpty ||
                          name.contains(query) ||
                          email.contains(query);
                    }).toList();

                    if (admins.isEmpty) {
                      return Center(child: Text("No admins found"));
                    }

                    return ListView.separated(
                      itemCount: admins.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final data = admins[index].data();
                        final name = (data['displayName'] ?? 'Admin').toString();
                        final email = (data['email'] ?? '').toString();
                        final clubName = (data['clubName'] ?? '').toString();
                        final role = (data['role'] ?? '').toString();
                        final isActive = data['isActive'] == null
                            ? true
                            : data['isActive'] == true;
                        final photoBase64 =
                            (data['photoBase64'] ?? '').toString();
                        final avatarImage = photoBase64.isNotEmpty
                            ? MemoryImage(base64Decode(photoBase64))
                            : null;
                        return AdminCard(
                          name: name,
                          email: email,
                          clubName: clubName.isEmpty ? 'Unknown' : clubName,
                          role: role,
                          avatarImage: avatarImage,
                          onEdit: () {
                            Get.toNamed(
                              Routes.ADMIN_VIEW,
                              arguments: {
                                'adminId': admins[index].id,
                                'name': name,
                                'email': email,
                                'clubName': clubName,
                                'role': role,
                                'isActive': isActive,
                                'photoBase64': photoBase64,
                              },
                            );
                          },
                        );
                      },
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
