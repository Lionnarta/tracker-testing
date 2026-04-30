abstract class TrackingRepository {
  Future<void> trackEvent(String name, {Map<String, dynamic>? params});
  Future<void> trackScreen(String screenName);
  Future<void> setUserProperty(String name, String value);
  Future<void> identify(String userId);
}
