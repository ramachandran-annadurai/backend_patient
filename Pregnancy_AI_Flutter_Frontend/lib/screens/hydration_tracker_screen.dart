import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../utils/date_utils.dart';

class HydrationTrackerScreen extends StatefulWidget {
  const HydrationTrackerScreen({super.key});

  @override
  State<HydrationTrackerScreen> createState() => _HydrationTrackerScreenState();
}

class _HydrationTrackerScreenState extends State<HydrationTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    final bool isSmallScreen = screenSize.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header like Food Tracking page
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12.0 : 16.0,
                vertical: 8.0,
              ),
              child: _buildHeaderBar(isSmallScreen),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenSize.height - topPadding - bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // Header Card with circular progress and summary text
                      _buildHeaderCard(),

                      const SizedBox(height: 16),

                      // Goals & Reminders card
                      _buildGoalsRemindersCard(),

                      const SizedBox(height: 16),

                      // Intake History card
                      _buildIntakeHistoryCard(),

                      const SizedBox(height: 24),

                      // Bottom action similar to sign up button style
                      Center(
                        child: GradientButton(
                          text: 'Log Intake',
                          startColor: AppTheme.brightBlue,
                          endColor: AppTheme.brightPink,
                          onPressed: () {},
                        ),
                      ),

                      const SizedBox(height: 24),
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
          icon: Icon(
            Icons.arrow_back,
            size: isSmall ? 20.0 : 24.0,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Column(
          children: [
            Text(
              'Hydration Tracker',
              style: TextStyle(
                fontSize: isSmall ? 18.0 : 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              AppDateUtils.getCurrentDate(),
              style: TextStyle(
                fontSize: isSmall ? 12.0 : 14.0,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.calendar_today,
            size: isSmall ? 20.0 : 24.0,
            color: Colors.black87,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    final width = MediaQuery.of(context).size.width;
    final progressSize = width * 0.42; // responsive circle size

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border.fromBorderSide(BorderSide(color: AppTheme.lightGray)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Today, July 23, 2023',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: progressSize,
            height: progressSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightBlue.withOpacity(0.35),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: progressSize,
                    height: progressSize * 0.6,
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(progressSize),
                        bottom: Radius.circular(progressSize * 0.1),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '6/8',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Glasses',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "You're doing great! Only 2 glasses to go.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Log Your Intake',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(icon: Icons.local_cafe, label: '1 Glass'),
              _buildQuickActionButton(icon: Icons.local_drink, label: '1 Bottle'),
              _buildQuickActionButton(icon: Icons.edit, label: 'Custom'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({required IconData icon, required String label}) {
    return Container(
      width: 96,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(BorderSide(color: AppTheme.lightGray)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textGray),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsRemindersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border.fromBorderSide(BorderSide(color: AppTheme.lightGray)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Goals & Reminders', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Daily Goal',
                    suffixText: 'glasses',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.lightGray),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Enable Reminders', style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
              Switch(value: true, onChanged: (_) {}),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(label: 'Start Time', value: '09:00 AM'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(label: 'End Time', value: '09:00 PM'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdownField(label: 'Frequency', value: 'Every hour'),
        ],
      ),
    );
  }

  Widget _buildTimeField({required String label, required String value}) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: value,
        suffixIcon: const Icon(Icons.access_time),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.lightGray),
        ),
      ),
    );
  }

  Widget _buildDropdownField({required String label, required String value}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.lightGray),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
          const Icon(Icons.expand_more),
        ],
      ),
    );
  }

  Widget _buildIntakeHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border.fromBorderSide(BorderSide(color: AppTheme.lightGray)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Intake History', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          _buildHistoryTile(icon: Icons.water_drop_outlined, title: '1 Glass (250ml)', time: '10:45 AM'),
          const SizedBox(height: 8),
          _buildHistoryTile(icon: Icons.water_drop_outlined, title: '1 Glass (250ml)', time: '09:12 AM'),
          const SizedBox(height: 8),
          _buildHistoryTile(icon: Icons.local_drink_outlined, title: '1 Bottle (500ml)', time: '08:00 AM'),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('View More'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile({required IconData icon, required String title, required String time}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(BorderSide(color: AppTheme.lightGray)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.brightBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray),
                ),
              ],
            ),
          ),
          const Icon(Icons.delete_outline, color: AppTheme.textGray),
        ],
      ),
    );
  }
}

// Inlined previous sub-widgets as methods on the State class to keep a single StatefulWidget.


