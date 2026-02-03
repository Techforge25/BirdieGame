import 'package:bierdygame/app/modules/clubAdmin/create_team/controller/create_team_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/create_team/view/create_team_view.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/controller/new_game_controller.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';

class TeamSetupView extends StatelessWidget {
  const TeamSetupView({super.key, this.onClose});

  final VoidCallback? onClose;

  Future<String?> _loadClubId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return userDoc.data()?['clubId']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final createTeamController = Get.find<CreateTeamController>();
    createTeamController.initTeamSetupSelection();
    final newGameController = Get.find<NewGameController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: onClose ?? () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        centerTitle: true,
        title: Text('Team Setup', style: AppTextStyles.bodyMedium2),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team Setup', style: AppTextStyles.subHeading),
            SizedBox(height: 6.h),
            Obx(() {
              final total = newGameController.teams;
              final added = createTeamController.teams.length;
              return Text(
                '$added of $total teams added',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            }),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: _setupCard(
                    icon: Icons.add,
                    label: 'Create Team',
                    onTap: () => _showCreateTeamSheet(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _setupCard(
                    icon: Icons.groups,
                    label: 'Existing Team',
                    onTap: () =>
                        _showExistingTeamsDialog(context, createTeamController),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                final teams = createTeamController.teams;
                if (teams.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return _selectedTeamCard(
                      context,
                      team,
                      createTeamController,
                      newGameController.playersPerTeam,
                    );
                  },
                );
              }),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => newGameController.confirmCreateGame(
                  onSuccess: () => Get.back(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(
                  'Create Game',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _setupCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary,
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(height: 10.h),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _selectedTeamCard(
    BuildContext context,
    TeamPreview team,
    CreateTeamController controller,
    int maxPlayers,
  ) {
    final memberList = team.players;
    final limit = maxPlayers <= 0 ? 1 : maxPlayers;
    final selectedEmails = (team.selectedEmails ?? const []).isNotEmpty
        ? team.selectedEmails!
        : memberList.map((p) => p.email).toList();
    if (memberList.length > limit &&
        (team.selectedEmails ?? const []).isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final defaults = memberList
            .take(limit)
            .map((player) => player.email)
            .toList();
        controller.setTeamSelectedEmails(team.id, defaults);
      });
    }
    final selectedSet = selectedEmails.toSet();
    final selectedCount = memberList.length <= limit
        ? memberList.length
        : selectedSet.isEmpty
        ? limit
        : selectedSet.length;
    final canAddPlayers = selectedCount < limit;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColorLight),
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isExpanded = false;
          return Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 14.w),
              childrenPadding: EdgeInsets.only(bottom: 6.h),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.transparent),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.transparent),
              ),
              onExpansionChanged: (expanded) {
                setState(() {
                  isExpanded = expanded;
                });
              },
              title: Text(team.name, style: AppTextStyles.bodyMedium2),
              subtitle: Text(
                '$selectedCount/$limit players',
                style: AppTextStyles.bodySmall,
              ),
              trailing: AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.expand_more, color: AppColors.borderColor),
              ),
              children: [
                if (memberList.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 68.w,
                      right: 14.w,
                      bottom: 12.h,
                    ),
                    child: Text(
                      'No players added',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ...memberList.map((player) {
                  final displayName = player.name.isEmpty
                      ? player.email
                      : player.name;
                  final isCaptain =
                      player.email.toLowerCase() ==
                      team.captainEmail.toLowerCase();
                  final isSelected = memberList.length > limit
                      ? selectedSet.contains(player.email)
                      : true;
                  return Container(
                    margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColorLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.flashyblue,
                          child: Text(
                            displayName.isEmpty
                                ? '?'
                                : displayName[0].toUpperCase(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: AppTextStyles.bodyMedium,
                              ),
                              if (player.email.isNotEmpty)
                                Text(
                                  player.email,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (memberList.length > limit)
                          Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primary,
                            onChanged: (checked) {
                              final next = selectedSet.toSet();
                              if (checked == true) {
                                if (next.length >= limit) {
                                  Get.snackbar(
                                    'Limit reached',
                                    'Only $limit players allowed',
                                  );
                                  return;
                                }
                                next.add(player.email);
                              } else {
                                next.remove(player.email);
                              }
                              controller.setTeamSelectedEmails(
                                team.id,
                                next.toList(),
                              );
                            },
                          ),
                        if (isCaptain)
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 22,
                          ),
                      ],
                    ),
                  );
                }).toList(),
                if (canAddPlayers)
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
                    child: GestureDetector(
                      onTap: () => _showAddPlayersDialog(
                        context,
                        controller,
                        team,
                        limit,
                      ),
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: AppColors.primary,
                          strokeWidth: 1.2,
                          dashPattern: const [6, 4],
                          radius: const Radius.circular(10),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: AppColors.primary),
                              SizedBox(width: 8.w),
                              Text(
                                'Add Player',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddPlayersDialog(
    BuildContext context,
    CreateTeamController controller,
    TeamPreview team,
    int limit,
  ) async {
    final currentSelected = (team.selectedEmails ?? const []).isNotEmpty
        ? team.selectedEmails!.length
        : team.players.length;
    final remaining = limit - currentSelected;
    final slots = remaining <= 0 ? 1 : remaining;
    final controllers = List.generate(slots, (_) => TextEditingController());
    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add Players',
                        style: AppTextStyles.bodyMedium2,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      icon: Icon(Icons.close, color: AppColors.borderColor),
                    ),
                  ],
                ),
                Divider(color: AppColors.borderColorLight),
                SizedBox(height: 6.h),
                ...List.generate(slots, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email (Player ${index + 1})',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: controllers[index],
                          decoration: InputDecoration(
                            hintText: 'Enter Email Address',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 14.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.borderColorLight,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.borderColorLight,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 6.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final emails = controllers
                          .map((c) => c.text.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      Navigator.of(dialogContext).pop(emails);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      'Send Invite & Add Player',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!context.mounted) {
      return;
    }
    if (result != null && result.isNotEmpty) {
      await controller.addPlayersToTeamFromDialog(
        teamId: team.id,
        currentPlayers: team.players,
        emails: result,
        limit: limit,
        currentSelectedEmails: team.selectedEmails ?? const [],
      );
    }
  }

  Widget _teamsList(BuildContext context, CreateTeamController controller) {
    return FutureBuilder<String?>(
      future: _loadClubId(),
      builder: (context, snapshot) {
        final clubId = snapshot.data;
        if (clubId == null || clubId.isEmpty) {
          return const SizedBox.shrink();
        }
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('teams')
              .where('clubId', isEqualTo: clubId)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return const SizedBox.shrink();
            }
            final docs = snap.data!.docs;
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final name = (data['name'] ?? 'Team').toString();
                final members = data['members'];
                final count = members is List ? members.length : 0;
                final memberList = members is List ? members : const [];
                final captainEmail = (data['captainEmail'] ?? '')
                    .toString()
                    .toLowerCase();
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderColorLight),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      bool isExpanded = false;
                      return Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.symmetric(horizontal: 14.w),
                          childrenPadding: EdgeInsets.only(bottom: 6.h),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Colors.transparent),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Colors.transparent),
                          ),
                          onExpansionChanged: (expanded) {
                            setState(() {
                              isExpanded = expanded;
                            });
                          },
                          title: Text(name, style: AppTextStyles.bodyMedium2),
                          subtitle: Text(
                            '$count/4 players',
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.expand_more,
                              color: AppColors.borderColor,
                            ),
                          ),
                          children: [
                            if (memberList.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 68.w,
                                  right: 14.w,
                                  bottom: 12.h,
                                ),
                                child: Text(
                                  'No players added',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ...memberList.map((member) {
                              if (member is! Map<String, dynamic>) {
                                return const SizedBox.shrink();
                              }
                              final playerName = (member['name'] ?? '')
                                  .toString();
                              final email = (member['email'] ?? '').toString();
                              final displayName = playerName.isEmpty
                                  ? email
                                  : playerName;
                              final isCaptain =
                                  email.toLowerCase() == captainEmail;
                              return Container(
                                margin: EdgeInsets.fromLTRB(
                                  14.w,
                                  0,
                                  14.w,
                                  10.h,
                                ),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderColorLight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppColors.flashyblue,
                                      child: Text(
                                        displayName.isEmpty
                                            ? '?'
                                            : displayName[0].toUpperCase(),
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                          if (email.isNotEmpty)
                                            Text(
                                              email,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isCaptain)
                                      Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber,
                                        size: 22,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateTeamSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final height =
            MediaQuery.of(sheetContext).size.height -
            kBottomNavigationBarHeight;
        return SizedBox(height: height, child: const CreateTeamView());
      },
    );
  }

  Future<void> _showExistingTeamsDialog(
    BuildContext context,
    CreateTeamController controller,
  ) async {
    final clubId = await _loadClubId();
    if (clubId == null || clubId.isEmpty) {
      Get.snackbar("Error", "Missing club id");
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(16.w),
            constraints: BoxConstraints(maxHeight: 420.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Available Teams',
                        style: AppTextStyles.subHeading,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(Icons.close, color: AppColors.borderColor),
                    ),
                  ],
                ),
                Divider(color: AppColors.borderColorLight),
                SizedBox(height: 10.h),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('teams')
                        .where('clubId', isEqualTo: clubId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No teams found'));
                      }
                      final teams = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final doc = teams[index];
                          final data = doc.data();
                          final name = (data['name'] ?? 'Team').toString();
                          final members = data['members'];
                          final playersCount = members is List
                              ? members.length
                              : 0;
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.borderColorLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primary,
                                  child: const Icon(
                                    Icons.emoji_events,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: AppTextStyles.bodyMedium2,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '$playersCount/4 Players',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    controller.addTeamFromFirestore(
                                      teamId: doc.id,
                                      data: data,
                                    );
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.flashyGreen,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
