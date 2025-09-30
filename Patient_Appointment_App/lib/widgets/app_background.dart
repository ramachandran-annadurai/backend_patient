import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showShapes;

  const AppBackground({
    super.key,
    required this.child,
    this.showShapes = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Background blob shapes
          if (showShapes) ...[
            // Top-left light blue blob
            Positioned(
              left: -100,
              top: -50,
              child: Container(
                width: isTablet ? 300 : 200,
                height: isTablet ? 300 : 200,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLightBlue,
                  borderRadius: BorderRadius.circular(150),
                ),
              ),
            ),

            // Bottom-right light pink blob
            Positioned(
              right: -100,
              bottom: -50,
              child: Container(
                width: isTablet ? 350 : 250,
                height: isTablet ? 350 : 250,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLightPink,
                  borderRadius: BorderRadius.circular(175),
                ),
              ),
            ),
          ],

          // Main content
          child,
        ],
      ),
    );
  }
}

// Convenience widget for Scaffold with background
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBackgroundShapes;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackgroundShapes = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: AppBackground(
        showShapes: showBackgroundShapes,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
