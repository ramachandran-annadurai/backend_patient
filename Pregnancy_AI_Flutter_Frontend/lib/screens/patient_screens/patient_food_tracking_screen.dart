import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../utils/date_utils.dart';
import '../../services/enhanced_voice_service.dart';
import '../../services/patient_service/get_current_pregnancy_week_service.dart';
// import 'detailed_food_entry_screen.dart'; // Removed as per edit hint
import '../../widgets/app_background.dart';
import '../../widgets/gradient_button.dart';
import '../../theme/app_theme.dart';
import '../../providers/food_analysis_provider.dart';
import '../../providers/save_food_entry_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/food_entry.dart';
import '../../models/analyze_food_response.dart';

class PatientFoodTrackingScreen extends StatefulWidget {
  final dynamic date; // Change to dynamic to handle both String and DateTime
  final String userRole; // Add this

  const PatientFoodTrackingScreen({
    Key? key,
    required this.date,
    this.userRole = 'patient', // Default value
  }) : super(key: key);

  // Factory constructor to handle string dates from navigation
  factory PatientFoodTrackingScreen.fromStringDate({
    Key? key,
    required String dateString,
    String userRole = 'patient',
  }) {
    return PatientFoodTrackingScreen(
      key: key,
      date: dateString,
      userRole: userRole,
    );
  }

  @override
  State<PatientFoodTrackingScreen> createState() =>
      _PatientFoodTrackingScreenState();
}

