class ApiResponseModel<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponseModel({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message']?.toString(),
      error: json['error']?.toString(),
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data,
      if (message != null) 'message': message,
      if (error != null) 'error': error,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }
}
