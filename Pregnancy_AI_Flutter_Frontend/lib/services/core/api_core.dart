import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'refresh_access_response.dart';
import 'package:patient_alert_app/utils/platform_util.dart';
import 'network_request.dart';
import 'package:patient_alert_app/main.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

class ErrorResponse {
  final String error;
  final Map<String, dynamic>? responseData;
  final String? errorCode;
  final Map<String, dynamic>? details;

  ErrorResponse(String responseString, {this.responseData})
      : error = responseString.isNotEmpty ? responseString : "Unknown error",
        errorCode = _extractErrorCode(responseString, responseData),
        details = _extractDetails(responseData);

  // Extract error code from nested response
  static String? _extractErrorCode(
      String error, Map<String, dynamic>? responseData) {
    if (responseData == null) return null;

    try {
      // Handle nested detail structure
      if (responseData.containsKey('detail') && responseData['detail'] is Map) {
        final detail = responseData['detail'] as Map<String, dynamic>;
        return detail['error_code']?.toString();
      }

      // Handle direct error_code
      if (responseData.containsKey('error_code')) {
        return responseData['error_code']?.toString();
      }
    } catch (e) {
      log('Error extracting error code: $e');
    }

    return null;
  }

  // Extract additional details from response
  static Map<String, dynamic>? _extractDetails(
      Map<String, dynamic>? responseData) {
    if (responseData == null) return null;

    try {
      // Handle nested detail structure
      if (responseData.containsKey('detail') && responseData['detail'] is Map) {
        final detail = responseData['detail'] as Map<String, dynamic>;
        if (detail.containsKey('details')) {
          return detail['details'] as Map<String, dynamic>?;
        }
      }

      // Handle direct details
      if (responseData.containsKey('details')) {
        return responseData['details'] as Map<String, dynamic>?;
      }
    } catch (e) {
      log('Error extracting details: $e');
    }

    return null;
  }

  // Helper methods to access specific data
  String? get existingUserId => details?['existing_user_id']?.toString();
  String? get userType => details?['user_type']?.toString();

  @override
  String toString() => error;
}

class ApiProvider extends ChangeNotifier {
  late Dio _dio;
  bool? logout;
  bool showForceUpgradeAlert = false;
  late Map<String, String> _defaultHeaders;
  late CacheOptions _cacheOptions;

  ApiProvider() {
    _dio = Dio();
    _defaultHeaders = {'X-Client': 'mobile'};
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    final dir = await getTemporaryDirectory();
    _cacheOptions = CacheOptions(
      store: HiveCacheStore(dir.path),
      policy: CachePolicy.refresh, // Always refresh from the server
      hitCacheOnErrorExcept: [401, 403],
      priority: CachePriority.normal,
      allowPostMethod: false,
    );

    _dio.interceptors.add(DioCacheInterceptor(options: _cacheOptions));
  }

  Future<void> loadDefaultHeaders() async {
    if (!_defaultHeaders.containsKey('x-app-version')) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String deviceInfo = await PlatformUtil().deviceInfo();
      String osVersion = await PlatformUtil().getOSVersion();

      _defaultHeaders.addAll({
        'x-app-version': packageInfo.version,
        'x-app-build': packageInfo.buildNumber,
        'x-platform': PlatformUtil().getPlatform().name,
        'x-os-version': osVersion,
        "User-Agent": deviceInfo,
        "x-device-locale": Platform.localeName,
      });
    }

