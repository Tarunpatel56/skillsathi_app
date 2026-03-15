import 'package:flutter/material.dart';

/// Reusable custom button with gradient, icon, and loading support.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final List<Color>? gradientColors;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.gradientColors,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [const Color(0xFF6C63FF), const Color(0xFF3F3D9E)];

    return SizedBox(
      width: width ?? double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : icon != null
                  ? Icon(icon, size: 20)
                  : const SizedBox.shrink(),
          label: Text(label,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable custom text field with dark theme.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF6C63FF))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
