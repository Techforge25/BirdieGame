import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuperAdminClubManagementController extends GetxController {
  RxInt selectedTab = 0.obs;
  Rx<String?> selectedClub = Rx<String?>(null);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim().toLowerCase();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTab.value = index;
     selectedClub.value = null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> clubsStream() {
    return _firestore
        .collection('clubs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> toggleClubStatus(String docId, String currentStatus) async {
    final nextStatus = currentStatus == 'active' ? 'blocked' : 'active';
    await _firestore.collection('clubs').doc(docId).set({
      'status': nextStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
