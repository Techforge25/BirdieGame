import 'dart:async';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageClubsController extends GetxController {
  RxInt selectedTab = 0.obs;
  RxInt selectedGameTab = 0.obs;
  RxInt selectedLeaderboardTab = 0.obs;
  RxInt gameDetailPage = 0.obs;
  Rxn<Map<String, dynamic>> selectedTeamDetail = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> selectedPlayerDetail = Rxn<Map<String, dynamic>>();
  Rx<String?> selectedClub = Rx<String?>(null);
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  RxList<GameModel> games = <GameModel>[].obs;
  final RxnString _clubId = RxnString();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _gamesSub;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  RxBool showGameDetail = false.obs;
  Rx<GameModel?> selectedGame = Rx<GameModel?>(null);

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim().toLowerCase();
    });
    _loadClubIdAndListen();
  }

  @override
  void onClose() {
    _gamesSub?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadClubIdAndListen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    _clubId.value = userDoc.data()?['clubId']?.toString();
    final clubId = _clubId.value;
    if (clubId == null || clubId.isEmpty) return;
    _gamesSub = _firestore
        .collection('games')
        .where('clubId', isEqualTo: clubId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      games.value = snapshot.docs
          .map((doc) => GameModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<String?> _ensureClubId() async {
    if (_clubId.value != null && _clubId.value!.isNotEmpty) {
      return _clubId.value;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    _clubId.value = userDoc.data()?['clubId']?.toString();
    return _clubId.value;
  }

  Future<void> createGame(
    GameModel game, {
    Map<String, dynamic>? clubGame,
  }) async {
    final clubId = await _ensureClubId();
    if (clubId == null || clubId.isEmpty) {
      Get.snackbar("Error", "Missing club id");
      return;
    }
    final gamePayload = {
      ...game.toMap(),
      'clubId': clubId,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (clubGame != null && clubGame['teams'] != null) {
      gamePayload['teams'] = clubGame['teams'];
    }
    final gameRef = await _firestore.collection('games').add(gamePayload);
    if (!games.any((g) => g.id == gameRef.id)) {
      games.insert(
        0,
        GameModel(
          id: gameRef.id,
          clubId: clubId,
          name: game.name,
          date: game.date,
          passkey: game.passkey,
          status: game.status,
        ),
      );
    }
    final payload = {
      if (clubGame != null) ...clubGame,
      'gameId': gameRef.id,
      'name': game.name,
      'date': game.date,
      'passkey': game.passkey,
      'status': game.status.name,
    };
    final payloadForArray = Map<String, dynamic>.from(payload);
    await _firestore.collection('clubs').doc(clubId).set({
      'game': {
        ...payload,
        'createdAt': FieldValue.serverTimestamp(),
      },
      'games': FieldValue.arrayUnion([payloadForArray]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void changeTab(int index) {
    selectedTab.value = index;
    selectedClub.value = null;
  }
void changeGameTab(int index) {
    selectedGameTab.value = index;
  }
  void changeLeaderboardTab(int index) {
    selectedLeaderboardTab.value = index;
  }

  void openTeamDetail(Map<String, dynamic> team) {
    selectedTeamDetail.value = team;
    gameDetailPage.value = 1;
  }

  void openPlayerDetail(Map<String, dynamic> player) {
    selectedPlayerDetail.value = player;
    gameDetailPage.value = 2;
  }

  void backToGameDetail() {
    gameDetailPage.value = 0;
    selectedTeamDetail.value = null;
    selectedPlayerDetail.value = null;
  }

  void backToTeamDetail() {
    gameDetailPage.value = 1;
    selectedPlayerDetail.value = null;
  }
  void addGame(GameModel game) {
    games.insert(0, game); // latest on top
  }

  Future<void> removeGame(GameModel game) async {
    if (game.id.isNotEmpty) {
      try {
        await _firestore.collection('games').doc(game.id).delete();
        games.removeWhere((g) => g.id == game.id);
        Get.snackbar("Removed", "Game removed successfully");
      } catch (e) {
        Get.snackbar("Error", "Failed to remove game");
        return;
      }
      final clubId = _clubId.value;
      if (clubId != null && clubId.isNotEmpty) {
        final clubRef = _firestore.collection('clubs').doc(clubId);
        final clubSnap = await clubRef.get();
        final clubData = clubSnap.data() ?? {};

        final gameField = clubData['game'];
        if (gameField is Map && gameField['gameId']?.toString() == game.id) {
          await clubRef.set({
            'game': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        final gamesField = clubData['games'];
        if (gamesField is List) {
          final updated = gamesField.where((entry) {
            if (entry is Map) {
              return entry['gameId']?.toString() != game.id;
            }
            return true;
          }).toList();
          if (updated.length != gamesField.length) {
            await clubRef.set({
              'games': updated,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
      }
    } else {
      games.remove(game);
    }
  }

  void openGame(GameModel game) {
    selectedGame.value = game;
    showGameDetail.value = true;
  }

  void backToGames() {
    showGameDetail.value = false;
    selectedGame.value = null;
  }

  List<GameModel> get filteredGames {
    final query = searchQuery.value;
    Iterable<GameModel> source = games;
    if (query.isNotEmpty) {
      source = source.where(
        (g) => g.name.toLowerCase().contains(query),
      );
    }
    switch (selectedTab.value) {
      case 1:
        return source.where((g) => g.status == GameStatus.active).toList();
      case 2:
        return source.where((g) => g.status == GameStatus.draft).toList();
      case 3:
        return source.where((g) => g.status == GameStatus.completed).toList();
      default:
        return source.toList();
    }
  }
}
