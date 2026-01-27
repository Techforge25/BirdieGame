import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.offNamed(Routes.ON_BOARDING_WELCOME);
      return;
    }
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = doc.data()?['role']?.toString();
      final route = _routeForRole(role);
      if (route != null) {
        Get.offAllNamed(route);
      } else {
        Get.offNamed(Routes.ON_BOARDING_WELCOME);
      }
    } catch (_) {
      Get.offNamed(Routes.ON_BOARDING_WELCOME);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: 
          Center(
            child: Image.asset(
              'assets/images/green_logo.png',
              width: 300.w,
              height: 300.h,
            ),
      ),
    );
  }
}
