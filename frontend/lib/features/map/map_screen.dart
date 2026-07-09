import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../services/location/amap_location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final AMapLocationService _locationService = AMapLocationService();

  StreamSubscription<AMapLocationSnapshot>? _locationSubscription;
  Map<String, dynamic> _mapSnapshot =
      Map<String, dynamic>.from(MockData.mapSnapshot);
  AMapLocationSnapshot? _currentLocation;

  bool _sharing = true;
  bool _isLocating = true;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startLocationFlow();
  }

  @override
  void dispose() {
    unawaited(_locationSubscription?.cancel());
    unawaited(_locationService.dispose());
    super.dispose();
  }

  Future<void> _startLocationFlow() async {
    setState(() {
      _isLocating = true;
      _errorMessage = null;
      _statusMessage = 'Initializing AMap location...';
    });

    await _locationSubscription?.cancel();
    _locationSubscription =
        _locationService.locationStream.listen(_handleLocationUpdate);

    final remoteSnapshot = await _locationService.fetchLocations();
    if (remoteSnapshot != null && mounted) {
      setState(() {
        _mapSnapshot = remoteSnapshot;
      });
    }

    final error = await _locationService.startTracking();
    if (!mounted) {
      return;
    }

    setState(() {
      _isLocating = false;
      _errorMessage = error;
      _statusMessage = error ?? 'Location started. Waiting for the first update...';
    });

    if (_sharing) {
      unawaited(_locationService.updateShareStatus(true));
    }
  }

  void _handleLocationUpdate(AMapLocationSnapshot snapshot) {
    if (!mounted) {
      return;
    }

    setState(() {
      _currentLocation = snapshot;
      if (snapshot.isSuccess) {
        _errorMessage = null;
        _statusMessage =
            'Updated ${snapshot.callbackTime ?? snapshot.locationTime ?? 'just now'}';
      } else {
        _errorMessage = snapshot.errorInfo ?? 'AMap returned an invalid result.';
        _statusMessage = _errorMessage;
      }
    });

    if (_sharing && snapshot.isSuccess) {
      unawaited(_locationService.uploadLocation(snapshot));
    }
  }

  Future<void> _toggleSharing(bool value) async {
    setState(() => _sharing = value);
    await _locationService.updateShareStatus(value);

    if (value && _currentLocation?.isSuccess == true) {
      await _locationService.uploadLocation(_currentLocation!);
    }
  }

  Future<void> _restartLocation() async {
    _locationService.stopTracking();
    await _startLocationFlow();
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  Map<String, dynamic>? get _partnerLocation {
    final raw = _mapSnapshot['partnerLocation'];
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.cast<String, dynamic>();
    }
    return null;
  }

  String get _distanceLabel {
    final remoteDistance = _mapSnapshot['distance'];
    if (remoteDistance is String && remoteDistance.isNotEmpty) {
      return remoteDistance;
    }

    final partner = _partnerLocation;
    if (_currentLocation?.hasCoordinates != true || partner == null) {
      return 'Waiting for both locations';
    }

    final partnerLat = _readDouble(partner['lat']);
    final partnerLng = _readDouble(partner['lng']);
    if (partnerLat == null || partnerLng == null) {
      return 'Waiting for both locations';
    }

    final distanceKm = _calculateDistanceKm(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      partnerLat,
      partnerLng,
    );

    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get _myCoordinateLabel {
    if (_currentLocation?.hasCoordinates == true) {
      return _currentLocation!.coordinateLabel;
    }

    final myLocation = _mapSnapshot['myLocation'];
    if (myLocation is Map) {
      final lat = _readDouble(myLocation['lat']);
      final lng = _readDouble(myLocation['lng']);
      if (lat != null && lng != null) {
        return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
      }
    }

    return 'Waiting for location data';
  }

  String get _partnerCoordinateLabel {
    final partner = _partnerLocation;
    if (partner == null) {
      return 'Partner location is not shared';
    }

    final lat = _readDouble(partner['lat']);
    final lng = _readDouble(partner['lng']);
    if (lat == null || lng == null) {
      return 'Partner location is not shared';
    }

    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  String get _partnerStatusLabel {
    final partnerSharing = _mapSnapshot['partnerSharing'];
    if (partnerSharing == false) {
      return 'Partner sharing is disabled';
    }

    final partner = _partnerLocation;
    if (partner == null) {
      return 'Waiting for partner location';
    }

    final updatedAt = partner['updatedAt'];
    if (updatedAt != null) {
      return 'Last sync $updatedAt';
    }

    return 'Latest shared location is ready';
  }

  String get _currentLocationSummary {
    if (_errorMessage != null && _errorMessage!.isNotEmpty) {
      return _errorMessage!;
    }

    if (_currentLocation == null) {
      return AMapLocationService.hasConfiguredKey
          ? 'The first location callback will appear here.'
          : 'Add the AMap key first, then restart the page.';
    }

    return _currentLocation!.detailLabel;
  }

  String get _keyStatusLabel {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
        return AMapLocationService.hasConfiguredKey
            ? 'Android key ready'
            : 'Android key missing';
      case TargetPlatform.iOS:
        return AMapLocationService.hasConfiguredKey
            ? 'iOS key ready'
            : 'iOS key missing';
      default:
        return 'Unsupported platform';
    }
  }

  @override
  Widget build(BuildContext context) {
    final partnerSharing = _mapSnapshot['partnerSharing'] != false;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            AppGradientHeader(
              title: 'Couple Map',
              subtitle: 'AMap location is live with sharing toggle and /map upload hooks.',
              icon: 'GPS',
              trailing: AppInfoChip(
                label: _keyStatusLabel,
                icon: AMapLocationService.hasConfiguredKey ? 'OK' : '!',
                background: Colors.white.withOpacity(0.18),
                foreground: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                color: AppTheme.sky,
                child: SizedBox(
                  height: 248,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.72),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_searching_rounded,
                          size: 34,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _distanceLabel,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          _currentLocationSummary,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          AppInfoChip(
                            label: _statusMessage ?? 'Waiting for location',
                            icon: _isLocating ? '...' : 'ON',
                            background: Colors.white,
                          ),
                          AppInfoChip(
                            label: _sharing ? 'Sharing enabled' : 'Local only',
                            icon: _sharing ? 'UP' : 'OFF',
                            background: Colors.white,
                          ),
                          if (_currentLocation?.accuracy != null)
                            AppInfoChip(
                              label:
                                  'Accuracy ${_currentLocation!.accuracy!.toStringAsFixed(0)}m',
                              icon: 'GPS',
                              background: Colors.white,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _sharing,
                      onChanged: _toggleSharing,
                      title: const Text('Share my location'),
                      subtitle: const Text('Upload real-time coordinates to /map/location'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLocating ? null : _restartLocation,
                            icon: const Icon(Icons.my_location_rounded),
                            label: const Text('Restart tracking'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openSettings,
                            icon: const Icon(Icons.settings_outlined),
                            label: const Text('Permissions'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                child: Column(
                  children: [
                    _LocationTile(
                      badge: 'ME',
                      title: 'My location',
                      subtitle: _myCoordinateLabel,
                      caption: _currentLocation?.detailLabel ??
                          'Detailed address will appear after the first update',
                    ),
                    const Divider(),
                    _LocationTile(
                      badge: 'TA',
                      title: 'Partner location',
                      subtitle: _partnerCoordinateLabel,
                      caption: partnerSharing
                          ? _partnerStatusLabel
                          : 'Partner sharing is currently disabled',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                color: AppTheme.peach,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Setup hint',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Inject AMap keys with --dart-define. Use AMAP_ANDROID_KEY for Android and AMAP_IOS_KEY for iOS.',
                      style: TextStyle(
                        color: AppTheme.textGray,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppInfoChip(
                          label: 'Android appId com.couple.couple_companion',
                          icon: 'A',
                          background: Colors.white,
                        ),
                        AppInfoChip(
                          label: 'iOS bundleId com.couple.coupleCompanion',
                          icon: 'i',
                          background: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.caption,
  });

  final String badge;
  final String title;
  final String subtitle;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppTheme.lightPink,
        child: Text(
          badge,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: const TextStyle(
                color: AppTheme.textGray,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double? _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

double _calculateDistanceKm(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) {
  const earthRadiusKm = 6371.0;
  final latDistance = _toRadians(endLat - startLat);
  final lngDistance = _toRadians(endLng - startLng);
  final a = math.sin(latDistance / 2) * math.sin(latDistance / 2) +
      math.cos(_toRadians(startLat)) *
          math.cos(_toRadians(endLat)) *
          math.sin(lngDistance / 2) *
          math.sin(lngDistance / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _toRadians(double degree) {
  return degree * math.pi / 180;
}
