import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DockBadgeSource {
  static const _channel = MethodChannel('io.github.q-1-p/dock_badge');

  Future<void> setBadge(String? label) async {
    try {
      await _channel.invokeMethod<void>('setBadgeLabel', {
        'label': label ?? '',
      });
    } on PlatformException catch (e) {
      debugPrint('DockBadge not supported: ${e.message}');
    }
  }
}
