import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelProvider {
  final Mixpanel? _mixpanel;

  MixpanelProvider(this._mixpanel);

  Future<void> logEvent(String name, Map<String, dynamic>? params) async {
    if (_mixpanel == null) return;
    debugPrint('MixpanelProvider: Logging event "$name"');
    _mixpanel.track(name, properties: params);
    _mixpanel.flush(); // Force immediate upload
  }

  Future<void> logScreen(String screenName) async {
    if (_mixpanel == null) return;
    debugPrint('MixpanelProvider: Logging screen "$screenName"');
    _mixpanel.track('screen_view', properties: {'screen_name': screenName});
    _mixpanel.flush(); // Force immediate upload
  }

  Future<void> setUserProperty(String name, String value) async {
    if (_mixpanel == null) return;
    debugPrint('MixpanelProvider: Setting user property "$name"');
    _mixpanel.getPeople().set(name, value);
    _mixpanel.flush(); // Force immediate upload
  }

  Future<void> identify(String userId) async {
    if (_mixpanel == null) return;
    debugPrint('MixpanelProvider: Identifying user "$userId"');
    _mixpanel.identify(userId);
    _mixpanel.flush();
  }
}
