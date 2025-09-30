import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient_profile_response.dart';
import '../../providers/profile_provider.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({Key? key}) : super(key: key);

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  Future<void> _refreshProfile() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshProfile,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return _buildLoadingWidget();
          }

          if (profileProvider.error != null) {
            return _buildErrorWidget(profileProvider.error!);
          }

          if (profileProvider.profile == null) {
            return _buildEmptyProfileWidget();
          }

          return _buildProfileContent(profileProvider.profile!);
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your profile...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProfileWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              color: Colors.grey,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No Profile Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please complete your profile first.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/profile-completion');
              },
              icon: const Icon(Icons.add),
              label: const Text('Complete Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(PatientProfileResponse profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.purple.shade100,
                    child: Text(
                      _getInitials(profile.profile),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFullName(profile.profile),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Week ${profile.profile.pregnancyWeek}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purple.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Personal Information
          _buildSectionCard('Personal Information', [
            _buildInfoRow('Blood Type', profile.profile.bloodType),
            _buildInfoRow('Date of Birth', profile.profile.dateOfBirth),
            _buildInfoRow('Height', profile.profile.height),
            _buildInfoRow('Weight', profile.profile.weight),
          ]),
          const SizedBox(height: 16),

          // Pregnancy Information
          _buildSectionCard('Pregnancy Information', [
            _buildInfoRow(
                'Pregnant', profile.profile.isPregnant ? 'Yes' : 'No'),
            _buildInfoRow('Last Period Date', profile.profile.lastPeriodDate),
            _buildInfoRow(
                'Pregnancy Week', profile.profile.pregnancyWeek.toString()),
            _buildInfoRow(
                'Expected Delivery', profile.profile.expectedDeliveryDate),
          ]),
          const SizedBox(height: 16),

          // Emergency Contact
          _buildSectionCard('Emergency Contact', [
            _buildInfoRow('Name', profile.profile.emergencyContact.name),
            _buildInfoRow(
                'Relationship', profile.profile.emergencyContact.relationship),
            _buildInfoRow('Phone', profile.profile.emergencyContact.phone),
          ]),
          const SizedBox(height: 24),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/profile-completion');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(PatientProfile profile) {
    final firstName = profile.firstName;
    final lastName = profile.lastName;

    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();

    return initials.isNotEmpty ? initials : 'U';
  }

  String _getFullName(PatientProfile profile) {
    final firstName = profile.firstName;
    final lastName = profile.lastName;

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else {
      return 'User';
    }
  }
}
