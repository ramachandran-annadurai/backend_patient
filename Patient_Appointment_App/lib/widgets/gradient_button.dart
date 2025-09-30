import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? startColor;
  final Color? endColor;
  final double? width;
  final double? height;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.startColor,
    this.endColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return Container(
      width: width ?? MediaQuery.of(context).size.width * 0.85,
      height: height ?? 56,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF60A5FA),
                  const Color(0xFFF472B6),
                ],
              )
            : LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade400,
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color:
                      (startColor ?? const Color(0xFF60A5FA)).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