class _PatientFoodTrackingScreenState extends State<PatientFoodTrackingScreen> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Voice recording related variables
  final EnhancedVoiceService _voiceService = EnhancedVoiceService();
  bool _isRecording = false;
  bool _isTranscribing = false;
  String _transcribedText = '';

  // Analysis related variables
  AnalyzeFoodResponseModel? _nutritionAnalysis;
  String _userId = '';

  String _selectedMealType = 'breakfast';
  int _pregnancyWeek = 1;

  @override
  void initState() {
    super.initState();

    // Set default values
    _selectedMealType = 'breakfast';
    _userId = 'patient_001'; // Static user ID

    // Initialize voice service
    _initializeVoiceService();

    // Fetch pregnancy week
    _fetchPregnancyWeek();
  }

  /// Initialize voice service and check permissions
  Future<void> _initializeVoiceService() async {
    try {
      final initialized = await _voiceService.initialize();

      if (!initialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Voice recording not available. Please grant microphone permission.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Fetch current pregnancy week from service
  Future<void> _fetchPregnancyWeek() async {
    try {
      // Get current user info from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      final String? userId = userInfo['userId'];
      if (userId == null) {
        print('❌ User ID not found for pregnancy week fetch');
        return;
      }

      // Call the service to get pregnancy week
      final service = GetCurrentPregnancyWeekService();
      final response = await service.call(userId);

      if (response['success'] == true) {
        setState(() {
          _pregnancyWeek = response['current_pregnancy_week'] ?? 1;
        });
        print('✅ Pregnancy week fetched: $_pregnancyWeek');
      } else {
        print(
            '⚠️ Failed to fetch pregnancy week: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Error fetching pregnancy week: $e');
    }
  }

  // Enhanced voice recording with translation support
  Future<void> _startVoiceRecording() async {
    try {
      setState(() {
        _isRecording = true;
      });

      final success = await _voiceService.startRecording();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎤 Voice recording started... Speak now!'),
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
            content:
                Text('⏹️ Recording stopped. Processing with translation...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Use the new translation method
        await _transcribeAudioWithTranslation();
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

  // New method for transcription with translation
  Future<void> _transcribeAudioWithTranslation() async {
    try {
      setState(() {
        _isTranscribing = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔤 Transcribing audio and translating if needed...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      final transcription = await _voiceService.transcribeAudio(
        context: context,
        useN8NForFood: true, // Use N8N webhook for food
      );

      if (transcription != null) {
        setState(() {
          _transcribedText = transcription;

          // Extract clean food text from N8N response
          String cleanFoodText = _extractFoodText(transcription);

          // Automatically populate the food input field with clean text
          _foodController.text =
              cleanFoodText.isNotEmpty ? cleanFoodText : transcription;
        });

        // Show different messages for errors vs successful transcription
        if (transcription.startsWith('Error:')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(transcription),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 8),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Transcription complete: $transcription'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('❌ Transcription failed - check console logs for details'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 8),
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

  /// Extract clean food text from N8N webhook response
  String _extractFoodText(String response) {
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

      return cleanText;
    } catch (e) {
      // Return original response if parsing fails
      return response;
    }
  }

  @override
  void dispose() {
    _foodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // NEW METHOD - Using FoodAnalysisProvider (Safe refactor)
  Future<void> _analyzeFoodWithGPT4() async {
    if (_foodController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter food details first'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final analysisProvider =
        Provider.of<FoodAnalysisProvider>(context, listen: false);

    final success = await analysisProvider.analyzeFood(
      _foodController.text.trim(),
      _pregnancyWeek,
      _userId,
    );

    if (success) {
      // Show dialog with analysis result
      _showGPT4AnalysisDialog(analysisProvider.analysisResult!);

      // Update local state for backward compatibility
      setState(() {
        _nutritionAnalysis = analysisProvider.analysisResult;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPT-4 analysis completed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: ${analysisProvider.errorMessage}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Show GPT-4 analysis results in a mobile-optimized dialog
  void _showGPT4AnalysisDialog(AnalyzeFoodResponseModel analysis) {
    final saveProvider =
        Provider.of<SaveFoodEntryProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          ChangeNotifierProvider<SaveFoodEntryProvider>.value(
        value: saveProvider,
        child: Dialog(
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
                              'Your meal has been analyzed',
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
                        // Nutritional Breakdown Card
                        _buildMobileAnalysisCard(
                          'Nutritional Breakdown',
                          Icons.analytics,
                          Colors.blue,
                          [
                            'Calories: ${analysis.analysis.nutritionalBreakdown.estimatedCalories ?? 'N/A'}',
                            'Protein: ${analysis.analysis.nutritionalBreakdown.proteinGrams ?? 'N/A'}g',
                            'Carbs: ${analysis.analysis.nutritionalBreakdown.carbohydratesGrams ?? 'N/A'}g',
                            'Fat: ${analysis.analysis.nutritionalBreakdown.fatGrams ?? 'N/A'}g',
                            'Fiber: ${analysis.analysis.nutritionalBreakdown.fiberGrams ?? 'N/A'}g',
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Pregnancy Benefits Card
                        _buildMobileAnalysisCard(
                          'Pregnancy Benefits',
                          Icons.favorite,
                          Colors.pink,
                          [
                            analysis.analysis.pregnancyBenefits
                                    .weekSpecificAdvice ??
                                'N/A',
                            'Nutrients for fetal development: ${analysis.analysis.pregnancyBenefits.nutrientsForFetalDevelopment.join(', ')}',
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Safety Considerations Card
                        _buildMobileAnalysisCard(
                          'Safety & Cooking',
                          Icons.security,
                          Colors.orange,
                          [
                            'Safety tips: ${analysis.analysis.safetyConsiderations.foodSafetyTips.join(', ')}',
                            'Cooking: ${analysis.analysis.safetyConsiderations.cookingRecommendations.join(', ')}',
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Smart Recommendations Card
                        _buildMobileAnalysisCard(
                          'Smart Recommendations',
                          Icons.lightbulb,
                          Colors.green,
                          [
                            'Next meal: ${analysis.analysis.smartRecommendations.nextMealSuggestions.join(', ')}',
                            'Hydration: ${analysis.analysis.smartRecommendations.hydrationTips ?? 'N/A'}',
                          ],
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
                  child: Consumer<SaveFoodEntryProvider>(
                    builder: (context, saveProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: saveProvider.isSaving
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _saveFoodEntryNew();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: saveProvider.isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Save Analysis',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build mobile-optimized analysis card
  Widget _buildMobileAnalysisCard(
      String title, IconData icon, Color color, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
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
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
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

  // NEW METHOD - Using SaveFoodEntryProvider (Same pattern as analyzeFood)
  Future<void> _saveFoodEntryNew() async {
    final foodDetails = _foodController.text.trim();
    if (foodDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter food details first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get current user info from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userInfo = await authProvider.getCurrentUserInfo();
    print(userInfo);

    // Build typed model then send as JSON to existing provider
    final entry = FoodEntryModel(
      userId: (userInfo['userId'] ?? '').toString(),
      userRole: (userInfo['userRole'] ?? 'patient').toString(),
      username: (userInfo['username'] ?? '').toString(),
      email: (userInfo['email'] ?? '').toString(),
      foodDetails: foodDetails,
      mealType: _selectedMealType,
      pregnancyWeek: _pregnancyWeek,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      transcribedText: _transcribedText.isEmpty ? null : _transcribedText,
      nutritionalBreakdown:
          _nutritionAnalysis?.analysis.nutritionalBreakdown.toJson() ?? {},
      gpt4Analysis: _nutritionAnalysis?.toJson(),
      timestamp: DateTime.now().toIso8601String(),
    );

    final saveProvider =
        Provider.of<SaveFoodEntryProvider>(context, listen: false);
    final success = await saveProvider.saveFoodEntry(entry);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Food saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _foodController.clear();
      _notesController.clear();
      setState(() {
        _nutritionAnalysis = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: ${saveProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallScreen = screenSize.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12.0 : 16.0,
                vertical: 8.0,
              ),
              child: _buildHeader(context, isSmallScreen),
            ),

            // Main Content - Expanded to fill remaining space
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12.0 : 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Log Your Meal Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Log Your Meal',
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Meal Type Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMealTypeButton(
                                      'breakfast', 'Breakfast', Icons.coffee),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMealTypeButton(
                                      'lunch', 'Lunch', Icons.restaurant),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMealTypeButton('dinner',
                                      'Dinner', Icons.restaurant_menu),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMealTypeButton(
                                      'snack', 'Snack', Icons.cookie),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // TextField
                            TextField(
                              controller: _foodController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText:
                                    'Describe what you ate... e.g., \'For breakfast, I had a bowl of oatmeal with berries and a glass of orange juice.\'',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.all(16),
                                suffixIcon: GestureDetector(
                                  onTap: _isRecording
                                      ? _stopVoiceRecording
                                      : _startVoiceRecording,
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _isRecording ? Icons.stop : Icons.mic,
                                      color: Colors.green[600],
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            if (_isTranscribing) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.green[600]!),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Transcribing audio...',
                                    style: TextStyle(
                                      color: Colors.green[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button - Gradient style like signup page
                      Consumer<FoodAnalysisProvider>(
                        builder: (context, analysisProvider, child) {
                          return GradientButton(
                            text: analysisProvider.isAnalyzing
                                ? 'Analyzing...'
                                : 'Submit',
                            onPressed: analysisProvider.isAnalyzing
                                ? null
                                : _analyzeFoodWithGPT4,
                            width: double.infinity,
                            height: 56,
                            startColor: AppTheme.brightBlue,
                            endColor: AppTheme.brightPink,
                          );
                        },
                      ),

                      // Analysis Results Section
                      if (_nutritionAnalysis != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isTablet ? 32 : 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Bottom padding for navigation
                      SizedBox(height: isSmallScreen ? 80.0 : 100.0),
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

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: isSmallScreen ? 20.0 : 24.0,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Column(
          children: [
            Text(
              'Food Nutrition',
              style: TextStyle(
                fontSize: isSmallScreen ? 18.0 : 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              _formatDate(widget.date),
              style: TextStyle(
                fontSize: isSmallScreen ? 12.0 : 14.0,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.calendar_today,
            size: isSmallScreen ? 20.0 : 24.0,
            color: Colors.black87,
          ),
          onPressed: () {
            // TODO: Add date picker functionality
          },
        ),
      ],
    );
  }

  Widget _buildMealTypeButton(String mealType, String label, IconData icon) {
    final isSelected = _selectedMealType == mealType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMealType = mealType;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green[300]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.green[600] : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.green[700] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      return AppDateUtils.formatDate(date);
    } catch (e) {
      return date.toString();
    }
  }

// Remove the unused _openDetailedFoodEntry method
// void _openDetailedFoodEntry() async { ... }
}
