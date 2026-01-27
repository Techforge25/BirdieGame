import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TeamCard extends StatelessWidget {
  final TeamModel team;
  final int teamIndex;
  final TextEditingController nameController;
  final VoidCallback onDelete;
  final VoidCallback onAdd;

  const TeamCard({
    super.key,
    required this.team,
    required this.teamIndex,
    required this.nameController,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  "Team ${teamIndex + 1}",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          /// TEAM NAME
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Team ${teamIndex + 1}",
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 10.h),

          /// BOTTOM ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${team.joinedPlayers ?? 0}/${team.playersCount ?? team.playersPerTeam} Joined",
                style: TextStyle(color: Colors.grey.shade700),
              ),

              OutlinedButton.icon(
                onPressed: onAdd,
                icon: Icon(Icons.person_add, size: 16),
                label: Text("Add"),
              )
            ],
          )
        ],
      ),
    );
  }
}
