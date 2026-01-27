import 'package:bierdygame/app/modules/clubAdmin/newGame/controller/new_game_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/widgets/counter_widget.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/widgets/team_card.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:bierdygame/app/widgets/custom_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NewGameView extends GetView<NewGameController> {
  const NewGameView({super.key});

  @override
  Widget build(BuildContext context) {
    final hasController = Get.isRegistered<NewGameController>();
    return GetBuilder<NewGameController>(
      init: hasController ? null : NewGameController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),

                  /// TITLE
                  Center(
                    child: Text(
                      "Create a Game",
                      style: AppTextStyles.miniHeadings,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// GAME NAME
                  Text(
                    "Game Name",
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomFormField(
                    controller: controller.nameController,
                    hint: "Enter game name",
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderColorLight),
                    bgcolor: AppColors.white,
                  ),

                  SizedBox(height: 20.h),

                  /// COUNTER BOX
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.borderColorLight),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        CounterSettingTile(
                          title: "Number of Teams",
                          subtitle: "Total teams playing",
                          value: controller.teams,
                          minValue: 2,
                          maxValue: 8,
                          icon: Icons.groups,
                          iconBgColor: AppColors.primary,
                          onIncrement: controller.incrementTeams,
                          onDecrement: controller.decrementTeams,
                        ),

                        SizedBox(height: 12.h),

                        CounterSettingTile(
                          title: "Players per Team",
                          subtitle: "Size of each team",
                          value: controller.playersPerTeam,
                          minValue: 2,
                          maxValue: 4,
                          icon: Icons.person,
                          iconBgColor: AppColors.darkBlue,
                          onIncrement: controller.incrementPlayersPerTeam,
                          onDecrement: controller.decrementPlayersPerTeam,
                        ),

                        SizedBox(height: 16.h),

                        /// SAVE TEAMS
                        CustomElevatedButton(
                          btnName: "Save",
                          onPressed: controller.generateTeams,
                        ),
                      ],
                    ),
                  ),

                  /// GENERATED TEAMS
                  if (controller.showTeams) ...[
                    SizedBox(height: 25.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.generatedTeams.length,
                      itemBuilder: (context, index) {
                        return TeamCard(
                          team: controller.generatedTeams[index],
                          teamIndex: index,
                          nameController: controller.teamNameControllers[index],
                          onDelete: () => controller.removeTeam(index),
                          onAdd: () => _showAddPlayersSheet(context, controller, index),
                        );
                      },
                    ),
                  ],

                  SizedBox(height: 30.h),

                  /// CREATE GAME
                  CustomElevatedButton(
                    btnName: "Create Game",
                    onPressed: controller.confirmCreateGame,
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddPlayersSheet(
    BuildContext context,
    NewGameController controller,
    int teamIndex,
  ) {
    final team = controller.generatedTeams[teamIndex];
    final players = controller.teamPlayers[teamIndex];
    final remainingSlots = team.playersPerTeam - players.length;
    if (remainingSlots <= 0) {
      Get.snackbar("Team full", "This team already has all players");
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _AddPlayersSheet(
          remainingSlots: remainingSlots,
          existingPlayers: players.length,
          onClose: () => Navigator.of(sheetContext).pop(),
          onSubmit: (controllers) async {
            await controller.addPlayersToTeam(
              teamIndex,
              controllers,
              onClose: () {
                if (Navigator.of(sheetContext).canPop()) {
                  Navigator.of(sheetContext).pop();
                }
              },
            );
          },
        );
      },
    );
  }
}

class _AddPlayersSheet extends StatefulWidget {
  final int remainingSlots;
  final int existingPlayers;
  final VoidCallback onClose;
  final Future<void> Function(List<TextEditingController> controllers) onSubmit;

  const _AddPlayersSheet({
    required this.remainingSlots,
    required this.existingPlayers,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<_AddPlayersSheet> createState() => _AddPlayersSheetState();
}

class _AddPlayersSheetState extends State<_AddPlayersSheet> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.remainingSlots,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: "Add Players",
      onClose: widget.onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.remainingSlots, (index) {
          final labelIndex = widget.existingPlayers + index + 1;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: CustomFormField(
              label: "Email (Player $labelIndex)",
              hint: "Enter Email Address",
              controller: _controllers[index],
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderColorLight),
            ),
          );
        }),
      ),
      actions: [
        CustomElevatedButton(
          btnName: "Add to team",
          onPressed: () async {
            await widget.onSubmit(_controllers);
          },
        ),
      ],
    );
  }
}
