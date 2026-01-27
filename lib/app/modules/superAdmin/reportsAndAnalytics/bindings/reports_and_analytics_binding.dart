import 'package:bierdygame/app/modules/superAdmin/reportsAndAnalytics/controller/reports_and_analytics_controller.dart';
import 'package:get/get.dart';

class ReportsAndAnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportsAndAnalyticsController>(
      () => ReportsAndAnalyticsController(),
    );
  }
}
