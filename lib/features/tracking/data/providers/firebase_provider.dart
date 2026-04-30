import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:tracker_testing/core/utils/analytics_mapper.dart';

class FirebaseProvider {
  final FirebaseAnalytics analytics;

  FirebaseProvider(this.analytics);

  Future<void> logEvent(String name, Map<String, dynamic>? params) {
    debugPrint('FirebaseProvider: Logging event "$name" with params: $params');
    return analytics.logEvent(
      name: name,
      parameters: toAnalyticsParams(params),
    );
  }

  Future<void> logScreen(String screenName) {
    return analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  Future<void> setUserProperty(String name, String? value) {
    debugPrint('FirebaseProvider: Setting user property "$name" to "$value"');
    return analytics.setUserProperty(name: name, value: value);
  }

  Future<void> setUserId(String? userId) {
    debugPrint('FirebaseProvider: Setting user ID to "$userId"');
    return analytics.setUserId(id: userId);
  }
}
