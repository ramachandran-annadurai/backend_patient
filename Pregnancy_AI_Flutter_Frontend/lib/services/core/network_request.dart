abstract class NetworkResponse {
  NetworkResponse.fromJson(Map<String, dynamic> json);
}

enum NetworkRequestType { get, post, put, patch, delete }

class NetworkRequest {
  NetworkRequest({
    required this.type,
    required this.path,
    this.queryParams,
    this.headers,
    this.bodyFields,
    this.body,
    this.isTokenRequired = true,
  });

  final NetworkRequestType type;
  final String path;
  final Map<String, dynamic>? queryParams;
  Map<String, String>? headers;
  final Map<String, String>? bodyFields;
  final dynamic body;
  final bool isTokenRequired;
}
