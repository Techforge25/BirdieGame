import 'package:bierdygame/app/modules/auth/controller/auth_controller.dart';
import 'package:bierdygame/app/modules/auth/data/auth_repository.dart';
import 'package:get/get.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => FirebaseAuthRepository());
    Get.lazyPut<AuthController>(
      () => AuthController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
