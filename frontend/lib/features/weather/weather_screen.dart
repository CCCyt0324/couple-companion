import 'package:flutter/material.dart';
import '../../services/api/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityCtrl = TextEditingController();
  Map<String, dynamic>? _weather;
  String? _reminder;
  bool _loading = false;
  String? _error;
  String _cityName = '';

  @override
  void initState() {
    super.initState();
    _autoLocate();
  }

  Future<void> _autoLocate() async {
    setState(() => _loading = true);
    try {
      final locRes = await apiService.get(ApiConstants.location);
      final loc = apiService.unwrap(locRes.data) as Map<String, dynamic>;
      final city = loc['city'] as String? ?? '北京';
      _cityName = city;
      _cityCtrl.text = city;
      _fetch(city: city);
    } catch (_) {
      _cityCtrl.text = '北京';
      _fetch(city: '北京');
    }
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch({String? city, double? lat, double? lng}) async {
    setState(() { _loading = true; _error = null; });
    final cityName = city ?? _cityCtrl.text.trim();
    try {
      final params = <String, dynamic>{'city': cityName};
      if (lat != null) { params['lat'] = lat; params['lng'] = lng; }
      final res = await apiService.get(ApiConstants.weather, params: params);
      final data = apiService.unwrap(res.data) as Map<String, dynamic>;
      setState(() {
        _weather = data['weather'] as Map<String, dynamic>?;
        _reminder = data['reminder'] as String?;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = '获取天气失败，请检查网络'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = _weather?['now'] as Map<String, dynamic>?;
    final daily = (_weather?['daily'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            AppGradientHeader(
              title: '${_cityName.isNotEmpty ? _cityName + ' ' : ''}天气',
              subtitle: _cityName.isNotEmpty ? '已定位到 $_cityName，可手动搜索其他城市' : '查看实时天气和三日预报',
              icon: '🌈',
            ),
            const SizedBox(height: 14),

            // 城市搜索
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(hintText: '输入城市名', prefixIcon: Icon(Icons.location_city_outlined)),
                    onSubmitted: (_) => _fetch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _fetch(), child: const Text('搜索')),
              ]),
            ),
            const SizedBox(height: 12),

            if (_loading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),

            if (_error != null)
              Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))),

            if (!_loading && _error == null) ...[
              // 当前天气卡片
              if (now != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppCard(
                    color: AppTheme.sky,
                    child: Column(children: [
                      Text('${now['temp'] ?? '--'}°C', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
                      Text(now['text'] ?? '', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        _stat('体感', '${now['feelsLike'] ?? '--'}°'),
                        _stat('湿度', '${now['humidity'] ?? '--'}%'),
                        _stat('风力', now['windDir']?.toString() ?? '--'),
                      ]),
                    ]),
                  ),
                ),

              // 三日预报
              if (daily.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: AppSectionTitle(title: '三日预报'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: daily.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final d = daily[i] as Map<String, dynamic>;
                      return SizedBox(
                        width: 140,
                        child: AppCard(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(d['fxDate']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(d['textDay']?.toString() ?? '--', style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('${d['tempMax']}° / ${d['tempMin']}°', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryPink)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // 贴心提醒
              if (_reminder != null && _reminder!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppCard(
                    color: AppTheme.lightPink,
                    child: Row(children: [
                      const Text('💡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_reminder!, style: const TextStyle(fontWeight: FontWeight.w500))),
                    ]),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGray)),
    ]);
  }
}
