// lib/core/widgets/custom_text_field.dart
// 📝 حقل نص مخصص

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// حقل نص مخصص بتصميم حديث
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? fillColor;
  final EdgeInsets? contentPadding;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.autofocus = false,
    this.fillColor,
    this.contentPadding,
  });

  /// حقل بحث
  factory CustomTextField.search({
    TextEditingController? controller,
    String? hint,
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
  }) {
    return CustomTextField(
      controller: controller,
      hint: hint ?? 'بحث...',
      prefixIcon: Icons.search,
      suffix: controller != null && controller.text.isNotEmpty
          ? IconButton(
              icon: Icon(Icons.close, color: Colors.grey.shade400, size: 20),
              onPressed: () {
                controller.clear();
                onClear?.call();
              },
            )
          : null,
      onChanged: onChanged,
    );
  }

  /// حقل كلمة مرور
  factory CustomTextField.password({
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    bool showPassword = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      controller: controller,
      label: label ?? 'كلمة المرور',
      hint: hint ?? 'أدخل كلمة المرور',
      errorText: errorText,
      prefixIcon: Icons.lock_outline,
      obscureText: !showPassword,
      suffix: IconButton(
        icon: Icon(
          showPassword ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey.shade500,
        ),
        onPressed: onToggleVisibility,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          onChanged: onChanged,
          onTap: onTap,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: TextStyle(
            fontSize: 14,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey.shade400, size: 20)
                : prefix,
            suffixIcon: suffix,
            filled: true,
            fillColor:
                fillColor ??
                (enabled ? Colors.grey.shade50 : Colors.grey.shade100),
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }
}

/// حقل باركود
class BarcodeTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onScanPressed;
  final VoidCallback? onClear;
  final String? hint;

  const BarcodeTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onScanPressed,
    this.onClear,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hint ?? 'امسح أو أدخل الباركود...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.qr_code, color: Colors.grey.shade400),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          controller.clear();
                          onClear?.call();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _ScanButton(onPressed: onScanPressed),
      ],
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _ScanButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.info,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.info.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }
}
