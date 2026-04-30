import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:flutter/foundation.dart';

class AmplitudeProvider {
  final Amplitude _amplitude;

  AmplitudeProvider(this._amplitude);

  Future<void> logEvent(String name, Map<String, dynamic>? params) async {
    debugPrint('AmplitudeProvider: Logging event "$name"');
    // In 4.5.0, we must wrap the event in a BaseEvent object
    await _amplitude.track(BaseEvent(name, eventProperties: params));
    await _amplitude.flush();
  }

  Future<void> logScreen(String name) async {
    debugPrint('AmplitudeProvider: Logging screen "$name"');
    await _amplitude.track(BaseEvent('screen_view', eventProperties: {'screen_name': name}));
    await _amplitude.flush();
  }

  Future<void> setUserProperty(String name, String value) async {
    debugPrint('AmplitudeProvider: Setting user property "$name"');
    // In 4.5.0, we use the Identify object
    final identify = Identify().set(name, value);
    await _amplitude.identify(identify);
    await _amplitude.flush();
  }

  Future<void> identify(String userId) async {
    debugPrint('AmplitudeProvider: Identifying user "$userId"');
    await _amplitude.setUserId(userId);
    await _amplitude.flush();
  }
}