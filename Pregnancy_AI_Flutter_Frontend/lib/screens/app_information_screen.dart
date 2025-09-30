import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';

class AppInformationScreen extends StatefulWidget {
  const AppInformationScreen({super.key});

  @override
  State<AppInformationScreen> createState() => _AppInformationScreenState();
}

class _AppInformationScreenState extends State<AppInformationScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final paddings = MediaQuery.of(context).padding;
    final bool isSmall = size.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 12.0 : 16.0,
                vertical: 8.0,
              ),
              child: _buildHeaderBar(isSmall),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - paddings.top - paddings.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _buildAppBadge(),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text('Maternal Health App',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            )),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text('Version 1.2.3',
                            style: TextStyle(color: AppTheme.textGray)),
                      ),
                      const SizedBox(height: 20),
                      _sectionCard(children: [
                        _tile(Icons.article_outlined, 'Terms of Service', onTap: () {}),
                        const Divider(height: 1),
                        _tile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {}),
                        const Divider(height: 1),
                        _tile(Icons.support_agent_outlined, 'Contact & Support', onTap: () {}),
                        const Divider(height: 1),
                        _tile(Icons.receipt_long_outlined, 'Licenses', onTap: () {}),
                      ]),
                      const SizedBox(height: 24),
                      // Example bright button similar to signup
                      SizedBox(
                        height: 48,
                        child: GradientButton(
                          text: 'Check for Updates',
                          startColor: AppTheme.brightBlue,
                          endColor: AppTheme.brightPink,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          '© 2025 Maternal Health Inc. All rights reserved.',
                          style: TextStyle(color: AppTheme.textGray),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar(bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, size: isSmall ? 20 : 24, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        const Text('App Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAppBadge() {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(colors: [Color(0xFFE9F2FF), Color(0xFFFCE4EC)]),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6)),
          ],
        ),
        child: const Center(
          child: Icon(Icons.health_and_safety_outlined, color: Color(0xFF6C63FF), size: 36),
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 8))],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile(IconData icon, String label, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(label, style: const TextStyle(color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black45),
      onTap: onTap,
    );
  }
}


