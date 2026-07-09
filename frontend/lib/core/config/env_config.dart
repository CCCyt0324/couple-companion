/// 环境配置 —— 通过 --dart-define 注入
/// flutter run --dart-define=API_URL=https://api.yourdomain.com
class EnvConfig {
  EnvConfig._();

  static const String _apiUrl = String.fromEnvironment('API_URL');
  static const String _wsUrl = String.fromEnvironment('WS_URL');

  /// API 基础地址（空 = 相对路径 /api，同域访问）
  static String get apiBaseUrl =>
      _apiUrl.isNotEmpty ? _apiUrl : '/api';

  /// WebSocket 地址（根据 API URL 自动推断 wss/ws）
  static String get wsBaseUrl {
    if (_wsUrl.isNotEmpty) return _wsUrl;
    if (_apiUrl.isNotEmpty) {
      final uri = Uri.parse(_apiUrl);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      return '$scheme://${uri.host}:${uri.port > 0 ? uri.port : ""}';
    }
    return 'ws://localhost:3000';
  }

  static bool get isProduction => _apiUrl.isNotEmpty;
}
