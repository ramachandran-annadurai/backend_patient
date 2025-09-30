import 'package:flutter/material.dart';
import '../widgets/app_background.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
                SizedBox(height: isSmall ? 16 : 20),
                _title(),
                const SizedBox(height: 12),
                _paragraph(_lorem),
                const SizedBox(height: 16),
                _bullet('The standard chunk of lorem Ipsum used since 1500s is reproduced below for those interested.'),
                const SizedBox(height: 10),
                _bullet('Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum. The point of using."'),
                const SizedBox(height: 10),
                _bullet('Lorem Ipsum is that it has a moreIt is a long established fact reader will distracted.'),
                const SizedBox(height: 10),
                _bullet('The point of using Lorem Ipsum is that it has a moreIt is a long established fact that reader will distracted.'),
                const SizedBox(height: 16),
                _paragraph(_loremShort),
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
        const Text('Privacy policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 24, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _title() {
    return const Text(
      'Pragnancy Apps Privacy Policy',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
    );
  }

  Widget _paragraph(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black54, height: 1.6),
    );
  }

  Widget _bullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7),
          decoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.black54, height: 1.6))),
      ],
    );
  }

  static const String _lorem =
      'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words believable. It is a long established fact that reader will distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a moreIt is a long established fact that reader will distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more';

  static const String _loremShort =
      'It is a long established fact that reader distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a moreIt is a long established.';
}


