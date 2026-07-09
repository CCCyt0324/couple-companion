import 'dart:async';
import 'dart:html' as html;
import 'location_service.dart';

LocationService createPlatformLocationService() => _WebLocationService();

class _WebLocationService implements LocationService {
  final _controller = StreamController<LocationSnapshot>.broadcast();
  html.Geolocation? _geo;
  int? _watchId;

  @override
  Stream<LocationSnapshot> get locationStream => _controller.stream;

  @override
  bool get isSupported => html.window.navigator.geolocation != null;

  @override
  Future<String?> startTracking({int intervalMs = 5000}) async {
    _geo = html.window.navigator.geolocation;
    if (_geo == null) return '您的浏览器不支持定位功能';

    try {
      _watchId = _geo!.watchPosition(
        (html.Geoposition pos) {
          _controller.add(LocationSnapshot(
            latitude: pos.coords.latitude,
            longitude: pos.coords.longitude,
            accuracy: pos.coords.accuracy,
          ));
        },
        onError: (html.PositionError err) {
          _controller.add(LocationSnapshot(error: _errorMsg(err.code)));
        },
        options: { 'enableHighAccuracy': true, 'timeout': 10000 },
      );
    } catch (e) {
      return '定位失败: $e';
    }
    return null;
  }

  @override
  void stopTracking() {
    if (_watchId != null) _geo?.clearWatch(_watchId!);
    _watchId = null;
  }

  @override
  Future<void> updateShareStatus(bool sharing) async {}

  @override
  Future<void> uploadLocation(LocationSnapshot snapshot) async {}

  @override
  Future<Map<String, dynamic>?> fetchLocations() async => null;

  @override
  Future<void> dispose() async {
    stopTracking();
    await _controller.close();
  }

  String _errorMsg(int code) {
    switch (code) {
      case 1: return '请在浏览器设置中允许位置权限';
      case 2: return '无法获取位置，请检查网络';
      case 3: return '定位超时，请重试';
      default: return '定位失败';
    }
  }
}
