import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class AmbulanceLocationScreen extends StatefulWidget {
  const AmbulanceLocationScreen({super.key});

  @override
  State<AmbulanceLocationScreen> createState() =>
      _AmbulanceLocationScreenState();
}

class _AmbulanceLocationScreenState extends State<AmbulanceLocationScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isSmall = size.width < 360;

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
                SizedBox(height: isSmall ? 12 : 16),
                _mapPlaceholder(size, isSmall),
                SizedBox(height: isSmall ? 12 : 16),
                _bottomCard(isSmall),
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
          icon: Icon(Icons.arrow_back,
              size: isSmall ? 20 : 24, color: Colors.black87),
        ),
        const Text(
          'Ambulance Location',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_horiz,
              size: isSmall ? 20 : 24, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _mapPlaceholder(Size size, bool isSmall) {
    return Container(
      height: size.height * 0.35,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/map_placeholder.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _circleIcon(Icons.add),
                const SizedBox(height: 8),
                _circleIcon(Icons.remove),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _pin(isSmall, color: Colors.red, label: 'Ambulance'),
                const SizedBox(height: 16),
                _pin(isSmall,
                    color: AppTheme.brightBlue, label: 'Your Location'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.black87),
    );
  }

  Widget _pin(bool isSmall, {required Color color, required String label}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_pin, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _bottomCard(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '5 Mins',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: isSmall ? 28 : 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Estimated Arrival Time',
                  style: TextStyle(
                      color: AppTheme.textGray, fontSize: isSmall ? 12 : 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _roundPill('SOS', Colors.red),
              const SizedBox(width: 8),
              _roundIcon(Icons.phone, AppTheme.brightBlue),
            ],
          ),
          const SizedBox(height: 16),
          _driverTile(isSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _infoCell('Ambulance ID', 'MED-2468')),
              const SizedBox(width: 12),
              Expanded(
                  child: _infoCell('Destination', 'City General Hospital')),
            ],
          ),
          const SizedBox(height: 16),
          _cancelButton(),
        ],
      ),
    );
  }

  Widget _roundPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _roundIcon(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration:
          BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
      child: Icon(icon, color: color),
    );
  }

  Widget _driverTile(bool isSmall) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange[200],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('David Chen',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const Text('Paramedic',
                    style: TextStyle(color: AppTheme.textGray)),
                Row(
                  children: const [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text('4.9 (12 reviews)',
                        style: TextStyle(color: AppTheme.textGray)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCell(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textGray)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.close),
        label: const Text('Cancel Ambulance'),
      ),
    );
  }
}
