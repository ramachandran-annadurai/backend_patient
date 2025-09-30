import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
/// Centralized HTTP core: token, headers, timeouts, and simple request helper.
/// Self-contained. No dependency on ApiService.
class ApiCore {
  static String? _authToken;

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration fileUploadTimeout = Duration(seconds: 60);

  // Optional shared HTTP client
  static http.Client? _sharedClient;
  static http.Client get client => _sharedClient ??= http.Client();

  // Token management
  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  // Headers
  static Map<String, String> get headers {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'keep-alive',
    };
    if (_authToken != null) {
      map['Authorization'] = 'Bearer $_authToken';
    }
    return map;
  }

  static Map<String, String> get authHeaders {
    final map = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      map['Authorization'] = 'Bearer $_authToken';
    }
    return map;
  }

  // Lightweight request helper with timeout + JSON decode + basic error mapping
  static Future<Map<String, dynamic>> request(
      Future<http.Response> Function() send, {
        Duration? timeout,
      }) async {
    try {
      final response = await send().timeout(timeout ?? defaultTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isEmpty ? <String, dynamic>{} : json.decode(response.body) as Map<String, dynamic>;
      }
      return {
        'error': 'HTTP ${response.statusCode}',
        'body': response.body,
      };
    } on TimeoutException {
      return {'error': 'timeout'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}



/// Provider-style HTTP base with token handling, headers, and helpers.
/// Uses ApiCore under the hood (http.Client + timeouts + JSON decode).
class BaseApiProvider extends ChangeNotifier {
  BaseApiProvider();

  bool logout = false;
  bool showForceUpgradeAlert = false;

  final Map<String, String> _defaultHeaders = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    'Connection': 'keep-alive',
  };

  http.Client get _client => ApiCore.client;

  Future<void> setTokenFromPrefs({String key = 'auth_token'}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(key);
    if (token != null && token.isNotEmpty) {
      ApiCore.setAuthToken(token);
    }
  }

  Map<String, String> _mergeHeaders({Map<String, String>? headers, bool auth = true}) {
    final result = <String, String>{}..addAll(_defaultHeaders);
    if (auth) {
      result.addAll(ApiCore.authHeaders);
    } else {
      result.addAll(ApiCore.headers);
    }
    if (headers != null && headers.isNotEmpty) {
      result.addAll(headers);
    }
    return result;
  }

  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers, bool auth = true, Duration? timeout}) {
    final merged = _mergeHeaders(headers: headers, auth: auth);
    return _execute(() => _client.get(Uri.parse(url), headers: merged), timeout: timeout);
  }

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body, {Map<String, String>? headers, bool auth = true, Duration? timeout}) {
    final merged = _mergeHeaders(headers: headers, auth: auth);
    return _execute(() => _client.post(Uri.parse(url), headers: merged, body: json.encode(body)), timeout: timeout);
  }

  Future<Map<String, dynamic>> put(String url, Map<String, dynamic> body, {Map<String, String>? headers, bool auth = true, Duration? timeout}) {
    final merged = _mergeHeaders(headers: headers, auth: auth);
    return _execute(() => _client.put(Uri.parse(url), headers: merged, body: json.encode(body)), timeout: timeout);
  }

  Future<Map<String, dynamic>> delete(String url, {Map<String, String>? headers, bool auth = true, Duration? timeout}) {
    final merged = _mergeHeaders(headers: headers, auth: auth);
    return _execute(() => _client.delete(Uri.parse(url), headers: merged), timeout: timeout);
  }

  Future<T> request<T>(
    Future<http.Response> Function() send, {
    Duration? timeout,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final map = await _execute(send, timeout: timeout);
    if (fromJson == null) {
      return map as T; // caller expects Map<String, dynamic>
    }
    return fromJson(map);
  }

  Future<Map<String, dynamic>> _execute(
    Future<http.Response> Function() send, {
    Duration? timeout,
  }) async {
    final result = await ApiCore.request(send, timeout: timeout ?? ApiCore.defaultTimeout);
    _handleCommonSignals(result);
    return result;
  }

  void _handleCommonSignals(Map<String, dynamic> jsonBody) {
    // Example: your backend could send { 'force_upgrade': true }
    final force = jsonBody['force_upgrade'] == true || jsonBody['x-app-outdated'] == true;
    if (force && showForceUpgradeAlert != true) {
      showForceUpgradeAlert = true;
      notifyListeners();
    }

    // Mark logout when explicit auth errors are detected
    final error = jsonBody['error']?.toString().toLowerCase();
    if (error != null && (error.contains('unauthorized') || error.contains('invalid token'))) {
      if (!logout) {
        logout = true;
        notifyListeners();
      }
    }
  }
}


