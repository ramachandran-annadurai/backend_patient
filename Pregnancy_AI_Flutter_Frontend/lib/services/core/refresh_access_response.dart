import 'network_request.dart';

class RefreshAccessAPIResponse implements NetworkResponse {
  final String accessToken;

  const RefreshAccessAPIResponse({
    required this.accessToken,
  });

  @override
  factory RefreshAccessAPIResponse.fromJson(Map<String, dynamic> json) {
    return RefreshAccessAPIResponse(
      accessToken: json['accessToken'], // ✅ matches JSON key
    );
  }
}
