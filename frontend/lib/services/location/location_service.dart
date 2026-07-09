import 'dart:async';
import 'package:flutter/foundation.dart';
import 'location_service_web.dart' if (dart.library.io) 'location_service_native.dart';

/// 跨平台定位快照
class LocationSnapshot {
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? city;
  final String? province;
  final String? address;
  final String? error;

  const LocationSnapshot({
    this.latitude, this.longitude, this.accuracy,
    this.city, this.province, this.address, this.error,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
  bool get isSuccess => error == null && hasCoordinates;
}

/// 统一定位服务接口（编译时自动选择 native 或 web 实现）
abstract class LocationService {
  Stream<LocationSnapshot> get locationStream;
  bool get isSupported;
  Future<String?> startTracking({int intervalMs = 5000});
  void stopTracking();
  Future<void> updateShareStatus(bool sharing);
  Future<void> uploadLocation(LocationSnapshot snapshot);
  Future<Map<String, dynamic>?> fetchLocations();
  Future<void> dispose();
}

// 实现类由条件导入提供
LocationService createLocationService() => createPlatformLocationService();
