import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../widgets/app_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isPregnancyCardExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12.0 : 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                _buildHeader(context, isSmallScreen),
                SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                // Patient Information Card
                _buildPatientInfoCard(context, isSmallScreen),
                SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                // Pregnancy Progress Card (Interactive)
                _buildPregnancyProgressCard(context, isSmallScreen),

                // Expandable Content
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isPregnancyCardExpanded ? null : 0,
                  child: _isPregnancyCardExpanded
                      ? Column(
                          children: [
                            SizedBox(height: isSmallScreen ? 16.0 : 20.0),
                            // Key Developments This Week
                            _buildKeyDevelopmentsCard(context, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 16.0 : 20.0),
                            // Quick Actions for Trimester 1
                            _buildQuickActionsCard(context, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 16.0 : 20.0),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // Doctor Information Card
                _buildDoctorInfoCard(context, isSmallScreen),
                SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                // Key Information Section
                _buildKeyInformationSection(context, isSmallScreen),
                SizedBox(
                    height: isSmallScreen
                        ? 80.0
                        : 100.0), // Bottom padding for navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          Icons.menu,
          size: isSmallScreen ? 20.0 : 24.0,
          color: Colors.black87,
        ),
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: isSmallScreen ? 18.0 : 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/emergency'),
              icon: Icon(
                Icons.emergency,
                size: isSmallScreen ? 20.0 : 24.0,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: isSmallScreen ? 20.0 : 24.0,
                  color: Colors.black87,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientInfoCard(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: isSmallScreen ? 60.0 : 70.0,
                height: isSmallScreen ? 60.0 : 70.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Icon(
                  Icons.person,
                  size: isSmallScreen ? 30.0 : 35.0,
                  color: Colors.grey[600],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: isSmallScreen ? 12.0 : 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jessica Alba',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16.0 : 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Patient ID: 123456',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12.0 : 14.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                _buildInfoRow('Age: 32', isSmallScreen),
                _buildInfoRow('Blood Type: O+', isSmallScreen),
                _buildInfoRow(
                    'Last Menstrual Period: May 29, 2023', isSmallScreen),
                _buildInfoRow(
                    'Expected Delivery Date: March 04, 2024', isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSmallScreen ? 11.0 : 12.0,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildPregnancyProgressCard(BuildContext context, bool isSmallScreen) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPregnancyCardExpanded = !_isPregnancyCardExpanded;
        });
      },
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Pregnancy Progress',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16.0 : 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isPregnancyCardExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.white,
                  size: isSmallScreen ? 20.0 : 24.0,
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16.0 : 20.0),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: isSmallScreen ? 80.0 : 100.0,
                        height: isSmallScreen ? 80.0 : 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Text(
                            '10\nWeeks',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14.0 : 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '210 days remaining',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12.0 : 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.child_care,
                        size: isSmallScreen ? 60.0 : 80.0,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Baby Size: Coconut',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12.0 : 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyDevelopmentsCard(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Developments This Week',
            style: TextStyle(
              fontSize: isSmallScreen ? 16.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildDevelopmentItem(
            Icons.favorite,
            Colors.red,
            'Healthy Organ Growth',
            'Vital organs are fully developed.',
            isSmallScreen,
          ),
          SizedBox(height: 12),
          _buildDevelopmentItem(
            Icons.pets,
            Colors.brown,
            'Finger & Toe Development',
            'Eyebrows and eyelids are now fully present.',
            isSmallScreen,
          ),
          SizedBox(height: 12),
          _buildDevelopmentItem(
            Icons.child_care,
            Colors.orange,
            'Teeth Formation Begins',
            'Teeth are starting to form under the gums.',
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentItem(
    IconData icon,
    Color color,
    String title,
    String description,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: isSmallScreen ? 20.0 : 24.0),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14.0 : 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12.0 : 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions for Trimester 1',
            style: TextStyle(
              fontSize: isSmallScreen ? 16.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Early Symptoms',
                  Icons.sentiment_dissatisfied,
                  Colors.red,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Prenatal Screening',
                  Icons.science,
                  Colors.blue,
                  isSmallScreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Wellness Tips',
                  Icons.lightbulb,
                  Colors.green,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Nutrition Tips',
                  Icons.apple,
                  Colors.orange,
                  isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 24.0 : 28.0),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 11.0 : 12.0,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoCard(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: isSmallScreen ? 60.0 : 70.0,
                height: isSmallScreen ? 60.0 : 70.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: Icon(
                  Icons.person,
                  size: isSmallScreen ? 30.0 : 35.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: isSmallScreen ? 12.0 : 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Luke Whitesell',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16.0 : 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Specialist Cardiology',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '7 Years experience',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12.0 : 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '57%',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10.0 : 12.0,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '76 Patient Stories',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10.0 : 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.favorite,
                color: Colors.red,
                size: isSmallScreen ? 20.0 : 24.0,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Available',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12.0 : 14.0,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '11:00 AM tomorrow',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12.0 : 14.0,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.videocam, size: isSmallScreen ? 16.0 : 18.0),
                label: Text(
                  'Join Call',
                  style: TextStyle(fontSize: isSmallScreen ? 12.0 : 14.0),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12.0 : 16.0,
                    vertical: isSmallScreen ? 8.0 : 12.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInformationSection(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Information',
          style: TextStyle(
            fontSize: isSmallScreen ? 16.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _buildInfoButton(
                'Daily Records', Icons.receipt, Colors.blue, isSmallScreen),
            _buildInfoButton('Medical Records', Icons.medical_services,
                Colors.purple, isSmallScreen),
            _buildInfoButton('Appointments', Icons.calendar_today,
                Colors.orange, isSmallScreen),
            _buildInfoButton(
                'Alerts', Icons.notifications, Colors.red, isSmallScreen),
            _buildInfoButton(
                'Ambulance', Icons.local_hospital, Colors.red, isSmallScreen),
            _buildInfoButton('Nearby clinics', Icons.location_on, Colors.teal,
                isSmallScreen),
          ],
        ),
      ],
    );
  }

  void _handleInfoButtonTap(String title) {
    switch (title) {
      case 'Daily Records':
        Navigator.pushNamed(context, '/patient-daily-log');
        break;
      case 'Medical Records':
        Navigator.pushNamed(context, '/medical-records');
        break;
      case 'Appointments':
        Navigator.pushNamed(context, '/appointments-overview');
        break;
      case 'Alerts':
        Navigator.pushNamed(context, '/alerts');
        break;
      case 'Ambulance':
        // TODO: Navigate to ambulance
        break;
      case 'Nearby clinics':
        // TODO: Navigate to nearby clinics
        break;
      default:
        break;
    }
  }

  Widget _buildInfoButton(
      String title, IconData icon, Color color, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleInfoButtonTap(title),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 24.0 : 28.0,
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10.0 : 12.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
