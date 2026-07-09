import '../config/env_config.dart';

class ApiConstants {
  static String get baseUrl => EnvConfig.apiBaseUrl;
  static String get wsUrl => EnvConfig.wsBaseUrl;

  // Auth
  static String get loginPhone => '$baseUrl/auth/login/phone';
  static String get loginEmail => '$baseUrl/auth/login/email';
  static String get registerPhone => '$baseUrl/auth/register/phone';
  static String get registerEmail => '$baseUrl/auth/register/email';
  static String get sendSms => '$baseUrl/auth/sms/send';

  // Room
  static String get myRoom => '$baseUrl/room';
  static String get joinRoom => '$baseUrl/room/join';
  static String get userProfile => '$baseUrl/user/profile';

  // Greeting
  static String get greetingToday => '$baseUrl/greeting/today';
  static String get greetingContent => '$baseUrl/greeting/content';
  static String get greetingBgImage => '$baseUrl/greeting/bg-image';

  // Habit
  static String get habits => '$baseUrl/habit';
  static String get habitToggle => '$baseUrl/habit';
  static String get habitStats => '$baseUrl/habit/today-stats';

  // Todo
  static String get todos => '$baseUrl/todo';

  // Mood
  static String get moodToday => '$baseUrl/mood/today';
  static String get moodRecord => '$baseUrl/mood';
  static String get moodHistory => '$baseUrl/mood/history';
  static String get moodCompare => '$baseUrl/mood/compare';

  // Period
  static String get periodToday => '$baseUrl/period/today';
  static String get periodRecord => '$baseUrl/period/record';
  static String get periodSetting => '$baseUrl/period/setting';
  static String get periodPredict => '$baseUrl/period/predict';
  static String get periodCountdown => '$baseUrl/period/countdown';

  // Weather
  static String get weather => '$baseUrl/weather';

  // Anniversary
  static String get anniversaries => '$baseUrl/anniversary';
  static String get anniversaryUpcoming => '$baseUrl/anniversary/upcoming';

  // Album
  static String get albums => '$baseUrl/album';

  // Wish
  static String get wishes => '$baseUrl/wish';

  // Status
  static String get statusMine => '$baseUrl/status/mine';
  static String get status => '$baseUrl/status';

  // Games
  static String get gameRoom => '$baseUrl/games/room';
  static String get gameHistory => '$baseUrl/games/history';
  static String get gameMatch => '$baseUrl/games/match';

  // Butler
  static String get butlerAdvice => '$baseUrl/butler/advice';
  static String get butlerChat => '$baseUrl/butler/chat';

  // Map
  static String get mapLocation => '$baseUrl/map/location';
  static String get mapLocations => '$baseUrl/map/locations';
  static String get mapShareStatus => '$baseUrl/map/share-status';

  // Location（无需登录）
  static String get location => '$baseUrl/location';
  static String get locationGeocode => '$baseUrl/location/geocode';
}
