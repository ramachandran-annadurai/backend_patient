import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
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
                      const SizedBox(height: 8),
                      _buildProfileCard(),
                      const SizedBox(height: 20),
                      const Text('Account', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(height: 12),
                      _settingsTile(icon: Icons.person, label: 'Edit Profile', onTap: () => Navigator.pushNamed(context, '/edit-profile')),
                      const SizedBox(height: 8),
                      _settingsTile(
                        icon: Icons.notifications_none,
                        label: 'Notifications settings',
                        onTap: () => Navigator.pushNamed(context, '/notification-settings'),
                      ),
                      const SizedBox(height: 20),
                      const Text('Clinic', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(height: 12),
                      _settingsTile(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacy Settings',
                          onTap: () => Navigator.pushNamed(context, '/privacy-settings')),
                      const SizedBox(height: 8),
                      _settingsTile(icon: Icons.group_outlined, label: 'User Management', onTap: () {}),
                      const SizedBox(height: 8),
                      _settingsTile(icon: Icons.bar_chart_outlined, label: 'Reports & Analytics', onTap: () {}),
                      const SizedBox(height: 8),
                      _settingsTile(icon: Icons.info_outline, label: 'App Information', onTap: () => Navigator.pushNamed(context, '/app-information')),
                      const SizedBox(height: 8),
                      _settingsTile(icon: Icons.policy_outlined, label: 'Privacy policy', onTap: () => Navigator.pushNamed(context, '/privacy-policy')),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: GradientButton(
                            text: 'Logout',
                            startColor: AppTheme.brightBlue,
                            endColor: AppTheme.brightPink,
                            onPressed: () {},
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
        const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.blueGrey.shade200),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Jessica Alba', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                SizedBox(height: 2),
                Text('Patient ID: 123456', style: TextStyle(color: AppTheme.textGray)),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({required IconData icon, required String label, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGray),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: const Color(0xFFE9F2FF), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF6C63FF)),
        ),
        title: Text(label, style: const TextStyle(color: Colors.black87)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45),
        onTap: onTap,
      ),
    );
  }
}


