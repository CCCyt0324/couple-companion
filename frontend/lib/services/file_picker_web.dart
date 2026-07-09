import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// 打开系统文件选择器，返回选中文件的字节数组
Future<({String name, Uint8List bytes, String mime})?> pickImageFile() async {
  final completer = Completer<({String name, Uint8List bytes, String mime})?>();

  final input = html.FileUploadInputElement();
  input.accept = 'image/*';
  input.multiple = false;

  input.addEventListener('change', (event) async {
    final files = input.files;
    if (files == null || files.isEmpty) {
      completer.complete(null);
      return;
    }
    final file = files[0];
    final reader = html.FileReader();
    reader.addEventListener('load', (e) {
      final result = reader.result;
      if (result is Uint8List) {
        completer.complete((name: file.name, bytes: result, mime: file.type));
      } else {
        completer.complete(null);
      }
    });
    reader.readAsArrayBuffer(file);
  });

  input.addEventListener('cancel', (_) => completer.complete(null));

  input.click();
  return completer.future;
}
