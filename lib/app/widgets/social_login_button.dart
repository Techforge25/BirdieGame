import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialLoginButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onPressed;

  const SocialLoginButton({
    Key? key,
    required this.assetPath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child:Container(
        width: 240.w,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.borderColorLight,borderRadius: BorderRadius.circular(10.r)),
        child: Row(
            children: [
              Image.asset(assetPath,height: 28,width: 28,),
              SizedBox(width: 10.w,),
              Text("Continue with Google",style: AppTextStyles.bodyMedium,)
            ],
          ),
      ),
    );
  }
}
