import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/album/album_screen.dart';
import '../../features/anniversary/anniversary_screen.dart';
import '../../features/butler/butler_screen.dart';
import '../../features/games/game_hub_screen.dart';
import '../../features/games/game_room_screen.dart';
import '../../features/habit/habit_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/mood/mood_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/period/period_screen.dart';
import '../../features/room/room_code_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/status/status_screen.dart';
import '../../features/todo/todo_screen.dart';
import '../../features/weather/weather_screen.dart';
import '../../features/wish/wish_screen.dart';
import '../theme/app_theme.dart';

final appRouterProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (_, __, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/weather', builder: (_, __) => const WeatherScreen()),
        GoRoute(path: '/period', builder: (_, __) => const PeriodScreen()),
        GoRoute(path: '/butler', builder: (_, __) => const ButlerScreen()),
        GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
      ],
    ),
    GoRoute(path: '/room', builder: (_, __) => const RoomCodeScreen()),
    GoRoute(path: '/mood', builder: (_, __) => const MoodScreen()),
    GoRoute(path: '/anniversary', builder: (_, __) => const AnniversaryScreen()),
    GoRoute(path: '/album', builder: (_, __) => const AlbumScreen()),
    GoRoute(path: '/wish', builder: (_, __) => const WishScreen()),
    GoRoute(path: '/status', builder: (_, __) => const StatusScreen()),
    GoRoute(path: '/games', builder: (_, __) => const GameHubScreen()),
    GoRoute(path: '/games/room/:id', builder: (_, state) => GameRoomScreen(roomId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0)),
    GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/habits', builder: (_, __) => const HabitScreen()),
    GoRoute(path: '/todos', builder: (_, __) => const TodoScreen()),
  ],
));

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: NavigationBar(
            backgroundColor: Colors.white,
            selectedIndex: _currentIndex(context),
            onDestinationSelected: (i) => _onTap(context, i),
            indicatorColor: AppTheme.lightPink,
            height: 70,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppTheme.primaryPink), label: '首页'),
              NavigationDestination(icon: Icon(Icons.cloud_outlined), selectedIcon: Icon(Icons.cloud, color: AppTheme.primaryPink), label: '天气'),
              NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite, color: AppTheme.primaryPink), label: '经期'),
              NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome, color: AppTheme.primaryPink), label: '管家'),
              NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view, color: AppTheme.primaryPink), label: '更多'),
            ],
          ),
        ),
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc == '/') return 0;
    if (loc == '/weather') return 1;
    if (loc == '/period') return 2;
    if (loc == '/butler') return 3;
    return 4;
  }

  void _onTap(BuildContext context, int i) {
    const routes = ['/', '/weather', '/period', '/butler', '/more'];
    GoRouter.of(context).go(routes[i]);
  }
}
