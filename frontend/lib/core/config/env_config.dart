/// 环境配置，通过 --dart-define 注入。
/// 例如：
/// flutter build web --dart-define=API_URL=https://api.yourdomain.com/api
class EnvConfig {
  EnvConfig._();

  static const String _apiUrl = String.fromEnvironment('API_URL');
  static const String _wsUrl = String.fromEnvironment('WS_URL');

  /// API 基础地址。
  /// 空值时默认走同域 `/api`。
  /// 如果只传了域名根地址，例如 `https://api.example.com`，
  /// 会自动补成 `https://api.example.com/api`，以匹配当前后端的全局前缀。
  static String get apiBaseUrl {
    if (_apiUrl.isEmpty) {
      return '/api';
    }

    final normalized = _trimTrailingSlash(_apiUrl);
    final uri = Uri.parse(normalized);
    if (uri.path.isEmpty || uri.path == '/') {
      return '$normalized/api';
    }
    return normalized;
  }

  /// WebSocket 地址。
  /// 未显式传入时，会根据 API_URL 自动推断协议、主机和端口。
  static String get wsBaseUrl {
    if (_wsUrl.isNotEmpty) {
      return _trimTrailingSlash(_wsUrl);
    }

    if (_apiUrl.isNotEmpty) {
      final uri = Uri.parse(_trimTrailingSlash(_apiUrl));
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final hasPort = uri.hasPort && uri.port > 0;
      return hasPort
          ? '$scheme://${uri.host}:${uri.port}'
          : '$scheme://${uri.host}';
    }

    return 'ws://localhost:3000';
  }

  static bool get isProduction => _apiUrl.isNotEmpty;

  static String _trimTrailingSlash(String value) {
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }
}
