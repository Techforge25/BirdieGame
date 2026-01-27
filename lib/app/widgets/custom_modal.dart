import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final TextStyle? titleStyle;
  final VoidCallback? onClose;

  const CustomModal({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.titleStyle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: kToolbarHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ).copyWith(top: 16),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: titleStyle ??  AppTextStyles.bodyMedium),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose ?? () => Get.back(),
                    ),
                  ],
                ),
              ),

              Divider(color: AppColors.borderColor, thickness: 1,indent: 15,endIndent: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width:
                          double.infinity, // <-- ADDED (forces left alignment)
                      child: content,
                    ),
                    const SizedBox(height: 24),
                    ...actions,
                    SizedBox(height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
