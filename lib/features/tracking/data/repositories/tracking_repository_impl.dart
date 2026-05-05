import 'package:flutter/material.dart';
import 'package:tracker_testing/features/tracking/data/providers/amplitude_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/firebase_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/mixpanel_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/posthog_provider.dart';
import 'package:tracker_testing/features/tracking/domain/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final FirebaseProvider firebase;
  final MixpanelProvider mixpanel;
  final AmplitudeProvider amplitude;
  final PosthogProvider posthog;

  TrackingRepositoryImpl(
    this.firebase,
    this.mixpanel,
    this.amplitude,
    this.posthog,
  );

  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    await Future.wait([
      _safeCall(() => firebase.logEvent(name, params), 'Firebase'),
      _safeCall(() => mixpanel.logEvent(name, params), 'Mixpanel'),
      _safeCall(() => amplitude.logEvent(name, params), 'Amplitude'),
      _safeCall(() => posthog.logEvent(name, params), 'Posthog'),
    ]);
  }

  @override
  Future<void> trackScreen(String screenName) async {
    await Future.wait([
      _safeCall(() => firebase.logScreen(screenName), 'Firebase'),
      _safeCall(() => mixpanel.logScreen(screenName), 'Mixpanel'),
      _safeCall(() => amplitude.logScreen(screenName), 'Amplitude'),
      _safeCall(() => posthog.logScreen(screenName), 'Posthog'),
    ]);
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    await Future.wait([
      _safeCall(() => firebase.setUserProperty(name, value), 'Firebase'),
      _safeCall(() => mixpanel.setUserProperty(name, value), 'Mixpanel'),
      _safeCall(() => amplitude.setUserProperty(name, value), 'Amplitude'),
      _safeCall(() => posthog.setUserProperty(name, value), 'Posthog'),
    ]);
  }

  @override
  Future<void> identify(String userId) async {
    await Future.wait([
      _safeCall(() => firebase.setUserId(userId), 'Firebase'),
      _safeCall(() => mixpanel.identify(userId), 'Mixpanel'),
      _safeCall(() => amplitude.identify(userId), 'Amplitude'),
      _safeCall(() => posthog.identify(userId), 'Posthog'),
    ]);
  }

  Future<void> _safeCall(Future<void> Function() call, String providerName) async {
    try {
      await call();
    } catch (e) {
      debugPrint('TrackingRepository: Error in $providerName: $e');
    }
  }
}