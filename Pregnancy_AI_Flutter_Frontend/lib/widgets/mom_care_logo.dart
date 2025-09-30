import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MomCareLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showShadow;
  final Widget? fallbackIcon;

  const MomCareLogo({
    super.key,
    this.size = 100,
    this.borderRadius = 20,
    this.showShadow = true,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: size * 0.1,
                  offset: Offset(0, size * 0.05),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/mom_care_logo.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon if logo fails to load
            return fallbackIcon ??
                Icon(
                  Icons.pregnant_woman,
                  size: size * 0.8,
                  color: AppColors.primary,
                );
          },
        ),
      ),
    );
  }
}

/// Predefined logo sizes for consistency
class MomCareLogoSizes {
  static const double small = 60;
  static const double medium = 100;
  static const double large = 140;
  static const double extraLarge = 180;
}


