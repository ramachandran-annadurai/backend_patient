class OCRResult {
  final String text;
  final double confidence;
  final List<List<double>> bbox;

  OCRResult({
    required this.text,
    required this.confidence,
    required this.bbox,
  });

  factory OCRResult.fromJson(Map<String, dynamic> json) {
    return OCRResult(
      text: json['text'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      bbox: List<List<double>>.from(
        (json['bbox'] ?? []).map((item) => List<double>.from(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
      'bbox': bbox,
    };
  }
}

class OCRResponse {
  final bool success;
  final String filename;
  final String fileType;
  final int totalPages;
  final int textCount;
  final String extractedText;
  final String fullContent;
  final List<OCRResult> results;
  final Map<String, dynamic>? processingSummary;
  final Map<String, dynamic>? webhookDelivery;
  final String? error;

  OCRResponse({
    required this.success,
    required this.filename,
    required this.fileType,
    required this.totalPages,
    required this.textCount,
    required this.extractedText,
    required this.fullContent,
    required this.results,
    this.processingSummary,
    this.webhookDelivery,
    this.error,
  });

  factory OCRResponse.fromJson(Map<String, dynamic> json) {
    return OCRResponse(
      success: json['success'] ?? false,
      filename: json['filename'] ?? '',
      fileType: json['file_type'] ?? '',
      totalPages: json['total_pages'] ?? 0,
      textCount: json['text_count'] ?? 0,
      extractedText: json['extracted_text'] ?? '',
      fullContent: json['full_content'] ?? '',
      results: (json['results'] ?? [])
          .map<OCRResult>((item) => OCRResult.fromJson(item))
          .toList(),
      processingSummary: json['processing_summary'],
      webhookDelivery: json['webhook_delivery'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'filename': filename,
      'file_type': fileType,
      'total_pages': totalPages,
      'text_count': textCount,
      'extracted_text': extractedText,
      'full_content': fullContent,
      'results': results.map((item) => item.toJson()).toList(),
      'processing_summary': processingSummary,
      'webhook_delivery': webhookDelivery,
      'error': error,
    };
  }
}

class FileUploadResult {
  final bool success;
  final String? error;
  final OCRResponse? ocrResponse;
  final String? fileName;

  FileUploadResult({
    required this.success,
    this.error,
    this.ocrResponse,
    this.fileName,
  });

  factory FileUploadResult.success(OCRResponse ocrResponse, String fileName) {
    return FileUploadResult(
      success: true,
      ocrResponse: ocrResponse,
      fileName: fileName,
    );
  }

  factory FileUploadResult.error(String error) {
    return FileUploadResult(
      success: false,
      error: error,
    );
  }
}
