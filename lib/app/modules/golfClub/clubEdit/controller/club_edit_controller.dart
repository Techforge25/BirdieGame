import 'package:bierdygame/app/modules/superAdmin/addClubs/controller/add_clubs_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
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
  final RxnString adminPhotoName = RxnString();
  final RxnString adminPhotoPath = RxnString();
  final RxnString adminPhotoBase64 = RxnString();

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
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      logoBase64.value = base64Encode(bytes);
      return;
    }
    final resized = img.copyResize(
      decoded,
      width: decoded.width > 600 ? 600 : decoded.width,
    );
    final jpgBytes = img.encodeJpg(resized, quality: 70);
    logoBase64.value = base64Encode(jpgBytes);
  }

  Future<void> pickAdminPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }
    adminPhotoPath.value = picked.path;
    adminPhotoName.value = picked.name;
    final bytes = await File(picked.path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      adminPhotoBase64.value = base64Encode(bytes);
      return;
    }
    final resized = img.copyResize(
      decoded,
      width: decoded.width > 300 ? 300 : decoded.width,
    );
    final jpgBytes = img.encodeJpg(resized, quality: 70);
    adminPhotoBase64.value = base64Encode(jpgBytes);
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
    final base64Logo = logoBase64.value ?? '';
    if (base64Logo.isNotEmpty && base64Logo.length > 700000) {
      Get.snackbar("Image too large", "Please pick a smaller image");
      return;
    }
    await _firestore.collection('clubs').doc(id).set({
      'name': name,
      'location': location,
      'logoPath': logoPath.value,
      'logoBase64': base64Logo,
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
      final photoBase64 = adminPhotoBase64.value ?? '';
      if (photoBase64.isNotEmpty && photoBase64.length > 700000) {
        Get.snackbar("Image too large", "Please pick a smaller image");
        return;
      }
      await controller.createClubAdmin(
        name: adminNameController.text.trim(),
        email: adminEmailController.text.trim().toLowerCase(),
        password: adminPasswordController.text.trim(),
        clubId: id,
        clubName: clubNameController.text.trim(),
        photoBase64: photoBase64,
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
    adminPhotoName.value = null;
    adminPhotoPath.value = null;
    adminPhotoBase64.value = null;
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
