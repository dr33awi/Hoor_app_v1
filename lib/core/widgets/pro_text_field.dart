// ═══════════════════════════════════════════════════════════════════════════
// Pro Text Field - Shared Text Input Widget
// Unified text field component for all forms
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/design_tokens.dart';

/// حقل نص موحد لجميع النماذج
class ProTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? prefix;
  final String? suffixText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const ProTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.prefix,
    this.suffixText,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon,
                    color: AppColors.textTertiary, size: AppIconSize.sm)
                : null,
            prefix: prefix,
            suffixText: suffixText,
            suffix: suffix,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.secondary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide:
                  BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// حقل نص للأرقام فقط
class ProNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffixText;
  final bool allowDecimal;
  final bool allowNegative;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const ProNumberField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixText,
    this.allowDecimal = true,
    this.allowNegative = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      keyboardType: TextInputType.numberWithOptions(
        decimal: allowDecimal,
        signed: allowNegative,
      ),
      inputFormatters: [
        if (!allowDecimal && !allowNegative)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(
            RegExp(allowNegative ? r'[0-9.-]' : r'[0-9.]'),
          ),
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}

/// حقل نص للهاتف
class ProPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const ProPhoneField({
    super.key,
    required this.controller,
    this.label = 'رقم الهاتف',
    this.hint = '05xxxxxxxx',
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
        LengthLimitingTextInputFormatter(15),
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}

/// حقل نص للبريد الإلكتروني
class ProEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const ProEmailField({
    super.key,
    required this.controller,
    this.label = 'البريد الإلكتروني',
    this.hint = 'example@email.com',
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: validator ?? _defaultEmailValidator,
      onChanged: onChanged,
    );
  }

  String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) return null; // اختياري
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }
}
