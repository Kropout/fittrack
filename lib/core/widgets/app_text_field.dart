import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? suffix;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? hint;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.suffix,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.hint,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          cursorColor: AppColors.goldLight,
          style: AppTextStyles.bodyStrong,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            suffixText: suffix,
            suffixStyle: AppTextStyles.body,
            filled: true,
            fillColor: const Color(0xFF14172A),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: _border(AppColors.hairline),
            focusedBorder: _border(AppColors.goldLight),
            errorBorder: _border(const Color(0xFFE57373)),
            focusedErrorBorder: _border(const Color(0xFFE57373)),
            errorStyle: const TextStyle(color: Color(0xFFE57373)),
          ),
        ),
      ],
    );
  }
}