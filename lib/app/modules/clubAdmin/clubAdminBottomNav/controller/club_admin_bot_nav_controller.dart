import 'dart:async';

import 'package:bierdygame/app/modules/clubAdmin/dashboard/view/dashboard_view.dart';
import 'package:bierdygame/app/modules/clubAdmin/reportsAndAnalytics/view/club_admin_reports_and_analytics_view.dart';
import 'package:bierdygame/app/modules/clubAdmin/games/view/manage_games.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/view/new_game_view.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/controller/new_game_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/scores/view/scores_view.dart';
import 'package:bierdygame/app/modules/golfClub/golfClubProfile/golf_club_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClubAdminBottomNavController extends GetxController {
  
  var currentIndex = 0.obs;
  var bottomNavIndex = 0.obs;
  final showReportsFromDashboard = false.obs;
  final isClubBlocked = false.obs;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _clubSubscription;
  final RxnString _clubId = RxnString();
  final RxnString _clubName = RxnString();

  List<Widget> get screens => [
        showReportsFromDashboard.value
            ? ClubAdminReportsAndAnalyticsView(
                onBackToDashboard: closeReportsFromDashboard,
              )
            : const ClubAdminDashboard(),
        ManageClubsGames(),
        NewGameView(),
        ScoresView(),
        GolfClubProfilePage(
          clubId: _clubId.value ?? '',
          nameOfClub: _clubName.value ?? '',
        ),
      ];

  String get clubId => _clubId.value ?? '';
  String get clubName => _clubName.value ?? '';
  
  @override
  void onInit() {
    super.onInit();
    _loadClubStatus();
  }

  @override
  void onClose() {
    _clubSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadClubStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data();
    _clubId.value = data?['clubId'] as String?;
    _clubName.value = data?['clubName']?.toString();
    final clubId = _clubId.value;
    if (clubId == null || clubId.isEmpty) return;
    _clubSubscription = FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubId)
        .snapshots()
        .listen((snapshot) {
      final status = (snapshot.data()?['status'] ?? 'active').toString();
      isClubBlocked.value = status != 'active';
      final clubName = snapshot.data()?['name']?.toString();
      if (clubName != null && clubName.isNotEmpty) {
        _clubName.value = clubName;
      }
    });
  }

  void changeTab(int index) {
    if (index >= 0 && index < screens.length) {
      if (index != 0 && showReportsFromDashboard.value) {
        showReportsFromDashboard.value = false;
      }
      if (currentIndex.value == 2 && index != 2) {
        final newGame = Get.isRegistered<NewGameController>()
            ? Get.find<NewGameController>()
            : null;
        newGame?.saveDraftIfNeeded();
      }
      currentIndex.value = index;
      bottomNavIndex.value = index;
    }
  }

  void openReportsFromDashboard() {
    showReportsFromDashboard.value = true;
    changeTab(0);
  }

  void closeReportsFromDashboard() {
    showReportsFromDashboard.value = false;
    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      bottomNavIndex.value = 0;
    }
  }

  bool guardClubAccess() {
    if (isClubBlocked.value) {
      Get.snackbar("Blocked", "Your club is blocked");
      return false;
    }
    return true;
  }
}
 
