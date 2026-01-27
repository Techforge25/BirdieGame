import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ScoresController extends GetxController {
  RxInt selectedTab = 0.obs;
  RxBool showGameDetail = false.obs;
  RxBool showPlayerRank = false.obs;
  final RxnString clubId = RxnString();
  final RxnString selectedGameName = RxnString();
  final RxnString selectedGameStatus = RxnString();
  final RxnString selectedGameDate = RxnString();
  final Rxn<Map<String, dynamic>> selectedTeam = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> selectedPlayer = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _loadClubId();
  }

  Future<void> _loadClubId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    clubId.value = doc.data()?['clubId']?.toString();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
  void openTeamRank({
    required String name,
    required String status,
    required String date,
    Map<String, dynamic>? teamData,
  }) {
    selectedGameName.value = name;
    selectedGameStatus.value = status;
    selectedGameDate.value = date;
    selectedTeam.value = teamData;
    showGameDetail.value = true;
  }
  void openPlayerRank({
    required String name,
    required String status,
    required String date,
    Map<String, dynamic>? playerData,
  }) {
    selectedGameName.value = name;
    selectedGameStatus.value = status;
    selectedGameDate.value = date;
    selectedPlayer.value = playerData;
    showPlayerRank.value = true;
  }

  void backToGames() {
    showGameDetail.value = false;
    showPlayerRank.value = false;
    selectedGameName.value = null;
    selectedGameStatus.value = null;
    selectedGameDate.value = null;
    selectedTeam.value = null;
    selectedPlayer.value = null;
  }
}
