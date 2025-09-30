import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../providers/symptom_analysis_provider.dart';
import '../../models/symptom_analysis_response.dart';
import '../../services/patient_service/get_profile_service.dart';
import '../../services/patient_service/save_symptom_analysis_report_service.dart';
import '../../services/patient_service/get_symptom_analysis_reports_service.dart';
import '../../services/enhanced_voice_service.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_background.dart';
import '../../widgets/gradient_button.dart';
import '../../theme/app_theme.dart';

class PatientSymptomsTrackingScreen extends StatefulWidget {
  final String date;

  const PatientSymptomsTrackingScreen({
    super.key,
    required this.date,
  });

  @override
  State<PatientSymptomsTrackingScreen> createState() =>
      _PatientSymptomsTrackingScreenState();
}

class _PatientSymptomsTrackingScreenState
    extends State<PatientSymptomsTrackingScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _severityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Voice recording related variables
  final EnhancedVoiceService _voiceService = EnhancedVoiceService();
  bool _isRecording = false;
  bool _isTranscribing = false;
  String _transcribedText = '';

  bool _isAnalyzing = false;
  String _errorMessage = '';

  // Analysis-related variables
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _n8nResponse;
  bool _isLoadingPregnancyWeek = false;
  int? _currentPregnancyWeek;

  @override
  void initState() {
    super.initState();
    _loadPatientPregnancyWeek();
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _severityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Load patient's pregnancy week when screen initializes
  Future<void> _loadPatientPregnancyWeek() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      if (userInfo['userId'] != null) {
        final profileResponse =
            await GetProfileService().call(patientId: userInfo['userId']!);

        if (profileResponse.profile.isPregnant ) {
          setState(() {
            _currentPregnancyWeek =
                int.tryParse(profileResponse.profile.pregnancyWeek.toString());
          });
          print('🔍 Loaded pregnancy week: $_currentPregnancyWeek');
        }
      }
    } catch (e) {
      print('⚠️ Could not load pregnancy week: $e');
    } finally {
      // Pregnancy week loading completed
    }
  }

  Future<void> _analyzeSymptoms() async {
    if (_symptomController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your symptoms';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      // Use the pregnancy week loaded from profile or default to 20
      final pregnancyWeek = _currentPregnancyWeek ?? 20;
      print('🔍 Using pregnancy week: $pregnancyWeek');

      // Prepare symptom data for analysis with enhanced context
      final symptomData = {
        'text': _symptomController.text.trim(), // Backend expects 'text' field
        'patient_id': userInfo['userId'] ?? 'unknown',
        'weeks_pregnant': pregnancyWeek, // Dynamic pregnancy week from profile
        'severity': _severityController.text.trim(),
        'notes': _notesController.text.trim(),
        'transcribed_text':
            _transcribedText, // Include transcribed text for reference
        'date': widget.date,
        'userRole': userInfo['userRole'] ?? 'patient',
        'patient_context': {
          'pregnancy_week': pregnancyWeek,
          'trimester': _getTrimester(pregnancyWeek),
          'symptom_date': widget.date,
          'severity_level': _severityController.text.trim(),
          'additional_notes': _notesController.text.trim(),
        }
      };

      // Call the quantum+LLM analysis endpoint
      final response = await _callSymptomAnalysisAPI(symptomData);

      setState(() {
        _isAnalyzing = false;
        if (response == null) {
          _errorMessage = 'Analysis failed';
        } else {
          // Show AI analysis in modal dialog
          _showSymptomAnalysisDialog(response);

          // Save the analysis report to backend
          _saveAnalysisReport(response.toJson(), symptomData);
        }
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error analyzing symptoms: $e';
      });
    }
  }

  Future<SymptomAnalysisResponseModel?> _callSymptomAnalysisAPI(
      Map<String, dynamic> symptomData) async {
    // Use the new SymptomAnalysisProvider
    final provider =
        Provider.of<SymptomAnalysisProvider>(context, listen: false);

    final success = await provider.analyzeSymptom(
      symptomData['text'] ?? '',
      symptomData['patient_id'] ?? '',
      symptomData['weeks_pregnant'] ?? 1,
      symptomData['severity'] ?? '',
      symptomData['notes'],
      symptomData['transcribed_text'],
      symptomData['date'] ?? '',
      symptomData['userRole'] ?? 'patient',
      symptomData['patient_context'] ?? {},
    );

    if (success && provider.analysisResult != null) {
      return provider.analysisResult!;
    } else {
      return null;
    }
  }

  // Show AI analysis results in a modal dialog (similar to second image)
  void _showSymptomAnalysisDialog(SymptomAnalysisResponseModel response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Header with gradient background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.lightBlue, AppTheme.lightPink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Analysis Complete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Your symptoms have been analyzed',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primary Recommendation Card
                      _buildMobileAnalysisCard(
                        'Primary Recommendation',
                        Icons.lightbulb,
                        Colors.blue,
                        [response.primaryRecommendation],
                      ),

                      const SizedBox(height: 16),

                      // Additional Recommendations Card
                      _buildMobileAnalysisCard(
                        'Additional Recommendations',
                        Icons.list_alt,
                        Colors.green,
                        response.additionalRecommendations.take(5).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Red Flags Card (if any)
                      if (response.redFlagsDetected.isNotEmpty)
                        _buildMobileAnalysisCard(
                          'Red Flags Detected',
                          Icons.warning,
                          Colors.red,
                          response.redFlagsDetected,
                        ),

                      if (response.redFlagsDetected.isNotEmpty)
                        const SizedBox(height: 16),

                      // Pregnancy Context Card
                      _buildMobileAnalysisCard(
                        'Pregnancy Context',
                        Icons.pregnant_woman,
                        Colors.pink,
                        [
                          'Week: ${response.pregnancyWeek}',
                          'Trimester: ${response.trimester}',
                          'Analysis Method: ${response.analysisMethod}',
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Disclaimer Card
                      if (response.disclaimer.isNotEmpty)
                        _buildMobileAnalysisCard(
                          'Medical Disclaimer',
                          Icons.info,
                          Colors.orange,
                          [response.disclaimer],
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom action area
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: GradientButton(
                  text: 'Close Analysis',
                  onPressed: () => Navigator.pop(dialogContext),
                  startColor: AppTheme.brightBlue,
                  endColor: AppTheme.brightPink,
                  width: double.infinity,
                  height: 56,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build analysis cards (matching food tracking style)
  Widget _buildMobileAnalysisCard(
      String title, IconData icon, Color color, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Helper method to determine trimester based on pregnancy week
  String _getTrimester(int weeksPregnant) {
    if (weeksPregnant <= 12) {
      return 'First Trimester';
    } else if (weeksPregnant <= 26) {
      return 'Second Trimester';
    } else {
      return 'Third Trimester';
    }
  }

  // Voice recording methods for symptom transcription
  Future<void> _startVoiceRecording() async {
    try {
      setState(() {
        _isRecording = true;
      });

      final success = await _voiceService.startRecording();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '🎤 Voice recording started... Describe your symptoms now!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to start recording'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopVoiceRecording() async {
    try {
      setState(() {
        _isRecording = false;
      });

      final success = await _voiceService.stopRecording();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏹️ Recording stopped. Transcribing symptoms...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Transcribe the recorded audio
        await _transcribeSymptomsAudio();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to stop recording'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Transcribe audio and populate symptoms field
  Future<void> _transcribeSymptomsAudio() async {
    try {
      setState(() {
        _isTranscribing = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔤 Transcribing your symptoms...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      final transcription = await _voiceService.transcribeAudio(
        context: context,
        useN8NForSymptoms: true, // Use N8N webhook for symptoms
      );

      if (transcription != null) {
        setState(() {
          _transcribedText = transcription;

          // Extract clean symptom text from N8N response
          String cleanSymptomText = _extractSymptomText(transcription);

          // Always populate symptoms field with extracted text
          if (cleanSymptomText.isNotEmpty) {
            _symptomController.text = cleanSymptomText;
          }
        });

        // Show appropriate message based on response type
        Color snackBarColor;
        String snackBarMessage;

        if (transcription.toLowerCase().contains('error')) {
          snackBarColor = Colors.red;
          snackBarMessage = '❌ $transcription';
        } else if (transcription.toLowerCase().contains('n8n')) {
          snackBarColor = Colors.blue;
          snackBarMessage = '🔗 N8N Webhook: $transcription';
        } else {
          snackBarColor = Colors.green;
          snackBarMessage = '✅ Symptoms processed: $transcription';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackBarMessage),
            backgroundColor: snackBarColor,
            duration: Duration(seconds: 6), // Longer duration for N8N responses
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Transcription failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTranscribing = false;
      });
    }
  }

  /// Extract clean symptom text from N8N webhook response
  String _extractSymptomText(String response) {
    try {
      // Try to parse as JSON first
      if (response.contains('{') && response.contains('}')) {
        // Extract JSON part from the response
        int startIndex = response.indexOf('{');
        int endIndex = response.lastIndexOf('}') + 1;
        String jsonString = response.substring(startIndex, endIndex);

        final jsonData = json.decode(jsonString);

        // Look for common output fields from N8N
        String extractedText = jsonData['output'] ??
            jsonData['transcription'] ??
            jsonData['text'] ??
            jsonData['result'] ??
            jsonData['message'] ??
            '';

        if (extractedText.isNotEmpty) {
          print('✅ Extracted symptom text: $extractedText');
          return extractedText;
        }
      }

      // If not JSON or no valid field found, try to extract meaningful text
      String cleanText = response;

      // Remove common N8N/webhook prefixes
      cleanText =
          cleanText.replaceAll(RegExp(r'N8N.*?:', caseSensitive: false), '');
      cleanText = cleanText.replaceAll(
          RegExp(r'webhook.*?:', caseSensitive: false), '');
      cleanText = cleanText.replaceAll(
          RegExp(r'response.*?:', caseSensitive: false), '');

      // Remove JSON formatting if present
      cleanText = cleanText.replaceAll(RegExp(r'[{}"\[\]]'), '');
      cleanText = cleanText.replaceAll(
          RegExp(r'output:|transcription:|text:|result:|message:',
              caseSensitive: false),
          '');

      // Clean up extra spaces and quotes
      cleanText = cleanText.trim();
      cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ');

      print('🧹 Cleaned symptom text: $cleanText');
      return cleanText;
    } catch (e) {
      print('❌ Error extracting symptom text: $e');
      // Return original response if parsing fails
      return response;
    }
  }

  // Save analysis report to backend
  Future<void> _saveAnalysisReport(Map<String, dynamic> analysisResponse,
      Map<String, dynamic> originalSymptomData) async {
    try {
      print('🔍 Saving analysis report to backend...');

      // Prepare report data for saving
      final reportData = {
        'patient_id': originalSymptomData['patient_id'],
        'symptom_text': originalSymptomData['text'],
        'weeks_pregnant': originalSymptomData['weeks_pregnant'],
        'severity': originalSymptomData['severity'],
        'notes': originalSymptomData['notes'],
        'date': originalSymptomData['date'],

        // AI Analysis Results
        'analysis_method': analysisResponse['analysis_method'] ?? 'quantum_llm',
        'primary_recommendation':
            analysisResponse['primary_recommendation'] ?? '',
        'additional_recommendations':
            analysisResponse['additional_recommendations'] ?? [],
        'red_flags_detected': analysisResponse['red_flags_detected'] ?? [],
        'disclaimer': analysisResponse['disclaimer'] ?? '',
        'urgency_level': 'moderate', // Default, can be enhanced later
        'knowledge_base_suggestions_count':
            analysisResponse['knowledge_base_suggestions_count'] ?? 0,

        // Patient Context
        'patient_context': originalSymptomData['patient_context'],
      };

      final saveResult =
          await SaveSymptomAnalysisReportService().call(reportData);

      if (saveResult.containsKey('success') && saveResult['success'] == true) {
        print('✅ Analysis report saved successfully!');
        print('🔍 Report ID: ${saveResult['report_id']}');
        print('🔍 Total reports: ${saveResult['analysisReportsCount']}');

        // Show success message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Analysis report saved to your medical history'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        print('⚠️ Failed to save analysis report: ${saveResult['message']}');

        // Show warning message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('⚠️ Analysis completed but could not save to history'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving analysis report: $e');

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error saving analysis report'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // View analysis history
  Future<void> _viewAnalysisHistory() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      if (userInfo['userId'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ User ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Loading analysis history...'),
              ],
            ),
          );
        },
      );

      // Fetch analysis reports
      final reportsResult =
          await GetSymptomAnalysisReportsService().call(userInfo['userId']!);

      // Close loading dialog
      Navigator.of(context).pop();

      if (reportsResult.containsKey('success') &&
          reportsResult['success'] == true) {
        final reports = reportsResult['analysisReports'] ?? [];

        if (reports.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📝 No analysis reports found yet'),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          // Navigate to history screen or show dialog
          _showAnalysisHistoryDialog(reports);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('❌ Error loading history: ${reportsResult['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show analysis history in a dialog
  void _showAnalysisHistoryDialog(List<dynamic> reports) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Symptom Analysis History'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      report['symptom_text'] ?? 'No symptoms',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Week ${report['weeks_pregnant']} (${report['trimester']})'),
                        Text('Date: ${report['analysis_date']}'),
                        if (report['ai_analysis']?['red_flags_detected']
                                ?.isNotEmpty ==
                            true)
                          Text(
                            '🚨 Red Flags Detected',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.psychology,
                      color: report['ai_analysis']?['red_flags_detected']
                                  ?.isNotEmpty ==
                              true
                          ? Colors.red
                          : Colors.green,
                    ),
                    onTap: () => _showReportDetails(report),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Show detailed report information
  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Analysis Report - ${report['analysis_date']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('**Symptoms:** ${report['symptom_text']}'),
                const SizedBox(height: 8),
                Text(
                    '**Pregnancy Week:** ${report['weeks_pregnant']} (${report['trimester']})'),
                const SizedBox(height: 8),
                Text('**Severity:** ${report['severity']}'),
                const SizedBox(height: 8),
                if (report['notes']?.isNotEmpty == true) ...[
                  Text('**Notes:** ${report['notes']}'),
                  const SizedBox(height: 8),
                ],
                const Divider(),
                const Text('**AI Analysis Results:**',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (report['ai_analysis']?['primary_recommendation']
                        ?.isNotEmpty ==
                    true) ...[
                  Text(
                      '**Primary Recommendation:**\n${report['ai_analysis']['primary_recommendation']}'),
                  const SizedBox(height: 8),
                ],
                if (report['ai_analysis']?['red_flags_detected']?.isNotEmpty ==
                    true) ...[
                  Text('**Red Flags:**',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  ...report['ai_analysis']['red_flags_detected'].map<Widget>(
                      (flag) =>
                          Text('• $flag', style: TextStyle(color: Colors.red))),
                  const SizedBox(height: 8),
                ],
                Text(
                    '**Analysis Method:** ${report['ai_analysis']?['analysis_method'] ?? 'Unknown'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: AppTheme.textGray),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Symptoms',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: AppTheme.textGray),
                    onPressed: _viewAnalysisHistory,
                  ),
                ],
              ),
            ),

            // Date display
            Center(
              child: Text(
                AppDateUtils.formatDate(widget.date),
                style: const TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instruction card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.lightGray),
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
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLightPink,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.lightPink),
                            ),
                            child: Icon(
                              Icons.sick,
                              color: AppTheme.brightPink,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Describe your symptoms',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textGray,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'You can type or use voice input.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Symptom input field
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.lightGray),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _symptomController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText:
                                    "e.g. I'm feeling a bit of nausea this morning...",
                                hintStyle: const TextStyle(
                                  color: AppTheme.textGray,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textGray,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _isRecording
                                ? _stopVoiceRecording
                                : _startVoiceRecording,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundLightPink,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.lightPink),
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: AppTheme.brightPink,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                    // Analyze button
                    const Spacer(),

                    Center(
                      child: GradientButton(
                        text: 'Analyze Results',
                        onPressed: _isAnalyzing ? null : _analyzeSymptoms,
                        startColor: AppTheme.brightBlue,
                        endColor: AppTheme.brightPink,
                        width: double.infinity,
                        height: 56,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
