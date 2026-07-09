import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../services/api/api_service.dart';
import '../../core/constants/api_constants.dart';

class ButlerScreen extends StatefulWidget {
  const ButlerScreen({super.key});
  @override
  State<ButlerScreen> createState() => _ButlerScreenState();
}

class _ButlerScreenState extends State<ButlerScreen> {
  final _messages = <_ChatMessage>[];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(const _ChatMessage(
      role: 'assistant',
      content: '喵～你好呀！我是暹暹，你的AI恋爱管家🐱 有什么想聊的都可以问我哦～',
    ));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _loading = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    try {
      final res = await apiService.post(ApiConstants.butlerChat, data: {
        'messages': _messages
            .where((m) => m.role != 'system')
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
      });
      final data = apiService.unwrap(res.data) as Map<String, dynamic>;
      setState(() {
        _messages.add(_ChatMessage.fromJson(data));
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() {
        _messages.add(const _ChatMessage(
          role: 'assistant', content: '喵～网络出了点问题，稍后再试吧😿',
        ));
        _loading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: Column(children: [
          const AppGradientHeader(title: 'AI 恋爱管家', subtitle: '随问随答 · 你的专属恋爱军师', icon: '🐱'),
          // 消息列表
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),
          // 输入栏
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -1))]),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  maxLines: 4, minLines: 1,
                  decoration: const InputDecoration(
                    hintText: '和暹暹聊聊...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _loading
                  ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryPink))
                  : GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryPink),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final isMe = msg.role == 'user';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryPink : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(18),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(isMe ? '我' : '🐱 暹暹', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isMe ? Colors.white70 : AppTheme.primaryPink)),
          const SizedBox(height: 4),
          Text(msg.content, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : AppTheme.textDark, height: 1.5)),
        ]),
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String content;
  const _ChatMessage({required this.role, required this.content});
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _ChatMessage(
    role: json['role'] as String? ?? 'assistant',
    content: json['content'] as String? ?? '',
  );
}
