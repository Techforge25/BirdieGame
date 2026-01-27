import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomProfileBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onAvatarTap;
  final String bgImg;
  final String name;
  final String? imageUrl;
  final ImageProvider? imageProvider;
  const CustomProfileBar({
    super.key,
    required this.onTap,
    this.onAvatarTap,
    required this.bgImg,
    required this.name,
    this.imageUrl,
    this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
              children: [
                 GestureDetector(
                   onTap: onAvatarTap,
                   child: CircleAvatar(
                    radius: 25.r,
                    backgroundImage: imageProvider ??
                        ((imageUrl != null && imageUrl!.isNotEmpty)
                            ? NetworkImage(imageUrl!)
                            : AssetImage(bgImg) as ImageProvider),
                                   ),
                 ),
                const SizedBox(width: 12),
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.miniHeadings,
                    ),
                    Text(
                      "Welcome Back, $name",
                      style: AppTextStyles.bodySmall
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration:  BoxDecoration(
                      color: Color(0xFF00833A),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            );
  }
}
