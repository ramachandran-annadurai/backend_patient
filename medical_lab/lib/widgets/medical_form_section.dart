import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/medical_record_provider.dart';
import 'dart:io';

class MedicalFormSection extends StatefulWidget {
  final String title;
  final String fieldName;
  final String placeholder;
  final IconData icon;
  final Color iconColor;
  final String hintText;

  const MedicalFormSection({
    super.key,
    required this.title,
    required this.fieldName,
    required this.placeholder,
    required this.icon,
    required this.iconColor,
    required this.hintText,
  });

  @override
  State<MedicalFormSection> createState() => _MedicalFormSectionState();
}

class _MedicalFormSectionState extends State<MedicalFormSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalRecordProvider>(
      builder: (context, provider, child) {
        // Update controller text when provider value changes
        String? currentValue = provider.getFieldValue(widget.fieldName);
        if (_controller.text != (currentValue ?? '')) {
          _controller.text = currentValue ?? '';
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                  Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  // Upload Button
                  ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : () => _pickFile(context, provider),
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text('Upload', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Text Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  controller: _controller,
                  onChanged: (value) {
                    switch (widget.fieldName) {
                      case 'medicalConditions':
                        provider.updateMedicalConditions(value);
                        break;
                      case 'allergies':
                        provider.updateAllergies(value);
                        break;
                      case 'currentMedications':
                        provider.updateCurrentMedications(value);
                        break;
                      case 'previousPregnancies':
                        provider.updatePreviousPregnancies(value);
                        break;
                      case 'familyHealthHistory':
                        provider.updateFamilyHealthHistory(value);
                        break;
                    }
                  },
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: Icon(
                      widget.icon,
                      color: widget.iconColor.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Hint Text
              Text(
                widget.hintText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              
              // Show uploaded file info if available
              if (provider.uploadedFiles.containsKey(widget.fieldName))
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'File processed: ${provider.uploadedFiles[widget.fieldName]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile(BuildContext context, MedicalRecordProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'bmp', 'tiff'],
        allowMultiple: false,
        withData: true, // This ensures we get file bytes for web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Processing file with OCR...'),
              ],
            ),
          ),
        );

        try {
          // Upload file bytes directly to PaddleOCR backend
          await provider.uploadFileBytesForOCR(file.bytes!, file.name, widget.fieldName);
        } catch (e) {
          // Close loading dialog
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          
          // Show error
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing file: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Show result
        if (context.mounted) {
          if (provider.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${provider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File "${file.name}" processed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}