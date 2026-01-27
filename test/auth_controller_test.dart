import 'package:bierdygame/app/modules/auth/controller/auth_controller.dart';
import 'package:bierdygame/app/modules/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeAuthRepository implements AuthRepository {
  bool signInCalled = false;
  bool signUpCalled = false;
  bool upsertCalled = false;
  bool fetchRoleCalled = false;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    signInCalled = true;
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    signUpCalled = true;
    throw UnimplementedError();
  }

  @override
  Future<void> upsertUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required String role,
  }) {
    upsertCalled = true;
    throw UnimplementedError();
  }

  @override
  Future<String?> fetchUserRole(String uid) {
    fetchRoleCalled = true;
    throw UnimplementedError();
  }

  @override
  Future<String?> consumeInviteRole(String email) {
    throw UnimplementedError();
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  test('signIn returns early when email is empty', () async {
    final repo = FakeAuthRepository();
    final controller = AuthController(authRepository: repo);

    controller.passwordController.text = 'password';
    await controller.signIn();

    expect(repo.signInCalled, isFalse);
    expect(controller.isLoading.value, isFalse);
  });

  test('signUp returns early when passwords mismatch', () async {
    final repo = FakeAuthRepository();
    final controller = AuthController(authRepository: repo);

    controller.passwordController.text = 'password';
    controller.confirmPasswordController.text = 'different';
    await controller.signUp();

    expect(repo.signUpCalled, isFalse);
    expect(controller.isLoading.value, isFalse);
  });
}
