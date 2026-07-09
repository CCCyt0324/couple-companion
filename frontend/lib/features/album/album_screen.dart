import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  int _selectedAlbumId = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('上传入口已预留，可继续接 multipart 上传')),
          );
        },
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const AppGradientHeader(
              title: '共享相册',
              subtitle: '相册列表、照片瀑布流、点赞与评论入口都已经落位。',
              icon: '🖼',
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final album = MockData.albums[index];
                  final selected = _selectedAlbumId == album['id'];
                  return ChoiceChip(
                    label: Text(album['name'] as String),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedAlbumId = album['id'] as int),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: MockData.albums.length,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: MockData.albumPhotos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
                  final photo = MockData.albumPhotos[index];
                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(photo['color'] as int),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_rounded,
                              size: 44,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                photo['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('❤️ ${photo['likes']}'),
                                  const SizedBox(width: 12),
                                  Text('💬 ${photo['comments']}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
