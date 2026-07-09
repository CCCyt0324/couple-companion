import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/api/api_service.dart';
import 'core/constants/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化用户身份——优先用 localStorage 中的 userId，没有则创建
  final prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('user_id');

  if (userId == null) {
    try {
      final res = await apiService.post(ApiConstants.roomStart);
      final data = apiService.unwrap(res.data) as Map<String, dynamic>;
      userId = data['userId'] as int;
      await prefs.setInt('user_id', userId);
    } catch (_) {}
  }

  if (userId != null) {
    apiService.setUserId(userId);
  }

  runApp(const ProviderScope(child: CoupleApp()));
}
