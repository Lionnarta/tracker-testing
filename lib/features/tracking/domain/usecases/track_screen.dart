import 'package:tracker_testing/features/tracking/domain/tracking_repository.dart';

class TrackScreen {
  final TrackingRepository repository;

  TrackScreen(this.repository);

  Future<void> call(String screenName) {
    return repository.trackScreen(screenName);
  }
}