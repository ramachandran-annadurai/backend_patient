import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _shareHealth = true;
  bool _anonResearch = false;
  String _profileVisibility = 'Providers Only';
  bool _searchVisibility = true;
  bool _appointmentReminders = true;
  bool _healthTips = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 12.0 : 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, isSmall),
                SizedBox(height: isSmall ? 16 : 20),

                _groupTitle('Data Sharing'),
                _card(children: [
                  _switchTile(
                    title: 'Share Health Data',
                    subtitle: 'With your primary healthcare provider.',
                    value: _shareHealth,
                    onChanged: (v) => setState(() => _shareHealth = v),
                  ),
                  const Divider(height: 1),
                  _switchTile(
                    title: 'Anonymized Research Data',
                    subtitle: 'Contribute to maternal health research.',
                    value: _anonResearch,
                    onChanged: (v) => setState(() => _anonResearch = v),
                  ),
                ]),

                SizedBox(height: 16),
                _groupTitle('Profile Visibility'),
                _card(children: [
                  _navTile(
                    title: 'Profile Visibility',
                    trailing: _profileVisibility,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _switchTile(
                    title: 'Search Visibility',
                    subtitle: 'Appear in search results.',
                    value: _searchVisibility,
                    onChanged: (v) => setState(() => _searchVisibility = v),
                  ),
                ]),

                SizedBox(height: 16),
                _groupTitle('Notification Settings'),
                _card(children: [
                  _switchTile(
                    title: 'Appointment Reminders',
                    value: _appointmentReminders,
                    onChanged: (v) => setState(() => _appointmentReminders = v),
                  ),
                  const Divider(height: 1),
                  _switchTile(
                    title: 'Health Tips',
                    value: _healthTips,
                    onChanged: (v) => setState(() => _healthTips = v),
                  ),
                ]),

                SizedBox(height: 16),
                _groupTitle('Account Management'),
                _card(children: [
                  _dangerNavTile(title: 'Delete My Account', onTap: () {}),
                ]),

                SizedBox(height: isSmall ? 20 : 24),
                _saveButton(size),
                SizedBox(height: isSmall ? 80 : 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, size: isSmall ? 20 : 24, color: Colors.black87),
        ),
        const Text('Privacy Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 24, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _groupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(subtitle, style: const TextStyle(color: AppTheme.textGray)),
                  ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppTheme.brightBlue),
        ],
      ),
    );
  }

  Widget _navTile({required String title, required String trailing, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Who can see your profile.', style: TextStyle(color: AppTheme.textGray)),
                ],
              ),
            ),
            Text(trailing, style: const TextStyle(color: Colors.black87)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _dangerNavTile({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: const [
            Expanded(
              child: Text('Delete My Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.chevron_right, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _saveButton(Size size) {
    return Center(
      child: Container(
        width: size.width - 80,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.brightBlue, AppTheme.brightPink]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brightBlue.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {},
            child: const Center(
              child: Text('Save Preferences', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}


