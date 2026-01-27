import 'package:bierdygame/app/widgets/custom_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'custom_text_field.dart';

/// A fully reusable form field builder.
/// You can use this for text, dropdown, or date fields anywhere in the app.
class CustomFormField extends StatefulWidget {
  final Color? bgcolor;
  final String? label;
  final Color? labelColor;
  final String? hint;
  final List<String>? items; // for dropdown
  final void Function(dynamic)? onChanged; // for dropdown or date
  final bool isDatePicker;
  final bool isDropdown;
  final bool? isLarge;
  final TextStyle? labeltextStyle;
  final TextEditingController? controller;
  final bool? enable;
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;

  const CustomFormField({
    super.key,
    this.label,
    this.bgcolor,
    this.hint,
    this.items,
    this.onChanged,
    this.isLarge,
    this.controller,
    this.isDatePicker = false,
    this.isDropdown = false,
    this.labeltextStyle,
    this.labelColor,
    this.enable, this.borderSide,this.borderRadius
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late TextEditingController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
  }

  @override
  void didUpdateWidget(covariant CustomFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      _initController();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label ?? "",
          style:
              widget.labeltextStyle ??
              AppTextStyles.bodySmall.copyWith(color: widget.labelColor),
        ),
        SizedBox(height: 4.h),

        /// Dropdown Field
        if (widget.isDropdown && widget.items != null)
          CustomDropDownWidget(
            // backgroundColor: AppColors.primary,
            title: widget.hint,
            list: widget.items!,
            valChanged: widget.onChanged ?? (_) {},
          )
        /// Date Picker Field
        else if (widget.isDatePicker)
          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: DateTime.now(),
              );
              if (pickedDate != null) {
                String formattedDate =
                    "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                _controller.text = formattedDate;
                if (widget.onChanged != null) {
                  widget.onChanged!(pickedDate);
                }
              }
            },
            child: AbsorbPointer(
              child: CustomTextField(
                controller: _controller,
                borderRadius: widget.borderRadius,
                hintText: widget.hint ?? '',
                suffixIcon: Icon(LucideIcons.calendarRange),
                borderSide: BorderSide(color: AppColors.borderColor),
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textBlack,
                ), 
              ),
            ),
          )
        /// Normal Text Field
        else
          CustomTextField(
            controller: widget.controller ?? _controller,
            hintText: widget.hint ?? '',
            borderSide: widget.borderSide ?? BorderSide(color: AppColors.borderColor),
            hintStyle: AppTextStyles.bodySmall.copyWith(), 
            isLarge: widget.isLarge,
            enable: widget.enable,
            bgcolor: widget.bgcolor,
            borderRadius: widget.borderRadius,
          ),
      ],
    );
  }
}
