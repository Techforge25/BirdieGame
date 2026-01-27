import 'package:bierdygame/app/modules/golfClub/clubEdit/controller/club_edit_controller.dart';
import 'package:get/get.dart';

class ClubEditBinding extends Bindings {
  ClubEditBinding({
    required this.clubId,
    required this.initialName,
    required this.initialLocation,
    required this.initialLogoPath,
    required this.initialLogoBase64,
  });

  final String? clubId;
  final String? initialName;
  final String? initialLocation;
  final String? initialLogoPath;
  final String? initialLogoBase64;

  @override
  void dependencies() {
    Get.put(
      ClubEditController(
        clubId: clubId,
        initialName: initialName,
        initialLocation: initialLocation,
        initialLogoPath: initialLogoPath,
        initialLogoBase64: initialLogoBase64,
      ),
      permanent: true,
    );
  }
}
