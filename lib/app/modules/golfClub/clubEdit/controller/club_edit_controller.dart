import 'package:bierdygame/app/modules/superAdmin/addClubs/controller/add_clubs_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class ClubEditController extends GetxController {
  ClubEditController({
    required this.clubId,
    required this.initialName,
    required this.initialLocation,
    required this.initialLogoPath,
    required this.initialLogoBase64,
  });

  final String? clubId;
  final String? initialName;
  final String? initialLocation;
  final String? initialLogoPath;
  final String? initialLogoBase64;

  final clubNameController = TextEditingController();
  final clubLocationController = TextEditingController();
  final adminNameController = TextEditingController();
  final adminEmailController = TextEditingController();
  final adminPasswordController = TextEditingController();

  final showAddAdminForm = false.obs;
  final isNewAdmin = true.obs;
  final adminCount = 0.obs;

  final RxnString logoName = RxnString();
  final RxnString logoPath = RxnString();
  final RxnString logoBase64 = RxnString();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    clubNameController.text = initialName ?? '';
    clubLocationController.text = initialLocation ?? '';
    logoPath.value = initialLogoPath;
    logoBase64.value = initialLogoBase64;
  }

  @override
  void onClose() {
    clubNameController.dispose();
    clubLocationController.dispose();
    adminNameController.dispose();
    adminEmailController.dispose();
    adminPasswordController.dispose();
    super.onClose();
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }
    logoPath.value = picked.path;
    logoName.value = picked.name;
    final bytes = await File(picked.path).readAsBytes();
    logoBase64.value = base64Encode(bytes);
  }

  Future<void> saveChanges() async {
    final id = clubId ?? '';
    if (id.isEmpty) {
      Get.snackbar("Error", "Missing club id");
      return;
    }
    final name = clubNameController.text.trim();
    final location = clubLocationController.text.trim();
    if (name.isEmpty || location.isEmpty) {
      Get.snackbar("Error", "Club name and location are required");
      return;
    }
    await _firestore.collection('clubs').doc(id).set({
      'name': name,
      'location': location,
      'logoPath': logoPath.value,
      'logoBase64': logoBase64.value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    Get.back();
    Get.snackbar("Updated", "Club details updated");
  }

  void showAddAdmin() {
    if (adminCount.value >= 5) {
      Get.snackbar("Note", "Only 5 Admins added");
      return;
    }
    showAddAdminForm.value = true;
  }

  Future<void> createAdmin() async {
    final id = clubId ?? '';
    if (id.isEmpty) {
      Get.snackbar("Error", "Missing club id");
      return;
    }
    if (!Get.isRegistered<AddClubsController>()) {
      Get.snackbar("Error", "Missing Add Clubs controller");
      return;
    }
    final controller = Get.find<AddClubsController>();
    if (isNewAdmin.value) {
      await controller.createClubAdmin(
        name: adminNameController.text.trim(),
        email: adminEmailController.text.trim().toLowerCase(),
        password: adminPasswordController.text.trim(),
        clubId: id,
        clubName: clubNameController.text.trim(),
      );
    } else {
      final existing = await controller.attachExistingClubAdminByEmail(
        email: adminEmailController.text.trim().toLowerCase(),
        clubId: id,
        clubName: clubNameController.text.trim(),
      );
      if (existing == null) {
        return;
      }
      adminNameController.text = existing.name;
    }
    adminNameController.clear();
    adminEmailController.clear();
    adminPasswordController.clear();
    showAddAdminForm.value = false;
  }

  Future<void> removeAdminFromClub(String uid) async {
    final id = clubId ?? '';
    if (id.isEmpty) return;
    if (!Get.isRegistered<AddClubsController>()) {
      Get.snackbar("Error", "Missing Add Clubs controller");
      return;
    }
    final controller = Get.find<AddClubsController>();
    await controller.removeAdminFromClub(uid: uid, clubId: id);
  }
}
