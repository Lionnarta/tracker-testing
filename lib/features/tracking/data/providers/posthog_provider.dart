import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:flutter/foundation.dart';

class PosthogProvider {
  final Posthog _posthog;

  PosthogProvider(this._posthog);

  Future<void> logEvent(String name, Map<String, dynamic>? params) async {
    debugPrint('PosthogProvider: Logging event "$name" with params: $params');
    await _posthog.capture(
      eventName: name,
      properties: params?.cast<String, Object>(),
    );
    await _posthog.flush();
  }

  Future<void> logScreen(String screenName) async {
    debugPrint('PosthogProvider: Logging screen "$screenName"');
    await _posthog.screen(
      screenName: screenName,
    );
    await _posthog.flush();
  }

  Future<void> setUserProperty(String name, String value) async {
    debugPrint('PosthogProvider: Setting user property "$name" to "$value"');
    // Posthog uses identify or register for properties. 
    // For specific user properties, we usually use identify or set individual properties if supported.
    // In PostHog, user properties are typically sent during identify.
    // However, for individual property updates, we can use capture with special properties or just re-identify.
    return _posthog.identify(
      userId: await _posthog.getDistinctId(),
      userProperties: {name: value}.cast<String, Object>(),
    );
  }

  Future<void> identify(String userId) async {
    debugPrint('PosthogProvider: Identifying user "$userId"');
    return _posthog.identify(
      userId: userId,
    );
  }

  Future<void> reset() async {
    debugPrint('PosthogProvider: Resetting user');
    return _posthog.reset();
  }
}
