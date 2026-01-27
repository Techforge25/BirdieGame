import 'package:bierdygame/app/routes/app_pages.dart';
import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,  
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.scaffoldBackground,
            primaryColor: AppColors.primary,
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
            elevatedButtonTheme: elevatedButtonTheme,
          ),
          
          initialRoute: Routes.splash, // App welcome screen se shuru hogi
          getPages: AppPages.routes,
        );
      },
    );
  }
}