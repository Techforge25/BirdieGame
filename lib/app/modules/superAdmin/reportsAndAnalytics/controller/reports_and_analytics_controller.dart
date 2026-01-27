import 'package:get/get.dart';

class ReportsAndAnalyticsController extends GetxController {
  RxInt selectedTab = 0.obs;
  Rx<String?> selectedStats = Rx<String?>(null);

  void changeTab(int index) {
    selectedTab.value = index;
     selectedStats.value = null;
  }
}
