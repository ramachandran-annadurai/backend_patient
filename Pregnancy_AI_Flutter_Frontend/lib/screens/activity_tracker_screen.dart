import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../utils/date_utils.dart';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({super.key});

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
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
                    minHeight:
                        size.height - paddings.top - paddings.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      _buildSummaryCard(),

                      const SizedBox(height: 16),

                      _buildExerciseLibraryCard(),

                      const SizedBox(height: 16),

                      _buildLogDetailsCard(),

                      const SizedBox(height: 16),

                      _buildTodayActivitiesCard(),

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
              'Activity Tracker',
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
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.equalizer,
            size: isSmall ? 20.0 : 22.0,
            color: Colors.black87,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
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
          Text('Today, July 23, 2023', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: 18 / 30,
                    strokeWidth: 10,
                    color: Colors.green,
                    backgroundColor: Colors.green.withOpacity(0.15),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('18', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.green, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('min / 30 min goal', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text("You've reached 60% of your daily goal!", style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Log Your Activity', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(Icons.directions_walk, 'Walking'),
              _buildQuickAction(Icons.self_improvement, 'Yoga'),
              _buildQuickAction(Icons.pool, 'Swimming'),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: () {}, child: const Text('Log Other Activity')),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
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
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseLibraryCard() {
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
          Text('Exercise Library', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _chip('All Trimesters', selected: true),
              _chip('1st Trimester'),
              _chip('2nd Trimester'),
            ],
          ),
          const SizedBox(height: 16),
          _exerciseTile('Pelvic Tilts', 'Core Strength', '5 min'),
          const SizedBox(height: 10),
          _exerciseTile('Kegels', 'Pelvic Floor', '3 min'),
          const SizedBox(height: 10),
          _exerciseTile('Light Walking', 'Cardio', '15 min'),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: () {}, child: const Text('See More Exercises'))),
        ],
      ),
    );
  }

  Widget _chip(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.lightPink.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppTheme.brightPink : AppTheme.textGray,
        ),
      ),
    );
  }

  Widget _exerciseTile(String title, String subtitle, String duration) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.play_circle_outline, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
              Text(duration, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textGray)),
            ],
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.lightPink.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: AppTheme.brightPink, size: 18),
        ),
      ],
    );
  }

  Widget _buildLogDetailsCard() {
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
          Text('Log Activity Details', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          _styledText('Duration (minutes)'),
          const SizedBox(height: 6),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g., 30',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          _styledText('Intensity'),
          const SizedBox(height: 8),
          Row(
            children: [
              _intensityChip('Light', selected: false),
              const SizedBox(width: 8),
              _intensityChip('Moderate', selected: true),
              const SizedBox(width: 8),
              _intensityChip('Vigorous', selected: false),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: GradientButton(
              text: 'Log Activity',
              startColor: AppTheme.brightBlue,
              endColor: AppTheme.brightPink,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledText(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textGray,
          ),
    );
  }

  Widget _intensityChip(String label, {required bool selected}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.lightPink.withOpacity(0.25) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightGray),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected ? AppTheme.brightPink : AppTheme.textGray,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayActivitiesCard() {
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
          Text("Today's Activities", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          _historyTile(Icons.directions_walk, 'Walking', '10 mins - Light', '10:45 AM'),
          const SizedBox(height: 8),
          _historyTile(Icons.self_improvement, 'Prenatal Yoga', '8 mins - Moderate', '09:12 AM'),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: () {}, child: const Text('View Full History'))),
        ],
      ),
    );
  }

  Widget _historyTile(IconData icon, String title, String subtitle, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(BorderSide(color: AppTheme.lightGray)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.brightPink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
              ],
            ),
          ),
          Text(time, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
        ],
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final bool isSmall;
  const _HeaderBar({required this.isSmall});

  @override
  Widget build(BuildContext context) {
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
              'Activity Tracker',
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
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.equalizer,
            size: isSmall ? 20.0 : 22.0,
            color: Colors.black87,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Text('Today, July 23, 2023', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          // Circular progress look
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: 18 / 30,
                    strokeWidth: 10,
                    color: Colors.green,
                    backgroundColor: Colors.green.withOpacity(0.15),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('18', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.green, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('min / 30 min goal', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text("You've reached 60% of your daily goal!", style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Log Your Activity', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _QuickAction(icon: Icons.directions_walk, label: 'Walking'),
              _QuickAction(icon: Icons.self_improvement, label: 'Yoga'),
              _QuickAction(icon: Icons.pool, label: 'Swimming'),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: () {}, child: const Text('Log Other Activity')),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
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
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ExerciseLibraryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Text('Exercise Library', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _chip('All Trimesters', selected: true),
              _chip('1st Trimester'),
              _chip('2nd Trimester'),
            ],
          ),
          const SizedBox(height: 16),
          _exerciseTile(context, 'Pelvic Tilts', 'Core Strength', '5 min'),
          const SizedBox(height: 10),
          _exerciseTile(context, 'Kegels', 'Pelvic Floor', '3 min'),
          const SizedBox(height: 10),
          _exerciseTile(context, 'Light Walking', 'Cardio', '15 min'),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: () {}, child: const Text('See More Exercises'))),
        ],
      ),
    );
  }

  Widget _chip(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.lightPink.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppTheme.brightPink : AppTheme.textGray,
        ),
      ),
    );
  }

  Widget _exerciseTile(BuildContext context, String title, String subtitle, String duration) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.play_circle_outline, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
              Text(duration, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textGray)),
            ],
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.lightPink.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: AppTheme.brightPink, size: 18),
        ),
      ],
    );
  }
}

class _LogDetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Text('Log Activity Details', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text('Duration (minutes)')
              .applyDefaultTextStyle(context),
          const SizedBox(height: 6),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g., 30',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Text('Intensity').applyDefaultTextStyle(context),
          const SizedBox(height: 8),
          Row(
            children: [
              _intensityChip(context, 'Light', selected: false),
              const SizedBox(width: 8),
              _intensityChip(context, 'Moderate', selected: true),
              const SizedBox(width: 8),
              _intensityChip(context, 'Vigorous', selected: false),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: GradientButton(
              text: 'Log Activity',
              startColor: AppTheme.brightBlue,
              endColor: AppTheme.brightPink,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _intensityChip(BuildContext context, String label,
      {required bool selected}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.lightPink.withOpacity(0.25) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightGray),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected ? AppTheme.brightPink : AppTheme.textGray,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }
}

class _TodayActivitiesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Text("Today's Activities", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          _historyTile(context, Icons.directions_walk, 'Walking', '10 mins - Light', '10:45 AM'),
          const SizedBox(height: 8),
          _historyTile(context, Icons.self_improvement, 'Prenatal Yoga', '8 mins - Moderate', '09:12 AM'),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: () {}, child: const Text('View Full History'))),
        ],
      ),
    );
  }

  Widget _historyTile(BuildContext context, IconData icon, String title, String subtitle, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(BorderSide(color: AppTheme.lightGray)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.brightPink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
              ],
            ),
          ),
          Text(time, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
        ],
      ),
    );
  }
}

extension on Text {
  Text applyDefaultTextStyle(BuildContext context) {
    return Text(
      data ?? '',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textGray,
          ),
    );
  }
}


