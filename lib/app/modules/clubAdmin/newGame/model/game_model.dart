import 'package:flutter/material.dart';

enum GameStatus { active, draft, completed }

class GameModel {
  final String id;
  final String clubId;
  final String name;
  final String date;
  final String passkey;
  final GameStatus status;

  // Additional for GameDetailView
  final int currentHole;
  final int totalHoles;
  final int par;
  final int totalTeams;
  final int totalPlayers;
  final int birdiedTeams;
  final double matchProgress; // 0.0 to 1.0
  final List<TeamModel> teams;

  GameModel({
    this.id = '',
    this.clubId = '',
    required this.name,
    required this.date,
    required this.passkey,
    required this.status,
    this.currentHole = 1,
    this.totalHoles = 18,
    this.par = 3,
    this.totalTeams = 0,
    this.totalPlayers = 0,
    this.birdiedTeams = 0,
    this.matchProgress = 0.0,
    this.teams = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'clubId': clubId,
      'name': name,
      'date': date,
      'passkey': passkey,
      'status': status.name,
    };
  }

  static GameModel fromMap(String id, Map<String, dynamic> data) {
    final statusStr = (data['status'] ?? 'active').toString();
    final parsedStatus = GameStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => GameStatus.active,
    );
    return GameModel(
      id: id,
      clubId: (data['clubId'] ?? '').toString(),
      name: (data['name'] ?? 'Game').toString(),
      date: (data['date'] ?? '').toString(),
      passkey: (data['passkey'] ?? '').toString(),
      status: parsedStatus,
    );
  }
}

class TeamModel {
  final String? name;
  final int? joinedPlayers;
  final int? playersCount;
  final int? birdies;
  final int? holesRemaining;
  final double? progress; // 0.0 - 1.0
  final int playersPerTeam;

  TeamModel({
    this.name,
    this.playersCount,
    this.birdies,
    this.holesRemaining,
    this.progress,
    this.joinedPlayers,
    required this.playersPerTeam,
  });
}
class TeamFormModel {
  final TextEditingController nameController;
  final List<PlayerFormModel> players;

  TeamFormModel({
    required this.nameController,
    required this.players,
  });
}

class PlayerFormModel {
  final TextEditingController nameController;
  final TextEditingController emailController;

  PlayerFormModel()
      : nameController = TextEditingController(),
        emailController = TextEditingController();
}




//
