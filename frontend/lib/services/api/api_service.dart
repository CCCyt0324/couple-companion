import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';

class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: const {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(LogInterceptor(responseBody: kDebugMode));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          if (_userId != null) {
            options.headers['x-user-id'] = _userId.toString();
          }
          handler.next(options);
        },
      ),
    );
  }

  late final Dio _dio;
  String? _token;
  int? _userId;

  Dio get dio => _dio;
  int? get userId => _userId;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getInt('user_id');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  void setUserId(int id) {
    _userId = id;
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  void setToken(String token) {
    _token = token;
  }

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? params,
  }) =>
      _dio.get(url, queryParameters: params);

  Future<Response<dynamic>> post(String url, {dynamic data}) =>
      _dio.post(url, data: data);

  Future<Response<dynamic>> put(String url, {dynamic data}) =>
      _dio.put(url, data: data);

  Future<Response<dynamic>> delete(String url) => _dio.delete(url);

  dynamic unwrap(dynamic raw) {
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'];
    }
    return raw;
  }
}

final apiService = ApiService();
