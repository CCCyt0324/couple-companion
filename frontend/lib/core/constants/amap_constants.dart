class AMapConstants {
  const AMapConstants._();

  static const String androidKey = String.fromEnvironment('AMAP_ANDROID_KEY');
  static const String iosKey = String.fromEnvironment('AMAP_IOS_KEY');
  static const String iosFullAccuracyPurposeKey = 'AMapLocationScene';

  static bool get hasAndroidKey => androidKey.isNotEmpty;
  static bool get hasIosKey => iosKey.isNotEmpty;
}
