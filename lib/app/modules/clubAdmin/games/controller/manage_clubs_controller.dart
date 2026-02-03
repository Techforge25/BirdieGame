import 'dart:async';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  Timer? _statusTimer;
  Worker? _gamesWorker;
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
    _statusTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _activateDueDraftsFromList(),
    );
    _gamesWorker = ever<List<GameModel>>(
      games,
      (_) => _activateDueDraftsFromList(),
    );
  }

  @override
  void onClose() {
    _gamesSub?.cancel();
    _statusTimer?.cancel();
    _gamesWorker?.dispose();
    super.onClose();
  }

  Future<void> _loadClubIdAndListen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    _clubId.value = userDoc.data()?['clubId']?.toString();
    final clubId = _clubId.value;
    if (clubId == null || clubId.isEmpty) return;
    _gamesSub = _firestore
        .collection('games')
        .where('clubId', isEqualTo: clubId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final docs = snapshot.docs;
          games.value = docs
              .map((doc) => GameModel.fromMap(doc.id, doc.data()))
              .toList();
          _autoActivateScheduledGames(docs);
        });
  }

  Future<void> _autoActivateScheduledGames(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final now = DateTime.now();
    for (final doc in docs) {
      final data = doc.data();
      final status = (data['status'] ?? '').toString();
      if (status != GameStatus.draft.name) {
        continue;
      }
      DateTime? scheduledAt;
      final scheduledRaw = data['scheduledAt'];
      if (scheduledRaw is Timestamp) {
        scheduledAt = scheduledRaw.toDate();
      } else {
        final dateStr = (data['date'] ?? '').toString();
        final timeStr = (data['time'] ?? '').toString();
        if (dateStr.isNotEmpty) {
          try {
            final date = DateFormat('yyyy-MM-dd').parse(dateStr);
            if (timeStr.isNotEmpty) {
              final time = DateFormat('hh:mm a').parse(timeStr);
              scheduledAt = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            } else {
              scheduledAt = date;
            }
          } catch (_) {
            scheduledAt = null;
          }
        }
      }
      if (scheduledAt != null && !scheduledAt.isAfter(now)) {
        await _firestore.collection('games').doc(doc.id).set({
          'status': GameStatus.active.name,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> _activateDueDraftsFromList() async {
    if (games.isEmpty) return;
    final now = DateTime.now();
    final dueGames = <GameModel>[];
    for (final game in games) {
      if (game.status != GameStatus.draft) continue;
      final scheduledAt = _resolveScheduledAt(game);
      if (scheduledAt != null && !scheduledAt.isAfter(now)) {
        dueGames.add(game);
      }
    }
    if (dueGames.isEmpty) return;
    for (final game in dueGames) {
      if (game.id.isEmpty) continue;
      await _firestore.collection('games').doc(game.id).set({
        'status': GameStatus.active.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _setGameStatusLocal(game.id, GameStatus.active);
    }
  }

  DateTime? _resolveScheduledAt(GameModel game) {
    if (game.date.isEmpty) return null;
    try {
      final date = DateFormat('yyyy-MM-dd').parse(game.date);
      if (game.time.isNotEmpty) {
        final time = DateFormat('hh:mm a').parse(game.time);
        return DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  void _setGameStatusLocal(String id, GameStatus status) {
    final idx = games.indexWhere((g) => g.id == id);
    if (idx < 0) return;
    final g = games[idx];
    games[idx] = GameModel(
      id: g.id,
      clubId: g.clubId,
      name: g.name,
      date: g.date,
      time: g.time,
      passkey: g.passkey,
      status: status,
      currentHole: g.currentHole,
      totalHoles: g.totalHoles,
      par: g.par,
      totalTeams: g.totalTeams,
      totalPlayers: g.totalPlayers,
      birdiedTeams: g.birdiedTeams,
      matchProgress: g.matchProgress,
      teams: g.teams,
    );
    games.refresh();
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
    if (clubGame != null && clubGame['scheduledAt'] != null) {
      gamePayload['scheduledAt'] = clubGame['scheduledAt'];
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
          time: game.time,
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
      'time': game.time,
      'passkey': game.passkey,
      'status': game.status.name,
    };
    final payloadForArray = Map<String, dynamic>.from(payload);
    await _firestore.collection('clubs').doc(clubId).set({
      'game': {...payload, 'createdAt': FieldValue.serverTimestamp()},
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
      source = source.where((g) => g.name.toLowerCase().contains(query));
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
