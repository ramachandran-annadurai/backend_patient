import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medical_record_provider.dart';
import '../widgets/medical_form_section.dart';
import '../widgets/loading_overlay.dart';

class MedicalRecordFormScreen extends StatelessWidget {
  const MedicalRecordFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medical Record'),
        centerTitle: true,
        actions: [
          Consumer<MedicalRecordProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.wifi_find),
                onPressed: () async {
                  bool connected = await provider.testBackendConnection();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(connected 
                          ? '✅ Backend connection successful!' 
                          : '❌ Backend connection failed'),
                        backgroundColor: connected ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                tooltip: 'Test Backend Connection',
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'DEBUG',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<MedicalRecordProvider>(
        builder: (context, provider, child) {
          return LoadingOverlay(
            isLoading: provider.isLoading,
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medical Information',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your medical details below',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Error Display Section
                    if (provider.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Error: ${provider.error}',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              onPressed: () {
                                provider.clearError();
                              },
                              tooltip: 'Clear Error',
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Form Sections
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        children: [
                          // Medical Conditions
                          MedicalFormSection(
                            title: 'Medical Conditions',
                            fieldName: 'medicalConditions',
                            placeholder: 'e.g., Diabetes, Hypertension, Asthma',
                            icon: Icons.medical_services,
                            iconColor: const Color(0xFF4CAF50),
                            hintText: 'Upload PDF, images, or text files to automatically extract medical information.',
                          ),
                          
                          // Allergies & Sensitivities
                          MedicalFormSection(
                            title: 'Allergies & Sensitivities',
                            fieldName: 'allergies',
                            placeholder: 'e.g., Penicillin, Shellfish, Pollen',
                            icon: Icons.warning,
                            iconColor: Colors.orange,
                            hintText: 'Upload PDF, images, or text files to automatically extract medical information.',
                          ),
                          
                          // Current Medications
                          MedicalFormSection(
                            title: 'Current Medications',
                            fieldName: 'currentMedications',
                            placeholder: 'e.g., Metformin 500mg twice daily, Lisinopril 10mg once daily',
                            icon: Icons.medication,
                            iconColor: Colors.blue,
                            hintText: 'Upload PDF, images, or text files to automatically extract medical information.',
                          ),
                          
                          // Previous Pregnancies
                          MedicalFormSection(
                            title: 'Previous Pregnancies',
                            fieldName: 'previousPregnancies',
                            placeholder: 'e.g., 2 pregnancies, 1 miscarriage, gestational diabetes',
                            icon: Icons.pregnant_woman,
                            iconColor: Colors.pink,
                            hintText: 'Upload PDF, images, or text files to automatically extract medical information.',
                          ),
                          
                          // Family Health History
                          MedicalFormSection(
                            title: 'Family Health History',
                            fieldName: 'familyHealthHistory',
                            placeholder: 'e.g., Mother: diabetes, Father: heart disease, Grandmother: cancer',
                            icon: Icons.family_restroom,
                            iconColor: Colors.purple,
                            hintText: 'Upload PDF, images, or text files to automatically extract medical information.',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : () => _saveMedicalRecord(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Medical Record',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Information Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your medical information will be stored securely and can be used to generate health summaries and track your medical history.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveMedicalRecord(BuildContext context, MedicalRecordProvider provider) async {
    if (!provider.hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one medical detail before saving.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await provider.saveMedicalRecord();

    if (context.mounted) {
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical record saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
