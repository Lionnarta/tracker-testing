import 'package:tracker_testing/features/tracking/domain/tracking_repository.dart';

class IdentifyUser {
  final TrackingRepository repository;

  IdentifyUser(this.repository);

  Future<void> call(String userId) {
    return repository.identify(userId);
  }
}
