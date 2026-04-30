import 'package:tracker_testing/features/tracking/data/providers/amplitude_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/firebase_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/mixpanel_provider.dart';
import 'package:tracker_testing/features/tracking/domain/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final FirebaseProvider firebase;
  final MixpanelProvider mixpanel;
  final AmplitudeProvider amplitude;

  TrackingRepositoryImpl(this.firebase, this.mixpanel, this.amplitude);

  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    await Future.wait([
      firebase.logEvent(name, params),
      mixpanel.logEvent(name, params),
      amplitude.logEvent(name, params),
    ]);
  }

  @override
  Future<void> trackScreen(String screenName) async {
    await Future.wait([
      firebase.logScreen(screenName),
      mixpanel.logScreen(screenName),
      amplitude.logScreen(screenName),
    ]);
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    await Future.wait([
      firebase.setUserProperty(name, value),
      mixpanel.setUserProperty(name, value),
      amplitude.setUserProperty(name, value),
    ]);
  }

  @override
  Future<void> identify(String userId) async {
    await Future.wait([
      firebase.setUserId(userId),
      mixpanel.identify(userId),
      amplitude.identify(userId),
    ]);
  }
}