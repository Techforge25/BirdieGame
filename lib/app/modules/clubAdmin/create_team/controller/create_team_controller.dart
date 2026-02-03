import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:io';

class CreateTeamController extends GetxController {
  final showCreateForm = false.obs;
  final showRosterForm = false.obs;
  final rosterReady = false.obs;
  final selectedCaptainIndex = 0.obs;
  final teamNameController = TextEditingController();
  final rosterTeamNameController = TextEditingController();
  final selectedEmojiIndex = (-1).obs;
  final RxnString rosterTeamId = RxnString();
  final RxnString teamLogoPath = RxnString();
  final RxnString teamLogoBase64 = RxnString();
  final RxnString teamLogoName = RxnString();
  bool teamSetupInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _migrateClubTeamsCollection();
  }

  final teams = <TeamPreview>[].obs;
  final rosterPlayers = <PlayerPreview>[].obs;
  final editingIndex = RxnInt();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void openCreateForm() {
    showCreateForm.value = true;
    showRosterForm.value = false;
  }

  void closeCreateForm() {
    showCreateForm.value = false;
  }

  Future<void> openRosterForm() async {
    rosterTeamNameController.text = teamNameController.text.trim();
    rosterPlayers.clear();
    rosterReady.value = false;
    rosterTeamId.value = null;
    showRosterForm.value = true;
    showCreateForm.value = false;
  }

  void closeRosterForm() {
    showRosterForm.value = false;
    showCreateForm.value = true;
  }

  void selectCaptain(int index) {
    selectedCaptainIndex.value = index;
  }

  Future<void> saveTeamSetup() async {
    final name = rosterTeamNameController.text.trim().isEmpty
        ? 'Team'
        : rosterTeamNameController.text.trim();
    final initials = rosterPlayers.map((p) => p.initials).toList();
    final captainEmail =
        (rosterPlayers.isNotEmpty &&
            selectedCaptainIndex.value >= 0 &&
            selectedCaptainIndex.value < rosterPlayers.length)
        ? rosterPlayers[selectedCaptainIndex.value].email
        : '';
    await _ensureRosterTeamDoc();
    final teamId = rosterTeamId.value ?? '';
    if (teamId.isNotEmpty) {
      await _updateTeamDoc(
        teamId: teamId,
        name: name,
        emojiIndex: selectedEmojiIndex.value,
        captainEmail: captainEmail,
        logoBase64: teamLogoBase64.value ?? '',
        logoPath: teamLogoPath.value ?? '',
      );
      await _upsertGlobalTeamDoc(
        teamId: teamId,
        name: name,
        captainEmail: captainEmail,
        logoBase64: teamLogoBase64.value ?? '',
        logoPath: teamLogoPath.value ?? '',
      );
    }
    final team = TeamPreview(
      id: teamId,
      name: name,
      playersCount: initials.length,
      maxPlayers: 4,
      playerInitials: initials,
      players: rosterPlayers.toList(),
      emojiIndex: selectedEmojiIndex.value,
      captainEmail: captainEmail,
      selectedEmails: rosterPlayers.map((p) => p.email).toList(),
    );
    int replaceIndex = -1;
    if (teamId.isNotEmpty) {
      replaceIndex = teams.indexWhere((t) => t.id == teamId);
    }
    if (replaceIndex < 0 &&
        editingIndex.value != null &&
        editingIndex.value! >= 0 &&
        editingIndex.value! < teams.length) {
      replaceIndex = editingIndex.value!;
    }
    if (replaceIndex >= 0) {
      teams[replaceIndex] = team;
    } else {
      teams.add(team);
    }
    showRosterForm.value = false;
    showCreateForm.value = false;
    rosterReady.value = false;
    selectedCaptainIndex.value = 0;
    selectedEmojiIndex.value = -1;
    teamNameController.clear();
    rosterTeamNameController.clear();
    rosterPlayers.clear();
    rosterTeamId.value = null;
    editingIndex.value = null;
    teamLogoPath.value = null;
    teamLogoBase64.value = null;
    teamLogoName.value = null;
  }

  void openEditTeam(int index) {
    if (index < 0 || index >= teams.length) return;
    final team = teams[index];
    editingIndex.value = index;
    rosterTeamId.value = team.id;
    rosterTeamNameController.text = team.name;
    selectedCaptainIndex.value = 0;
    rosterPlayers.assignAll(team.players);
    if (team.captainEmail.isNotEmpty) {
      final idx = team.players.indexWhere(
        (p) => p.email.toLowerCase() == team.captainEmail.toLowerCase(),
      );
      if (idx >= 0) {
        selectedCaptainIndex.value = idx;
      }
    }
    rosterReady.value = rosterPlayers.isNotEmpty;
    showRosterForm.value = true;
    showCreateForm.value = false;
  }

  void openEditTeamFromFirestore({
    required String teamId,
    required Map<String, dynamic> data,
  }) {
    final name = (data['name'] ?? 'Team').toString();
    final emojiIndex = (data['emojiIndex'] ?? -1) as int? ?? -1;
    final captainEmail = (data['captainEmail'] ?? '').toString();
    final logoBase64 = (data['logoBase64'] ?? data['logo'] ?? '').toString();
    final logoPath = (data['logoPath'] ?? '').toString();
    final members = data['members'];
    final players = <PlayerPreview>[];
    if (members is List) {
      for (final member in members) {
        if (member is Map<String, dynamic>) {
          final mName = (member['name'] ?? '').toString();
          final email = (member['email'] ?? '').toString();
          final uid = (member['uid'] ?? '').toString();
          players.add(
            PlayerPreview(
              uid: uid,
              name: mName.isEmpty ? email : mName,
              email: email,
            ),
          );
        }
      }
    }
    editingIndex.value = null;
    rosterTeamId.value = teamId;
    rosterTeamNameController.text = name;
    selectedEmojiIndex.value = emojiIndex;
    selectedCaptainIndex.value = 0;
    rosterPlayers.assignAll(players);
    teamLogoBase64.value = logoBase64.isNotEmpty ? logoBase64 : null;
    teamLogoPath.value = logoPath.isNotEmpty ? logoPath : null;
    if (captainEmail.isNotEmpty) {
      final idx = players.indexWhere(
        (p) => p.email.toLowerCase() == captainEmail.toLowerCase(),
      );
      if (idx >= 0) {
        selectedCaptainIndex.value = idx;
      }
    }
    rosterReady.value = rosterPlayers.isNotEmpty;
    showRosterForm.value = true;
    showCreateForm.value = false;
  }

  void prepareEditTeamFromFirestore({
    required String teamId,
    required Map<String, dynamic> data,
  }) {
    final name = (data['name'] ?? 'Team').toString();
    final emojiIndex = (data['emojiIndex'] ?? -1) as int? ?? -1;
    final captainEmail = (data['captainEmail'] ?? '').toString();
    final logoBase64 = (data['logoBase64'] ?? data['logo'] ?? '').toString();
    final logoPath = (data['logoPath'] ?? '').toString();
    final members = data['members'];
    final players = <PlayerPreview>[];
    if (members is List) {
      for (final member in members) {
        if (member is Map<String, dynamic>) {
          final mName = (member['name'] ?? '').toString();
          final email = (member['email'] ?? '').toString();
          final uid = (member['uid'] ?? '').toString();
          players.add(
            PlayerPreview(
              uid: uid,
              name: mName.isEmpty ? email : mName,
              email: email,
            ),
          );
        }
      }
    }
    editingIndex.value = null;
    rosterTeamId.value = teamId;
    rosterTeamNameController.text = name;
    selectedEmojiIndex.value = emojiIndex;
    selectedCaptainIndex.value = 0;
    rosterPlayers.assignAll(players);
    teamLogoBase64.value = logoBase64.isNotEmpty ? logoBase64 : null;
    teamLogoPath.value = logoPath.isNotEmpty ? logoPath : null;
    if (captainEmail.isNotEmpty) {
      final idx = players.indexWhere(
        (p) => p.email.toLowerCase() == captainEmail.toLowerCase(),
      );
      if (idx >= 0) {
        selectedCaptainIndex.value = idx;
      }
    }
    rosterReady.value = rosterPlayers.isNotEmpty;
  }

  void addTeamFromFirestore({
    required String teamId,
    required Map<String, dynamic> data,
  }) {
    final exists = teams.any((team) => team.id == teamId);
    if (exists) return;
    final name = (data['name'] ?? 'Team').toString();
    final emojiIndex = (data['emojiIndex'] ?? -1) as int? ?? -1;
    final captainEmail = (data['captainEmail'] ?? '').toString();
    final members = data['members'];
    final players = <PlayerPreview>[];
    if (members is List) {
      for (final member in members) {
        if (member is Map<String, dynamic>) {
          final mName = (member['name'] ?? '').toString();
          final email = (member['email'] ?? '').toString();
          final uid = (member['uid'] ?? '').toString();
          players.add(
            PlayerPreview(
              uid: uid,
              name: mName.isEmpty ? email : mName,
              email: email,
            ),
          );
        }
      }
    }
    final initials = players.map((p) => p.initials).toList();
    final selectedEmails = players.map((p) => p.email).toList();
    teams.add(
      TeamPreview(
        id: teamId,
        name: name,
        playersCount: players.length,
        maxPlayers: 4,
        playerInitials: initials,
        players: players,
        emojiIndex: emojiIndex,
        captainEmail: captainEmail,
        selectedEmails: selectedEmails,
      ),
    );
  }

  Future<void> deleteTeam(int index) async {
    if (index < 0 || index >= teams.length) return;
    final team = teams[index];
    final teamId = team.id;
    if (teamId.isNotEmpty) {
      final clubId = await _loadClubId();
      if (clubId != null && clubId.isNotEmpty) {
        await _firestore
            .collection('clubs')
            .doc(clubId)
            .collection('club_teams')
            .doc(teamId)
            .delete();
      }
      await _firestore.collection('teams').doc(teamId).delete();
    }
    teams.removeAt(index);
  }

  void removeRosterPlayer(int index) {
    if (index < 0 || index >= rosterPlayers.length) return;
    rosterPlayers.removeAt(index);
    rosterReady.value = rosterPlayers.isNotEmpty;
  }

  Future<void> removeRosterPlayerFromTeam(int index) async {
    if (index < 0 || index >= rosterPlayers.length) return;
    final player = rosterPlayers[index];
    rosterPlayers.removeAt(index);
    rosterReady.value = rosterPlayers.isNotEmpty;
    final teamId = rosterTeamId.value;
    final clubId = await _loadClubId();
    if (teamId == null || teamId.isEmpty || clubId == null || clubId.isEmpty) {
      return;
    }
    final memberPayload = {
      'uid': player.uid,
      'name': player.name,
      'email': player.email,
    };
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('club_teams')
        .doc(teamId)
        .set({
          'members': FieldValue.arrayRemove([memberPayload]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    await _firestore.collection('teams').doc(teamId).set({
      'members': FieldValue.arrayRemove([memberPayload]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void selectEmoji(int index) {
    selectedEmojiIndex.value = index;
  }

  void clearTeams() {
    teams.clear();
    editingIndex.value = null;
    rosterTeamId.value = null;
    rosterPlayers.clear();
    rosterReady.value = false;
    selectedCaptainIndex.value = 0;
    selectedEmojiIndex.value = -1;
    teamNameController.clear();
    rosterTeamNameController.clear();
    teamLogoPath.value = null;
    teamLogoBase64.value = null;
    teamLogoName.value = null;
    teamSetupInitialized = false;
  }

  void initTeamSetupSelection() {
    if (teamSetupInitialized) {
      return;
    }
    clearTeams();
    teamSetupInitialized = true;
  }

  Future<void> _migrateClubTeamsCollection() async {
    final clubId = await _loadClubId();
    if (clubId == null || clubId.isEmpty) return;
    final oldRef = _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('teams');
    final newRef = _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('club_teams');
    final oldSnap = await oldRef.get();
    if (oldSnap.docs.isEmpty) return;
    for (final doc in oldSnap.docs) {
      await newRef.doc(doc.id).set(doc.data(), SetOptions(merge: true));
      await oldRef.doc(doc.id).delete();
    }
  }

  void setTeamSelectedEmails(String teamId, List<String> emails) {
    final idx = teams.indexWhere((t) => t.id == teamId);
    if (idx < 0) return;
    final team = teams[idx];
    teams[idx] = TeamPreview(
      id: team.id,
      name: team.name,
      playersCount: team.playersCount,
      maxPlayers: team.maxPlayers,
      playerInitials: team.playerInitials,
      players: team.players,
      emojiIndex: team.emojiIndex,
      captainEmail: team.captainEmail,
      selectedEmails: emails,
    );
  }

  void updateTeamPlayers(
    String teamId,
    List<PlayerPreview> players, {
    List<String>? selectedEmails,
  }) {
    final idx = teams.indexWhere((t) => t.id == teamId);
    if (idx < 0) return;
    final team = teams[idx];
    teams[idx] = TeamPreview(
      id: team.id,
      name: team.name,
      playersCount: players.length,
      maxPlayers: team.maxPlayers,
      playerInitials: players.map((p) => p.initials).toList(),
      players: players,
      emojiIndex: team.emojiIndex,
      captainEmail: team.captainEmail,
      selectedEmails: selectedEmails ?? team.selectedEmails,
    );
  }

  Future<void> addPlayersToTeamFromDialog({
    required String teamId,
    required List<PlayerPreview> currentPlayers,
    required List<String> emails,
    required int limit,
    required List<String> currentSelectedEmails,
  }) async {
    if (emails.isEmpty) return;
    rosterTeamId.value = teamId;
    rosterPlayers.assignAll(currentPlayers);
    await addRosterPlayersFromDialog(emails);
    final updatedPlayers = rosterPlayers.toList();
    final selectedSet = <String>{};
    if (currentSelectedEmails.isNotEmpty) {
      selectedSet.addAll(currentSelectedEmails);
    } else {
      selectedSet.addAll(currentPlayers.map((p) => p.email));
    }
    for (final player in updatedPlayers) {
      if (selectedSet.length >= limit) break;
      selectedSet.add(player.email);
    }
    updateTeamPlayers(
      teamId,
      updatedPlayers,
      selectedEmails: selectedSet.toList(),
    );
  }

  @override
  void onClose() {
    teamNameController.dispose();
    rosterTeamNameController.dispose();
    super.onClose();
  }

  Future<void> addRosterPlayersFromDialog(List<String> rawEmails) async {
    final emails = rawEmails
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (emails.isEmpty) {
      Get.snackbar("Missing email", "Please enter at least one email");
      return;
    }
    await _ensureRosterTeamDoc();
    final clubId = await _loadClubId();
    final teamId = rosterTeamId.value;
    if (clubId == null || clubId.isEmpty || teamId == null || teamId.isEmpty) {
      Get.snackbar("Error", "Unable to create team roster");
      return;
    }

    bool showedMissingEmail = false;
    for (final email in emails) {
      final alreadyAdded = rosterPlayers.any(
        (player) => player.email.toLowerCase() == email,
      );
      if (alreadyAdded) {
        continue;
      }
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        if (!showedMissingEmail) {
          Get.snackbar(
            "Email does not exist",
            "Player must be registered in the app",
          );
          showedMissingEmail = true;
        }
        continue;
      }
      final doc = snapshot.docs.first;
      final data = doc.data();
      final name = (data['displayName'] ?? data['name'] ?? '').toString();
      rosterPlayers.add(
        PlayerPreview(
          uid: doc.id,
          name: name.isEmpty ? email : name,
          email: email,
        ),
      );
      await _firestore
          .collection('clubs')
          .doc(clubId)
          .collection('club_teams')
          .doc(teamId)
          .set({
            'members': FieldValue.arrayUnion([
              {'uid': doc.id, 'name': name, 'email': email},
            ]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      await _firestore.collection('teams').doc(teamId).set({
        'members': FieldValue.arrayUnion([
          {'uid': doc.id, 'name': name, 'email': email},
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    rosterReady.value = rosterPlayers.isNotEmpty;
  }

  Future<void> pickTeamLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }
    teamLogoPath.value = picked.path;
    teamLogoName.value = picked.name;
    final bytes = await File(picked.path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      teamLogoBase64.value = base64Encode(bytes);
      return;
    }
    final resized = img.copyResize(
      decoded,
      width: decoded.width > 300 ? 300 : decoded.width,
    );
    final jpgBytes = img.encodeJpg(resized, quality: 70);
    teamLogoBase64.value = base64Encode(jpgBytes);
  }

  Future<void> _ensureRosterTeamDoc() async {
    if (rosterTeamId.value != null && rosterTeamId.value!.isNotEmpty) {
      return;
    }
    final clubId = await _loadClubId();
    if (clubId == null || clubId.isEmpty) return;
    final name = rosterTeamNameController.text.trim().isEmpty
        ? 'Team'
        : rosterTeamNameController.text.trim();
    final ref = await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('club_teams')
        .add({
          'name': name,
          'emojiIndex': selectedEmojiIndex.value,
          'logoBase64': teamLogoBase64.value ?? '',
          'logo': teamLogoBase64.value ?? '',
          'logoPath': teamLogoPath.value ?? '',
          'members': <Map<String, dynamic>>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
    rosterTeamId.value = ref.id;
    await _firestore.collection('teams').doc(ref.id).set({
      'clubId': clubId,
      'name': name,
      'emojiIndex': selectedEmojiIndex.value,
      'logoBase64': teamLogoBase64.value ?? '',
      'logo': teamLogoBase64.value ?? '',
      'logoPath': teamLogoPath.value ?? '',
      'members': <Map<String, dynamic>>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateTeamDoc({
    required String teamId,
    required String name,
    required int emojiIndex,
    required String captainEmail,
    required String logoBase64,
    required String logoPath,
  }) async {
    final clubId = await _loadClubId();
    if (clubId == null || clubId.isEmpty) return;
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('club_teams')
        .doc(teamId)
        .set({
          'name': name,
          'emojiIndex': emojiIndex,
          'captainEmail': captainEmail,
          'logoBase64': logoBase64,
          'logo': logoBase64,
          'logoPath': logoPath,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> _upsertGlobalTeamDoc({
    required String teamId,
    required String name,
    required String captainEmail,
    required String logoBase64,
    required String logoPath,
  }) async {
    final clubId = await _loadClubId();
    if (clubId == null || clubId.isEmpty) return;
    await _firestore.collection('teams').doc(teamId).set({
      'clubId': clubId,
      'name': name,
      'emojiIndex': selectedEmojiIndex.value,
      'captainEmail': captainEmail,
      'logoBase64': logoBase64,
      'logo': logoBase64,
      'logoPath': logoPath,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> _loadClubId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['clubId']?.toString();
  }
}

class TeamPreview {
  final String id;
  final String name;
  final int playersCount;
  final int maxPlayers;
  final List<String> playerInitials;
  final List<PlayerPreview> players;
  final int emojiIndex;
  final String captainEmail;
  final List<String>? selectedEmails;

  const TeamPreview({
    required this.id,
    required this.name,
    required this.playersCount,
    required this.maxPlayers,
    required this.playerInitials,
    required this.players,
    required this.emojiIndex,
    this.captainEmail = '',
    this.selectedEmails,
  });
}

class PlayerPreview {
  final String uid;
  final String name;
  final String email;

  const PlayerPreview({required this.name, required this.email, this.uid = ''});

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.characters.take(1).toString().toUpperCase();
    }
    final first = parts.first.characters.take(1).toString().toUpperCase();
    final last = parts.last.characters.take(1).toString().toUpperCase();
    return '$first$last';
  }
}
