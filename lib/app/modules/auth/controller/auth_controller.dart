import 'package:bierdygame/app/modules/auth/data/auth_repository.dart';
import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  // Controllers for text fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;


  var isLoading = false.obs;

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final name = nameController.text.trim();

      final userCredential = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: name,
      );

      final user = userCredential.user;
      if (user == null) {
        Get.snackbar("Signup Failed", "Unable to create account");
        return;
      }

      final invitedRole = await _authRepository.consumeInviteRole(email);
      final role = invitedRole ?? 'player';

      await _authRepository.upsertUserProfile(
        uid: user.uid,
        email: email,
        displayName: name,
        role: role,
      );

      Get.snackbar("Success", "Account created successfully");

      // Navigate after signup
      // Get.offAll(() => HomeView());

    } on Exception catch (e) {
      Get.snackbar("Signup Failed", e.toString(),duration: Duration(seconds: 11));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and password are required");
      return;
    }

    try {
      isLoading.value = true;

      final userCredential = await _authRepository.signIn(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        Get.snackbar("Login Failed", "User not found");
        return;
      }

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = userDoc.data() ?? {};
      final isActive = data['isActive'] == null ? true : data['isActive'] == true;
      final status = (data['status'] ?? '').toString().toLowerCase();
      final isSuspended = !isActive || status == 'inactive' || status == 'suspended' || status == 'blocked';
      if (isSuspended) {
        await FirebaseAuth.instance.signOut();
        Get.snackbar(
          "Account Suspended",
          "Your Account was Suspended contact Super Admin",
        );
        return;
      }

      final role = await _authRepository.fetchUserRole(user.uid);
      final route = _routeForRole(role);
      if (route == null) {
        Get.snackbar("Login Failed", "Contact Super Admin");
        return;
      }

      Get.offAllNamed(route);
    } on Exception catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? _routeForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return Routes.SUPER_ADMIN_BOTTOM_NAV;
      case 'club_admin':
      case 'clubadmin':
        return Routes.CLUB_ADMIN_BOTTOM_NAV;
      case 'player':
        return Routes.PLAYER_BOTTOM_NAV;
      default:
        return null;
    }
  }
  

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
