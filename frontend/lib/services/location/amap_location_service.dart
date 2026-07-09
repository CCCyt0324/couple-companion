import 'dart:async';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/amap_constants.dart';
import '../../core/constants/api_constants.dart';
import '../api/api_service.dart';

class AMapLocationSnapshot {
  const AMapLocationSnapshot({
    required this.raw,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.address,
    this.province,
    this.city,
    this.district,
    this.country,
    this.poiName,
    this.callbackTime,
    this.locationTime,
    this.errorCode,
    this.errorInfo,
  });

  factory AMapLocationSnapshot.fromRaw(Map<String, Object> result) {
    final raw = Map<String, Object?>.from(result);
    return AMapLocationSnapshot(
      raw: raw,
      latitude: _doubleValue(raw['latitude']),
      longitude: _doubleValue(raw['longitude']),
      accuracy: _doubleValue(raw['accuracy']),
      address: _stringValue(raw['address']),
      province: _stringValue(raw['province']),
      city: _stringValue(raw['city']),
      district: _stringValue(raw['district']),
      country: _stringValue(raw['country']),
      poiName: _stringValue(raw['poiName']),
      callbackTime: _stringValue(raw['callbackTime']),
      locationTime: _stringValue(raw['locationTime']),
      errorCode: _intValue(raw['errorCode']),
      errorInfo: _stringValue(raw['errorInfo']),
    );
  }

  final Map<String, Object?> raw;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? address;
  final String? province;
  final String? city;
  final String? district;
  final String? country;
  final String? poiName;
  final String? callbackTime;
  final String? locationTime;
  final int? errorCode;
  final String? errorInfo;

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get isSuccess => (errorCode ?? 0) == 0 && hasCoordinates;

  String get coordinateLabel {
    if (!hasCoordinates) {
      return '--';
    }
    return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
  }

  String get areaLabel {
    final parts = <String>[
      if (city != null && city!.isNotEmpty) city!,
      if (district != null && district!.isNotEmpty) district!,
      if (poiName != null && poiName!.isNotEmpty) poiName!,
    ];

    if (parts.isNotEmpty) {
      return parts.join(' / ');
    }

    if (address != null && address!.isNotEmpty) {
      return address!;
    }

    return 'Waiting for location data';
  }

  String get detailLabel {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    return areaLabel;
  }

  static double? _doubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static int? _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String? _stringValue(Object? value) {
    if (value == null) {
      return null;
    }
    return value.toString();
  }
}

class AMapLocationService {
  AMapLocationService({
    ApiService? apiServiceInstance,
    AMapFlutterLocation? locationPlugin,
  })  : _apiService = apiServiceInstance ?? apiService,
        _locationPlugin = locationPlugin ?? AMapFlutterLocation();

  final ApiService _apiService;
  final AMapFlutterLocation _locationPlugin;
  final StreamController<AMapLocationSnapshot> _locationController =
      StreamController<AMapLocationSnapshot>.broadcast();

  StreamSubscription<Map<String, Object>>? _locationSubscription;
  bool _initialized = false;
  bool _tokenLoaded = false;

  Stream<AMapLocationSnapshot> get locationStream => _locationController.stream;

  static bool get isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get hasConfiguredKey {
    if (kIsWeb) {
      return false;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AMapConstants.hasAndroidKey;
      case TargetPlatform.iOS:
        return AMapConstants.hasIosKey;
      default:
        return false;
    }
  }

  static String get missingKeyMessage {
    if (kIsWeb) {
      return 'AMap location is not supported on web.';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Missing Android AMap key. Pass --dart-define=AMAP_ANDROID_KEY=yourKey.';
      case TargetPlatform.iOS:
        return 'Missing iOS AMap key. Pass --dart-define=AMAP_IOS_KEY=yourKey.';
      default:
        return 'AMap location is not available on this platform.';
    }
  }

  Future<String?> initialize() async {
    if (!isSupportedPlatform) {
      return missingKeyMessage;
    }

    if (_initialized) {
      return hasConfiguredKey ? null : missingKeyMessage;
    }

    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);

    if (AMapConstants.hasAndroidKey || AMapConstants.hasIosKey) {
      AMapFlutterLocation.setApiKey(
        AMapConstants.androidKey,
        AMapConstants.iosKey,
      );
    }

    _locationSubscription = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      _locationController.add(AMapLocationSnapshot.fromRaw(result));
    });

    _initialized = true;
    return hasConfiguredKey ? null : missingKeyMessage;
  }

  Future<String?> startTracking({int intervalMs = 5000}) async {
    final initError = await initialize();
    if (initError != null) {
      return initError;
    }

    final permissionError = await _ensurePermissionGranted();
    if (permissionError != null) {
      return permissionError;
    }

    final locationOption = AMapLocationOption()
      ..needAddress = true
      ..geoLanguage = GeoLanguage.ZH
      ..onceLocation = false
      ..locationMode = AMapLocationMode.Hight_Accuracy
      ..locationInterval = intervalMs;

    _locationPlugin.setLocationOption(locationOption);
    _locationPlugin.startLocation();
    return null;
  }

  void stopTracking() {
    _locationPlugin.stopLocation();
  }

  Future<void> updateShareStatus(bool sharing) async {
    await _ensureTokenLoaded();
    if (!_apiService.isLoggedIn) {
      return;
    }

    try {
      await _apiService.post(
        ApiConstants.mapShareStatus,
        data: <String, dynamic>{'sharing': sharing},
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to update share status: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> uploadLocation(AMapLocationSnapshot snapshot) async {
    if (!snapshot.isSuccess) {
      return;
    }

    await _ensureTokenLoaded();
    if (!_apiService.isLoggedIn) {
      return;
    }

    try {
      await _apiService.post(
        ApiConstants.mapLocation,
        data: <String, dynamic>{
          'lat': snapshot.latitude,
          'lng': snapshot.longitude,
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to upload current location: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<Map<String, dynamic>?> fetchLocations() async {
    await _ensureTokenLoaded();
    if (!_apiService.isLoggedIn) {
      return null;
    }

    try {
      final response = await _apiService.get(ApiConstants.mapLocations);
      final data = _apiService.unwrap(response.data);
      if (data is Map<String, dynamic>) {
        return data;
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to fetch shared map locations: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    return null;
  }

  Future<void> dispose() async {
    stopTracking();
    await _locationSubscription?.cancel();
    _locationPlugin.destroy();
    await _locationController.close();
  }

  Future<void> _ensureTokenLoaded() async {
    if (_tokenLoaded) {
      return;
    }

    await _apiService.loadToken();
    _tokenLoaded = true;
  }

  Future<String?> _ensurePermissionGranted() async {
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      return null;
    }

    if (status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.restricted) {
      return 'Location permission is blocked. Please enable it in system settings.';
    }

    status = await Permission.location.request();
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      return null;
    }

    if (status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.restricted) {
      return 'Location permission is blocked. Please enable it in system settings.';
    }

    return 'Location permission was not granted.';
  }
}
