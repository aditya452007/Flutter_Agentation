import 'package:flutter/services.dart';

abstract class ClipboardService {
  Future<void> copy(String text);
}

class SystemClipboardService implements ClipboardService {
  const SystemClipboardService();
  @override
  Future<void> copy(String text) => Clipboard.setData(ClipboardData(text: text));
}

class FakeClipboardService implements ClipboardService {
  String? text;
  @override
  Future<void> copy(String value) async {
    text = value;
  }
}
