import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
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
                      const SizedBox(height: 12),
                      _buildUploadCard(),
                      const SizedBox(height: 24),
                      _buildProcessingSection(),
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
        Column(
          children: [
            Text(
              'Upload Document',
              style: TextStyle(
                fontSize: isSmall ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              AppDateUtils.getCurrentDate(),
              style: TextStyle(fontSize: isSmall ? 12 : 14, color: Colors.grey[600]),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid, width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: Color(0xFF6C63FF), size: 48),
          const SizedBox(height: 16),
          Text('Tap to upload', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Upload a clear image or document', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
          const SizedBox(height: 20),
          Center(
            child: GradientButton(
              text: 'Upload',
              startColor: AppTheme.brightBlue,
              endColor: AppTheme.brightPink,
              onPressed: () {},
              width: 140,
              height: 44,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Processing Status', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.lightGray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Processing...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFFB983FF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text('75%'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

