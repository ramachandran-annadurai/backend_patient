import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Jessica Alba');
  final TextEditingController _ageController = TextEditingController(text: '30');
  String _bloodGroup = 'O+';
  final TextEditingController _addressController = TextEditingController(text: '123 Wellness Ave, Suite 100');
  final TextEditingController _phoneController = TextEditingController(text: '(123) 456-7890');

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
                      _buildProfileHeader(),
                      const SizedBox(height: 20),
                      const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(height: 12),
                      _textField(label: 'Full Name', controller: _nameController, keyboardType: TextInputType.name),
                      const SizedBox(height: 12),
                      _textField(label: 'Age', controller: _ageController, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      _bloodGroupField(),
                      const SizedBox(height: 12),
                      _textField(label: 'Address', controller: _addressController, keyboardType: TextInputType.streetAddress),
                      const SizedBox(height: 12),
                      _textField(label: 'Contact Phone', controller: _phoneController, keyboardType: TextInputType.phone),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: GradientButton(
                          text: 'Save Changes',
                          startColor: AppTheme.brightBlue,
                          endColor: AppTheme.brightPink,
                          onPressed: () {},
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
        const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(radius: 44, backgroundColor: Color(0xFFCFD8DC)),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Jessica Alba', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 4),
        const Text('Patient ID: 123456', style: TextStyle(color: AppTheme.textGray)),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _textField({required String label, required TextEditingController controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightGray),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bloodGroupField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Blood Group', style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightGray),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _bloodGroup,
              items: const [
                DropdownMenuItem(value: 'A+', child: Text('A+')),
                DropdownMenuItem(value: 'A-', child: Text('A-')),
                DropdownMenuItem(value: 'B+', child: Text('B+')),
                DropdownMenuItem(value: 'B-', child: Text('B-')),
                DropdownMenuItem(value: 'O+', child: Text('O+')),
                DropdownMenuItem(value: 'O-', child: Text('O-')),
                DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                DropdownMenuItem(value: 'AB-', child: Text('AB-')),
              ],
              onChanged: (v) => setState(() => _bloodGroup = v ?? _bloodGroup),
            ),
          ),
        ),
      ],
    );
  }
}


