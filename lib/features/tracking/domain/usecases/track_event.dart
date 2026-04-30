import 'package:tracker_testing/features/tracking/domain/tracking_repository.dart';

class TrackEvent {
  final TrackingRepository repository;

  TrackEvent(this.repository);

  Future<void> call(String name, {Map<String, dynamic>? params}) {
    return repository.trackEvent(name, params: params);
  }
}
