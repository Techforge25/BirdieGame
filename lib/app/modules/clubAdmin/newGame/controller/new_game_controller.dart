import 'dart:math';

import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/create_team/controller/create_team_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewGameController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rulesController = TextEditingController();
  final List<TextEditingController> teamNameControllers = [];
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> selectedTime = Rxn<TimeOfDay>();

  int teams = 4;
  int playersPerTeam = 2;

  bool showTeams = false;
  List<TeamModel> generatedTeams = [];
  List<List<TeamPlayer>> teamPlayers = [];
  String? _draftGameId;
  bool isEditingDraft = false;
  bool _isSubmitting = false;

  @override
  void onClose() {
    nameController.dispose();
    rulesController.dispose();
    for (final controller in teamNameControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  void incrementTeams() {
    if (teams < 8) {
      teams++;
      update();
    }
  }

  void decrementTeams() {
    if (teams > 2) {
      teams--;
      update();
    }
  }

  void incrementPlayersPerTeam() {
    if (playersPerTeam < 4) {
      playersPerTeam++;
      update();
    }
  }

  void decrementPlayersPerTeam() {
    if (playersPerTeam > 2) {
      playersPerTeam--;
      update();
    }
  }

  String get formattedDate {
    final date = selectedDate.value;
    if (date == null) return 'Select Date';
    return DateFormat('MM/dd/yy').format(date);
  }

  String get formattedTime {
    final time = selectedTime.value;
    if (time == null) return 'Select Time';
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('hh:mm a').format(dateTime);
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(surface: AppColors.white),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppColors.white),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
      update();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(dialogBackgroundColor: AppColors.white),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      selectedTime.value = picked;
      update();
    }
  }

  void generateTeams() {
    final nav = Get.find<ClubAdminBottomNavController>();
    if (!nav.guardClubAccess()) return;
    if (nameController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter a game name first",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    generatedTeams = [];
    for (final controller in teamNameControllers) {
      controller.dispose();
    }
    teamNameControllers.clear();
    teamPlayers = [];
    showTeams = false;
    update();
  }

  void confirmCreateGame({VoidCallback? onSuccess}) {
    final nav = Get.find<ClubAdminBottomNavController>();
    if (!nav.guardClubAccess()) return;
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.flashyGreen,
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.flashyGreen,
                radius: 40,
                child: Icon(Icons.check, color: AppColors.primary, size: 40),
              ),
              SizedBox(height: 10),
              Text(
                "Confirm Game Creation",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                "Are you sure you want to create game\n\n"
                "${nameController.text}\n"
                "with $teams teams?",
                style: TextStyle(color: AppColors.textBlack),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  createGame().then((_) {
                    onSuccess?.call();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Create Game",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: Get.back,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createGame() async {
    final nav = Get.find<ClubAdminBottomNavController>();
    if (!nav.guardClubAccess()) return;
    _isSubmitting = true;
    try {
      final now = DateTime.now();
      final dateValue = selectedDate.value ?? now;
      DateTime scheduledAt = DateTime(
        dateValue.year,
        dateValue.month,
        dateValue.day,
        selectedTime.value?.hour ?? 0,
        selectedTime.value?.minute ?? 0,
      );
      final isScheduledInFuture = scheduledAt.isAfter(now);
      final game = GameModel(
        name: nameController.text,
        date: DateFormat(
          'yyyy-MM-dd',
        ).format(selectedDate.value ?? DateTime.now()),
        time: selectedTime.value == null ? '' : formattedTime,
        passkey: generatePasskey(),
        status: isScheduledInFuture ? GameStatus.draft : GameStatus.active,
      );

      final teamController = Get.isRegistered<CreateTeamController>()
          ? Get.find<CreateTeamController>()
          : null;
      final selectedTeams =
          teamController?.teams.toList() ?? <TeamPreview>[];
      final useSelectedTeams = selectedTeams.isNotEmpty;
      final teamsPayload = useSelectedTeams
          ? List.generate(selectedTeams.length, (index) {
              final team = selectedTeams[index];
              final selectedEmails = (team.selectedEmails ?? const [])
                      .map((e) => e.toString())
                      .where((e) => e.isNotEmpty)
                      .toList();
              final effectiveSelected =
                  selectedEmails.isNotEmpty
                      ? selectedEmails
                      : team.players.map((p) => p.email).toList();
              final effectiveEmails = selectedEmails.length > playersPerTeam
                  ? selectedEmails.take(playersPerTeam).toList()
                  : effectiveSelected;
              final members = team.players
                  .where((p) => effectiveEmails.contains(p.email))
                  .map((p) => {'uid': p.uid, 'name': p.name, 'email': p.email})
                  .toList();
              return {
                'name': team.name,
                'totalGames': 1,
                'avgBirdies': 0,
                'totalWins': 0,
                'topScores': 0,
                'teamBirdies': 0,
                'createdAt': DateTime.now().toIso8601String(),
                'members': members,
              };
            })
          : List.generate(teams, (index) {
              return {
                'name': "Team ${index + 1}",
                'totalGames': 1,
                'avgBirdies': 0,
                'totalWins': 0,
                'topScores': 0,
                'teamBirdies': 0,
                'createdAt': DateTime.now().toIso8601String(),
                'members': <Map<String, dynamic>>[],
              };
            });

      final clubGamePayload = {
        'name': game.name,
        'teamsCount': useSelectedTeams ? selectedTeams.length : teams,
        'playersPerTeam': playersPerTeam,
        'teams': teamsPayload,
        'time': game.time,
        'scheduledAt': scheduledAt,
      };

      await Get.find<ManageClubsController>().createGame(
        game,
        clubGame: clubGamePayload,
      );
      if (_draftGameId != null) {
        await FirebaseFirestore.instance
            .collection('games')
            .doc(_draftGameId)
            .delete();
      }
      resetForm();
      teamController?.clearTeams();
      _draftGameId = null;
      nav.changeTab(1);
    } catch (e, stack) {
      debugPrint('CreateGame failed: $e');
      debugPrintStack(stackTrace: stack);
      Get.snackbar("Error", "Failed to create game: $e");
    } finally {
      _isSubmitting = false;
    }
  }

  String generatePasskey({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();

    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  void removeTeam(int index) {
    if (index < generatedTeams.length) {
      generatedTeams.removeAt(index);
    }
    if (index < teamPlayers.length) {
      teamPlayers.removeAt(index);
    }
    if (index < teamNameControllers.length) {
      teamNameControllers[index].dispose();
      teamNameControllers.removeAt(index);
    }
    teams = generatedTeams.length;
    showTeams = false;
    update();
  }

  Future<void> addPlayersToTeam(
    int teamIndex,
    List<TextEditingController> controllers, {
    VoidCallback? onClose,
  }) async {
    final rawEmails = controllers
        .map((c) => c.text.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
    if (rawEmails.isEmpty) {
      Get.snackbar("Missing email", "Please enter at least one email");
      return;
    }

    final existingEmails = teamPlayers[teamIndex]
        .map((p) => p.email.toLowerCase())
        .toSet();
    for (final email in rawEmails) {
      if (existingEmails.contains(email)) {
        Get.snackbar("Duplicate", "Player already added to this team");
        return;
      }
    }

    final playersToAdd = <TeamPlayer>[];
    for (final email in rawEmails) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        Get.snackbar("Player did not sign up", "No user found for $email");
        return;
      }
      final doc = snapshot.docs.first;
      final data = doc.data();
      final name = (data['displayName'] ?? data['name'] ?? '').toString();
      playersToAdd.add(
        TeamPlayer(
          uid: doc.id,
          name: name.isEmpty ? email : name,
          email: email,
        ),
      );
    }

    teamPlayers[teamIndex].addAll(playersToAdd);
    if (teamIndex < generatedTeams.length) {
      final team = generatedTeams[teamIndex];
      final teamName = teamNameControllers.length > teamIndex
          ? teamNameControllers[teamIndex].text.trim()
          : team.name;
      generatedTeams[teamIndex] = TeamModel(
        name: teamName,
        playersCount: team.playersCount ?? team.playersPerTeam,
        birdies: team.birdies,
        holesRemaining: team.holesRemaining,
        progress: team.progress,
        joinedPlayers: teamPlayers[teamIndex].length,
        playersPerTeam: team.playersPerTeam,
      );
    }
    update();
    if (onClose != null) {
      onClose();
    } else if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }

  Future<void> saveDraftIfNeeded() async {
    if (_isSubmitting) return;
    final trimmedName = nameController.text.trim();
    final hasData = trimmedName.isNotEmpty;
    if (!hasData) return;
    final nav = Get.find<ClubAdminBottomNavController>();
    if (!nav.guardClubAccess()) return;
    final clubId = await _loadClubId();
    if (clubId == null || clubId.isEmpty) return;

    final teamController = Get.isRegistered<CreateTeamController>()
        ? Get.find<CreateTeamController>()
        : null;
    final selectedTeams =
        teamController?.teams.toList() ?? <TeamPreview>[];
    final useSelectedTeams = selectedTeams.isNotEmpty;
    final teamsPayload = useSelectedTeams
        ? List.generate(selectedTeams.length, (index) {
            final team = selectedTeams[index];
            final selectedEmails =
                (team.selectedEmails ?? const [])
                    .map((e) => e.toString())
                    .where((e) => e.isNotEmpty)
                    .toList();
            final effectiveSelected = selectedEmails.isNotEmpty
                ? selectedEmails
                : team.players.map((p) => p.email).toList();
            final effectiveEmails = effectiveSelected.length > playersPerTeam
                ? effectiveSelected.take(playersPerTeam).toList()
                : effectiveSelected;
            final members = team.players
                .where((p) => effectiveEmails.contains(p.email))
                .map((p) => {'uid': p.uid, 'name': p.name, 'email': p.email})
                .toList();
            return {
              'name': team.name,
              'totalGames': 0,
              'avgBirdies': 0,
              'totalWins': 0,
              'topScores': 0,
              'teamBirdies': 0,
              'createdAt': DateTime.now().toIso8601String(),
              'members': members,
            };
          })
        : <Map<String, dynamic>>[];

    final draftPayload = {
      'clubId': clubId,
      'name': trimmedName.isEmpty ? "Draft Game" : trimmedName,
      'date': DateFormat(
        'yyyy-MM-dd',
      ).format(selectedDate.value ?? DateTime.now()),
      'time': selectedTime.value == null ? '' : formattedTime,
      'passkey': '',
      'status': GameStatus.draft.name,
      'teamsCount': useSelectedTeams ? selectedTeams.length : teams,
      'playersPerTeam': playersPerTeam,
      if (teamsPayload.isNotEmpty) 'teams': teamsPayload,
      'updatedAt': FieldValue.serverTimestamp(),
      if (_draftGameId == null) 'createdAt': FieldValue.serverTimestamp(),
    };

    if (_draftGameId == null) {
      final ref = await FirebaseFirestore.instance
          .collection('games')
          .add(draftPayload);
      _draftGameId = ref.id;
    } else {
      await FirebaseFirestore.instance
          .collection('games')
          .doc(_draftGameId)
          .set(draftPayload, SetOptions(merge: true));
    }
  }

  Future<String?> _loadClubId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return userDoc.data()?['clubId']?.toString();
  }

  Future<void> loadDraftById(String gameId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .get();
    final data = snapshot.data();
    if (data == null) return;
    _draftGameId = gameId;
    isEditingDraft = true;
    nameController.text = (data['name'] ?? '').toString();
    final rawDate = (data['date'] ?? '').toString();
    if (rawDate.isNotEmpty) {
      try {
        selectedDate.value = DateFormat('yyyy-MM-dd').parse(rawDate);
      } catch (_) {
        selectedDate.value = null;
      }
    }
    final rawTime = (data['time'] ?? '').toString();
    if (rawTime.isNotEmpty) {
      try {
        final parsed = DateFormat('hh:mm a').parse(rawTime);
        selectedTime.value = TimeOfDay(
          hour: parsed.hour,
          minute: parsed.minute,
        );
      } catch (_) {
        selectedTime.value = null;
      }
    }
    playersPerTeam = (data['playersPerTeam'] ?? 2) as int? ?? 2;
    final rawTeams = data['teams'];
    if (rawTeams is List) {
      teams = rawTeams.length;
      generatedTeams = [];
      teamPlayers = [];
      for (final controller in teamNameControllers) {
        controller.dispose();
      }
      teamNameControllers.clear();
      showTeams = false;
    }
    update();
  }

  void resetForm() {
    nameController.clear();
    rulesController.clear();
    selectedDate.value = null;
    selectedTime.value = null;
    teams = 4;
    playersPerTeam = 2;
    generatedTeams = [];
    teamPlayers = [];
    for (final controller in teamNameControllers) {
      controller.dispose();
    }
    teamNameControllers.clear();
    isEditingDraft = false;
    update();
  }
}

class TeamPlayer {
  final String uid;
  final String name;
  final String email;

  TeamPlayer({required this.uid, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'email': email};
  }
}
