import 'package:bierdygame/app/modules/player/playerJoinGame/view/game_board.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerJoinGameController extends GetxController {
  var currentIndex = 0.obs;
  final passkeyController = TextEditingController();
  final Rxn<Map<String, dynamic>> currentGame = Rxn<Map<String, dynamic>>();
  final RxnString currentGameId = RxnString();
  final RxInt playersPerTeam = 0.obs;

  final List<Widget> screens = [
    GameBoardView(),
  ];

  void changeTab(int index) {
    if (index >= 0 && index < screens.length) {
      currentIndex.value = index;
    }
  }

  @override
  void onClose() {
    passkeyController.dispose();
    super.onClose();
  }

  Future<bool> findGameByPasskey() async {
    final passkey = passkeyController.text.trim().toUpperCase();
    if (passkey.isEmpty) {
      Get.snackbar("Error", "Please enter a passkey");
      return false;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return false;
    }
    final gameQuery = await FirebaseFirestore.instance
        .collection('games')
        .where('passkey', isEqualTo: passkey)
        .limit(1)
        .get();
    if (gameQuery.docs.isEmpty) {
      Get.snackbar("Invalid Passkey", "Game not found");
      return false;
    }
    final gameDoc = gameQuery.docs.first;
    final data = gameDoc.data();
    final teams = data['teams'];
    if (teams is! List) {
      Get.snackbar("Error", "Game teams not available");
      return false;
    }
    currentGame.value = data;
    currentGameId.value = gameDoc.id;
    playersPerTeam.value = (data['playersPerTeam'] ?? 4) as int? ?? 4;
    return true;
  }

  Future<void> joinSelectedTeam(int teamIndex) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }
    final gameId = currentGameId.value ?? '';
    if (gameId.isEmpty) {
      Get.snackbar("Error", "Game not found");
      return;
    }
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userSnap.data() ?? {};
    final displayName =
        (userData['displayName'] ?? userData['name'] ?? '').toString();
    final email = (userData['email'] ?? '').toString();
    final gameDoc = await FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .get();
    final data = gameDoc.data();
    if (data == null) {
      Get.snackbar("Error", "Game not available");
      return;
    }
    final teams = data['teams'];
    if (teams is! List) {
      Get.snackbar("Error", "Teams not available");
      return;
    }
    final updatedTeams = List<Map<String, dynamic>>.from(
      teams.map((t) => Map<String, dynamic>.from(t)),
    );
    bool alreadyJoined = false;
    for (final team in updatedTeams) {
      final members = team['members'];
      if (members is List) {
        if (members.any((m) => m is Map && m['uid'] == user.uid)) {
          alreadyJoined = true;
          break;
        }
      }
    }
    if (alreadyJoined) {
      Get.snackbar("Already Joined", "You are already in this game");
      return;
    }
    if (teamIndex < 0 || teamIndex >= updatedTeams.length) {
      Get.snackbar("Error", "Invalid team");
      return;
    }
    final members = updatedTeams[teamIndex]['members'];
    final memberList = members is List
        ? List<Map<String, dynamic>>.from(members)
        : <Map<String, dynamic>>[];
    if (memberList.length >= playersPerTeam.value) {
      Get.snackbar("Teams Full", "Selected team is full");
      return;
    }
    memberList.add({
      'uid': user.uid,
      'name': displayName.isEmpty ? email : displayName,
      'email': email,
    });
    updatedTeams[teamIndex]['members'] = memberList;
    await FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .set({
          'teams': updatedTeams,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    Get.snackbar("Joined", "You have joined the game");
    Get.to(() => GameBoardView());
  }
}
