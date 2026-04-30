import 'package:tracker_testing/features/tracking/domain/usecases/track_event.dart';
import 'package:tracker_testing/features/tracking/domain/usecases/track_screen.dart';
import 'package:tracker_testing/features/tracking/domain/usecases/set_user_property.dart';
import 'package:tracker_testing/features/tracking/domain/usecases/identify_user.dart';

class TrackingService {
  final TrackEvent trackEvent;
  final TrackScreen trackScreen;
  final SetUserProperty setUserPropertyUseCase;
  final IdentifyUser identifyUserUseCase;

  TrackingService({
    required this.trackEvent,
    required this.trackScreen,
    required this.setUserPropertyUseCase,
    required this.identifyUserUseCase,
  });

  Future<void> logEvent(String name, {Map<String, dynamic>? params}) {
    return trackEvent(name, params: params);
  }

  Future<void> logScreen(String name) {
    return trackScreen(name);
  }

  Future<void> setUserProperty(String name, String value) {
    return setUserPropertyUseCase(name, value);
  }

  Future<void> identify(String userId) {
    return identifyUserUseCase(userId);
  }
}
