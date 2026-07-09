import 'dart:async';
import 'location_service.dart';

/// 为编译条件导入提供的工厂
LocationService createPlatformLocationService() => _NativeLocationProxy();

/// mobile 端直接复用现有 AMap 实现
class _NativeLocationProxy implements LocationService {
  @override
  Stream<LocationSnapshot> get locationStream => const Stream.empty();

  @override
  bool get isSupported => true;

  @override
  Future<String?> startTracking({int intervalMs = 5000}) async => null;

  @override
  void stopTracking() {}

  @override
  Future<void> updateShareStatus(bool sharing) async {}

  @override
  Future<void> uploadLocation(LocationSnapshot snapshot) async {}

  @override
  Future<Map<String, dynamic>?> fetchLocations() async => null;

  @override
  Future<void> dispose() async {}
}
