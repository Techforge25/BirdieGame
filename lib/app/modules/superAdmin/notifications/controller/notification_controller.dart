import 'package:get/get.dart';

class NotificationController extends GetxController {
  RxInt selectedTab = 0.obs;
  Rx<String?> selectedClub = Rx<String?>(null);

  void changeTab(int index) {
    selectedTab.value = index;
     selectedClub.value = null;
  }
}
