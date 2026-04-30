import 'package:tracker_testing/features/tracking/domain/tracking_repository.dart';

class SetUserProperty {
  final TrackingRepository repository;

  SetUserProperty(this.repository);

  Future<void> call(String name, String value) {
    return repository.setUserProperty(name, value);
  }
}
