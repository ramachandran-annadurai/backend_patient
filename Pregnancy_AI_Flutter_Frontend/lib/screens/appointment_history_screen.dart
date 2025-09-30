import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

enum AppointmentType { inPerson, video }

class AppointmentItem {
  final DateTime dateTime;
  final String doctor;
  final AppointmentType type;

  AppointmentItem({required this.dateTime, required this.doctor, required this.type});
}

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final paddings = MediaQuery.of(context).padding;
    final bool isSmall = size.width < 360;

    // Sample data
    final completed = [
      AppointmentItem(dateTime: DateTime(2024, 5, 15, 10, 0), doctor: 'Dr. Amelia Carter', type: AppointmentType.inPerson),
      AppointmentItem(dateTime: DateTime(2024, 4, 20, 14, 30), doctor: 'Dr. Amelia Carter', type: AppointmentType.video),
    ];
    final rejected = [
      AppointmentItem(dateTime: DateTime(2024, 3, 5, 11, 0), doctor: 'Dr. Amelia Carter', type: AppointmentType.inPerson),
    ];
    final notAttended = [
      AppointmentItem(dateTime: DateTime(2024, 2, 10, 9, 0), doctor: 'Dr. Amelia Carter', type: AppointmentType.video),
      AppointmentItem(dateTime: DateTime(2024, 2, 10, 9, 0), doctor: 'Dr. Amelia Carter', type: AppointmentType.video),
    ];

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
                      _buildSearchBar(onFilterTap: () => _showFilterDialog(context)),
                      const SizedBox(height: 16),
                      _buildSection(title: 'Completed Visits', items: completed),
                      const SizedBox(height: 16),
                      _buildSection(title: 'Rejected Visits', items: rejected),
                      const SizedBox(height: 16),
                      _buildSection(title: 'Not Attended Visits', items: notAttended),
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
          icon: Icon(Icons.arrow_back, size: isSmall ? 20 : 24, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'Appointment History',
          style: TextStyle(fontSize: isSmall ? 18 : 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar({required VoidCallback onFilterTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGray),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.textGray),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search History...',
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.lightGray),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.tune, color: AppTheme.textGray, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<AppointmentItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        ...items.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAppointmentCard(e),
            )),
      ],
    );
  }

  Widget _buildAppointmentCard(AppointmentItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFFFE0EB), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_month, color: Color(0xFFFF6B9D)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDateTime(item.dateTime), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(item.doctor, style: const TextStyle(color: AppTheme.textGray)),
                ],
              ),
            ),
            Text(
              item.type == AppointmentType.inPerson ? 'In-person' : 'Video call',
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${monthNames[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute $ampm';
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
          icon: Icon(Icons.arrow_back, size: isSmall ? 20 : 24, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'Appointment History',
          style: TextStyle(fontSize: isSmall ? 18 : 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onFilterTap;
  const _SearchBar({required this.onFilterTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGray),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.textGray),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search History...',
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.lightGray),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.tune, color: AppTheme.textGray, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<AppointmentItem> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        ...items.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AppointmentCard(item: e),
            )),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentItem item;
  const _AppointmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFFFE0EB), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_month, color: Color(0xFFFF6B9D)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDateTime(item.dateTime), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(item.doctor, style: const TextStyle(color: AppTheme.textGray)),
                ],
              ),
            ),
            Text(
              item.type == AppointmentType.inPerson ? 'In-person' : 'Video call',
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${monthNames[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute $ampm';
  }
}

void _showFilterDialog(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  final double dialogWidth = screenSize.width * 0.92;

  bool upcoming = false;
  bool completed = true;
  bool cancelled = false;
  String apptType = 'Consultation';
  String sortBy = 'Newest first';
  int quickRange = 1; // 0:30d, 1:this year, 2:custom

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dialogWidth),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filter & Sort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Appointment Status', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _checkboxTile('Upcoming', upcoming, (v) => setState(() => upcoming = v ?? false)),
                      _checkboxTile('Completed', completed, (v) => setState(() => completed = v ?? false)),
                      _checkboxTile('Cancelled', cancelled, (v) => setState(() => cancelled = v ?? false)),
                      const SizedBox(height: 12),
                      const Text('Appointment Type', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: apptType,
                        items: const [
                          DropdownMenuItem(value: 'Consultation', child: Text('Consultation')),
                          DropdownMenuItem(value: 'Follow-up', child: Text('Follow-up')),
                          DropdownMenuItem(value: 'Scan', child: Text('Scan')),
                        ],
                        onChanged: (v) => setState(() => apptType = v ?? apptType),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Date Range', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select Date Range',
                          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Last 30 days'),
                            selected: quickRange == 0,
                            onSelected: (_) => setState(() => quickRange = 0),
                          ),
                          ChoiceChip(
                            label: const Text('This year'),
                            selected: quickRange == 1,
                            onSelected: (_) => setState(() => quickRange = 1),
                          ),
                          ChoiceChip(
                            label: const Text('Custom'),
                            selected: quickRange == 2,
                            onSelected: (_) => setState(() => quickRange = 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: sortBy,
                        items: const [
                          DropdownMenuItem(value: 'Newest first', child: Text('Newest first')),
                          DropdownMenuItem(value: 'Oldest first', child: Text('Oldest first')),
                        ],
                        onChanged: (v) => setState(() => sortBy = v ?? sortBy),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  upcoming = false;
                                  completed = false;
                                  cancelled = false;
                                  apptType = 'Consultation';
                                  sortBy = 'Newest first';
                                  quickRange = 1;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Clear All'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Apply Filters'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _checkboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
  return Row(
    children: [
      Expanded(child: Text(label)),
      Checkbox(
        value: value,
        onChanged: onChanged,
        side: const BorderSide(color: AppTheme.textGray),
      ),
    ],
  );
}


