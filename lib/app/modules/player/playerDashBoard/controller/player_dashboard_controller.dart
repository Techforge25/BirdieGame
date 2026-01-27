import 'package:bierdygame/app/modules/player/playerDashBoard/view/widget/carousel_model.dart';
import 'package:get/get.dart';

class PlayerDashboardController extends GetxController {
  var currentIndex = 0.obs;

  final List<DashboardSliderModel> sliders = [
    DashboardSliderModel(
      image: "assets/images/pic1.png",
      title: "Smart\nLeaderboards",
      subtitle:
          "See top players and teams with\nauto-calculated rankings.",
    ),
    DashboardSliderModel(
      image: "assets/images/pic2.png",
      title: "Live\nMatches",
      subtitle:
          "Track live matches and\nreal-time scores instantly.",
    ),
    DashboardSliderModel(
      image: "assets/images/pic3.png",
      title: "Player\nStatistics",
      subtitle:
          "Analyze player performance\nwith advanced statistics.",
    ),
  ];
}
