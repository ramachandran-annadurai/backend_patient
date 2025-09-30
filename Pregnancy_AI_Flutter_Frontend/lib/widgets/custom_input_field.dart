import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final VoidCallback? onTogglePassword;

  const CustomInputField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppTheme.textGray.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: AppTheme.textGray,
            size: 20,
          ),
          suffixIcon: isPassword && onTogglePassword != null
              ? IconButton(
                  icon: Icon(
                    isPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textGray,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: AppTheme.textGray,
        ),
      ),
    );
  }
}
