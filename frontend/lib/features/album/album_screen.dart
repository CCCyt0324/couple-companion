import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../core/constants/api_constants.dart';
import '../../services/api/api_service.dart';
import '../../services/file_picker_web.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});
  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<dynamic> _albums = [];
  List<dynamic> _photos = [];
  int? _selectedAlbumId;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadAlbums(); }

  Future<void> _loadAlbums() async {
    try {
      final res = await apiService.get(ApiConstants.albums);
      final data = (apiService.unwrap(res.data) as List?) ?? [];
      if (mounted) {
        setState(() { _albums = data; _loading = false; if (data.isNotEmpty && _selectedAlbumId == null) { _selectedAlbumId = data[0]['id']; _loadPhotos(); } });
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _loadPhotos() async {
    if (_selectedAlbumId == null) return;
    try {
      final res = await apiService.get('${ApiConstants.albums}/$_selectedAlbumId/photos');
      if (mounted) setState(() => _photos = (apiService.unwrap(res.data) as List?) ?? []);
    } catch (_) {}
  }

  Future<void> _createAlbum() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('新建相册'), content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: '相册名称')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')), ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('创建'))],
    ));
    if (name != null && name.isNotEmpty) { await apiService.post(ApiConstants.albums, data: {'name': name}); _loadAlbums(); }
  }

  Future<void> _deleteAlbum(int id) async {
    await apiService.delete('${ApiConstants.albums}/$id');
    setState(() { if (_selectedAlbumId == id) _selectedAlbumId = null; _photos = []; });
    _loadAlbums();
  }

  // ===== 文件上传 =====
  Future<void> _pickFile() async {
    if (_selectedAlbumId == null) return;
    final picked = await pickImageFile();
    if (picked == null) return;

    _show('上传中...');

    // 使用 FormData 上传
    final dio = apiService.dio;
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(picked.bytes, filename: picked.name),
    });

    try {
      await dio.post('${ApiConstants.albums}/$_selectedAlbumId/photos/upload', data: formData);
      _loadPhotos();
      _show('上传成功 📸');
    } catch (_) {
      _show('上传失败，请检查文件大小（最大 10MB）');
    }
  }

  // ===== 粘贴图片 =====
  Future<void> _pasteImage() async {
    if (_selectedAlbumId == null) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';

    if (text.startsWith('data:image/')) {
      _show('正在上传粘贴的图片...');
      try {
        await apiService.post('${ApiConstants.albums}/$_selectedAlbumId/photos', data: {'base64': text});
        _loadPhotos();
        _show('上传成功 📸');
      } catch (_) {
        _show('上传失败');
      }
    } else {
      _show('剪贴板中没有图片，请先用截图工具截图后粘贴，或点击「选择文件」上传');
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    await apiService.delete('${ApiConstants.albums}/photos/$photoId');
    _loadPhotos();
  }

  Future<void> _toggleLike(int photoId) async {
    await apiService.post('${ApiConstants.albums}/photos/$photoId/like');
    _loadPhotos();
  }

  Future<void> _addComment(int photoId) async {
    final ctrl = TextEditingController();
    final content = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('评论'), content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: '说点什么...')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')), ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('发送'))],
    ));
    if (content != null && content.isNotEmpty) {
      await apiService.post('${ApiConstants.albums}/photos/$photoId/comments', data: {'content': content});
      _loadPhotos();
    }
  }

  Future<void> _showComments(int photoId) async {
    try {
      final res = await apiService.get('${ApiConstants.albums}/photos/$photoId/comments');
      final comments = (apiService.unwrap(res.data) as List?) ?? [];
      if (mounted) {
        showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('💬 评论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (comments.isEmpty) const Text('暂无评论', style: TextStyle(color: AppTheme.textGray)),
            ...comments.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 28, height: 28, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.lightPink), child: const Center(child: Text('👤', style: TextStyle(fontSize: 14)))),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c['content']?.toString() ?? '', style: const TextStyle(fontSize: 14)),
                Text(c['createdAt']?.toString().substring(0, 16) ?? '', style: const TextStyle(fontSize: 10, color: AppTheme.textGray)),
              ])),
            ]))),
          ]),
        ));
      }
    } catch (_) {}
  }

  void _show(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgColor,
    appBar: AppBar(title: const Text('📸 共享相册'), actions: [
      if (_selectedAlbumId != null) IconButton(onPressed: _pickFile, icon: const Icon(Icons.add_a_photo, color: AppTheme.primaryPink)),
      if (_selectedAlbumId != null) IconButton(onPressed: _pasteImage, icon: const Icon(Icons.content_paste, color: AppTheme.primaryPink)),
      IconButton(onPressed: _createAlbum, icon: const Icon(Icons.create_new_folder_outlined, color: AppTheme.primaryPink)),
    ]),
    body: _loading ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink)) : Column(children: [
      SizedBox(height: 56, child: _albums.isEmpty ? const Center(child: Text('点击右上角📁创建相册')) : ListView.builder(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: _albums.length,
        itemBuilder: (_, i) {
          final a = _albums[i] as Map; final sel = _selectedAlbumId == a['id'];
          return GestureDetector(
            onTap: () { setState(() { _selectedAlbumId = a['id']; _loadPhotos(); }); },
            onLongPress: () => _deleteAlbum(a['id']),
            child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: sel ? AppTheme.primaryPink : Colors.white, borderRadius: BorderRadius.circular(20), border: sel ? null : Border.all(color: AppTheme.stroke)), child: Center(child: Text(a['name']?.toString() ?? '', style: TextStyle(color: sel ? Colors.white : AppTheme.textDark, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)))),
          );
        },
      )),
      const SizedBox(height: 4),
      // 提示文字
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('📷 点击右上角相机选文件 ｜ 📋 截图后点粘贴按钮上传', style: const TextStyle(fontSize: 11, color: AppTheme.textGray))),
      const SizedBox(height: 6),

      Expanded(child: _photos.isEmpty ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('📷', style: TextStyle(fontSize: 48)), SizedBox(height: 8), Text('点击右上角📸上传照片', style: TextStyle(color: AppTheme.textGray))])) : GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
        itemCount: _photos.length,
        itemBuilder: (_, i) {
          final p = _photos[i] as Map; final likes = (p['likeCount'] as int?) ?? 0;
          final comments = (p['comments'] as List?) ?? [];
          final url = p['url']?.toString() ?? '';
          final fullUrl = '${ApiConstants.baseUrl.replaceFirst('/api', '')}$url';

          return GestureDetector(
            onDoubleTap: () => _toggleLike(p['id']),
            onLongPress: () => _showComments(p['id']),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey.shade100, boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4, offset: const Offset(0, 2))]),
              clipBehavior: Clip.antiAlias,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(fullUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 40, color: AppTheme.textGray)))),
                Positioned(bottom: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black45], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Row(children: [
                  GestureDetector(onTap: () => _toggleLike(p['id']), child: Row(children: [const Text('❤️', style: TextStyle(fontSize: 14)), const SizedBox(width: 3), Text('$likes', style: const TextStyle(color: Colors.white, fontSize: 12))])),
                  const SizedBox(width: 10),
                  GestureDetector(onTap: () => _showComments(p['id']), child: Row(children: [const Text('💬', style: TextStyle(fontSize: 14)), const SizedBox(width: 3), Text('${comments.length}', style: const TextStyle(color: Colors.white, fontSize: 12))])),
                  const Spacer(),
                  GestureDetector(onTap: () => _deletePhoto(p['id']), child: const Icon(Icons.delete_outline, color: Colors.white70, size: 18)),
                ]))),
              ]),
            ),
          );
        },
      )),
    ]),
  );
}
