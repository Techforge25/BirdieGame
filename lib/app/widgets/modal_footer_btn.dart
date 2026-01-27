import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ModalFooterBtn extends StatelessWidget {
  final String text1;
  final double? fontSize;
  final String text2;
  final VoidCallback onTap1;
  final VoidCallback onTap2;
  final Color? borderColor;
  
  const ModalFooterBtn({
    super.key,
    required this.text1,
    required this.text2, required this.onTap1, required this.onTap2, this.fontSize, this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onTap1,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              text1,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white,fontSize: fontSize),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: onTap2,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: borderColor ?? Colors.grey[300]!,width: 1.5),
            ),
            child: Text(
              text2,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