    _defaultHeaders['Content-Type'] = 'application/json; charset=UTF-8';
  }

  Future<RefreshAccessAPIResponse> refreshAccess() async {
    const String refreshAccessURL = '';
    final prefs = await SharedPreferences.getInstance();
    var refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      logout = true;
      notifyListeners();
      throw (ErrorResponse(
          json.encode({'error': "Refresh token not present"})));
    }

    try {
      final response = await _dio.post(
        refreshAccessURL,
        data: {'refreshToken': refreshToken},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final parsed = RefreshAccessAPIResponse.fromJson(response.data);
      await prefs.setString('jwt_token', parsed.accessToken);


      return parsed;
    } on DioException catch (e) {
      logout = true;
      notifyListeners();
      await prefs.remove('refresh_token');
      throw (ErrorResponse(e.response?.data.toString() ?? e.toString()));
    }
  }

  Future<T> refreshTokenAndRetry<T extends NetworkResponse>(
      NetworkRequest request,
      Function(dynamic json) fromJson,
      ) async {
    try {
      final refreshAccessResponse = await refreshAccess();
      request.headers?['Authorization'] =
      'Bearer ${refreshAccessResponse.accessToken}';
    } catch (e) {
      log('Error getting refresh token: $e');
    }

    return await makeAPICall<T>(request, (json) => fromJson(json),
        isItARetryCall: true);
  }

  Future<void> refreshTokenAndRetryVoid(NetworkRequest request) async {
    try {
      final refreshAccessResponse = await refreshAccess();
      request.headers?['Authorization'] =
      'Bearer ${refreshAccessResponse.accessToken}';
    } catch (e) {
      log('Error getting refresh token: $e');
    }

    return await makeVoidAPICall(request, isItARetryCall: true);
  }

  Future<T> makeAPICall<T extends NetworkResponse>(
      NetworkRequest request,
      T Function(dynamic json) fromJson, {
        bool isItARetryCall = false,
      }) async {
    try {
      await loadDefaultHeaders();
      request.headers ??= {};
      request.headers!.addAll(_defaultHeaders);

      if (request.isTokenRequired) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('Token');
        if (token != null) {
          request.headers!['Authorization'] = 'Bearer $token';
        }
      }

      // Add ETag header if available
      final prefs = await SharedPreferences.getInstance();
      final eTag = prefs.getString('etag_${request.path}');
      if (eTag != null) {
        request.headers!['If-None-Match'] = eTag;
      }

      final response = await _dio.request(
        request.path,
        data: request.body,
        options: _cacheOptions.toOptions().copyWith(
          method: request.type.name.toUpperCase(),
          headers: request.headers,
        ),
      );
      log("🚀 Dio Response Code: ${response.statusCode}");
      _checkResponseHeaders(response.headers.map);
      log('Response headers: ${response.headers.map}');

      if (response.headers.map.containsKey('etag')) {
        await prefs.setString(
            'etag_${request.path}', response.headers.map['etag']!.first);
      }

      switch (response.statusCode) {
        case 200:
        // Update the stored response with the new data
          await prefs.setString(
              'response_${request.path}', json.encode(response.data));
          return fromJson(response.data);
        case 304:
        // Use the cached response if the ETag matches
          final cachedResponse = prefs.getString('response_${request.path}');
          if (cachedResponse != null) {
            return fromJson(json.decode(cachedResponse));
          } else {
            throw ('No cached response available for 304 status code');
          }
        case 204:
          throw (ErrorResponse(response.data.toString()));
        default:
          throw ('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        throw (data['error'] ?? 'Bad request');
      } else if (e.response?.statusCode == 401) {
        if (!isItARetryCall) {
          return await refreshTokenAndRetry<T>(request, fromJson);
        } else {
          logout = true;
          notifyListeners();
          throw (e.response?.data['error']);
        }
      } else if (e.response?.statusCode == 403) {
        throw (e.response?.data['error']);
      } else {
        throw (e.toString());
      }
    }
  }

  Future<void> makeVoidAPICall(
      NetworkRequest request, {
        bool isItARetryCall = false,
      }) async {
    try {
      await loadDefaultHeaders();
      request.headers ??= {};
      request.headers!.addAll(_defaultHeaders);

      if (request.isTokenRequired) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('Token');
        if (token != null) {
          request.headers!['Authorization'] = 'Bearer $token';
        }
      }

      final response = await _dio.request(
        request.path,
        data: request.body,
        options: _cacheOptions.toOptions().copyWith(
          method: request.type.name.toUpperCase(),
          headers: request.headers,
        ),
      );
      _checkResponseHeaders(response.headers.map);

      switch (response.statusCode) {
        case 200:
        case 201:
          return;
        case 204:
          throw (response.data.toString());
        default:
          throw ('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && !isItARetryCall) {
        return await refreshTokenAndRetryVoid(request);
      } else if (e.response?.statusCode == 401 && isItARetryCall) {
        logout = true;
        notifyListeners();
        throw (e.response?.data['error']);
      } else if (e.response?.statusCode == 400) {
        throw (e.response?.data['error']);
      } else {
        throw (e.toString());
      }
    }
  }

  void _checkResponseHeaders(Map<String, List<String>> headers) {
    if (headers.containsKey('x-app-outdated')) {
      showForceUpgradeAlert = true;
      notifyListeners();
    }
  }

  Future<void> clearAllCache() async {
    await _cacheOptions.store?.clean();
  }
}