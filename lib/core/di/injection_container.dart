import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_session_replay/amplitude_session_replay.dart' as amp_replay;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:mixpanel_flutter_session_replay/mixpanel_flutter_session_replay.dart' as mix_replay;
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:tracker_testing/core/config/env.dart';
import 'package:tracker_testing/core/tracking_service.dart';
import 'package:tracker_testing/features/tracking/data/providers/amplitude_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/firebase_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/mixpanel_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/posthog_provider.dart';
import 'package:tracker_testing/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:tracker_testing/features/tracking/domain/tracking_repository.dart';
import 'package:tracker_testing/features/tracking/domain/usecases/identify_user.dart';
import 'package:tracker_testing/features/tracking/domain/usecases/set_user_property.dart';
import 'package:tracker_testing/features/tracking/domain/usecases/track_event.dart';
import 'package:tracker_testing/features/tracking/domain/usecases/track_screen.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. External SDKs
  final analytics = FirebaseAnalytics.instance;
  await analytics.setAnalyticsCollectionEnabled(true);
  
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = crashlytics.recordFlutterError;

  // Initialize Mixpanel
  Mixpanel? mixpanel;
  mix_replay.MixpanelSessionReplay? mixpanelReplay;
  debugPrint('DI: Mixpanel Token Length: ${Env.mixpanelToken.length}');
  if (Env.mixpanelToken.isNotEmpty) {
    try {
      mixpanel = await Mixpanel.init(
        Env.mixpanelToken,
        trackAutomaticEvents: true,
      );
      
      // Mixpanel Session Replay
      final replayResult = await mix_replay.MixpanelSessionReplay.initialize(
        token: Env.mixpanelToken,
        distinctId: await mixpanel.getDistinctId(),
        options: mix_replay.SessionReplayOptions(
          autoRecordSessionsPercent: 100.0,
          logLevel: mix_replay.LogLevel.debug,
        ),
      );
      if (replayResult.success) {
        mixpanelReplay = replayResult.instance;
        debugPrint('DI: ✅ Mixpanel Session Replay initialized.');
      } else {
        debugPrint('DI: ❌ Mixpanel Session Replay result failed: ${replayResult.error}');
      }
    } catch (e) {
      debugPrint('DI: ❌ Mixpanel/Replay initialization failed: $e');
    }
  } else {
    debugPrint('DI: Mixpanel token is empty. Skipping initialization.');
  }

  // Initialize Amplitude
  final amplitude = Amplitude(Configuration(apiKey: Env.amplitudeToken));
  await amplitude.isBuilt;
  
  amp_replay.SessionReplay? amplitudeReplay;
  if (Env.amplitudeToken.isNotEmpty) {
    try {
      final amplitudeReplayConfig = amp_replay.SessionReplayConfig(
        apiKey: Env.amplitudeToken,
        deviceId: await amplitude.getDeviceId() ?? 'unknown',
        sessionId: await amplitude.getSessionId() ?? DateTime.now().millisecondsSinceEpoch,
        sampleRate: 1.0,
        logLevel: amp_replay.LogLevel.debug,
      );
      
      // Correct Class Name is SessionReplay
      amplitudeReplay = amp_replay.SessionReplay(amplitudeReplayConfig);
      await amplitudeReplay.start();
      
      debugPrint('DI: ✅ Amplitude Session Replay initialized and started.');
    } catch (e) {
      debugPrint('DI: ❌ Amplitude Session Replay failed: $e');
    }
  }

  // Initialize PostHog
  final posthog = Posthog();
  debugPrint('DI: PostHog Token Length: ${Env.posthogToken.length}');
  if (Env.posthogToken.isNotEmpty) {
    try {
      final posthogConfig = PostHogConfig(Env.posthogToken);
      posthogConfig.debug = kDebugMode;
      posthogConfig.host = 'https://us.i.posthog.com';
      
      // Session Replay Requirements
      posthogConfig.sessionReplay = true;
      posthogConfig.captureApplicationLifecycleEvents = true; // Required for session segmentation
      
      // Control Privacy/Masking
      posthogConfig.sessionReplayConfig.maskAllTexts = false;
      posthogConfig.sessionReplayConfig.maskAllImages = false;
      
      await posthog.setup(posthogConfig);
      debugPrint('DI: PostHog setup complete with Session Replay.');
    } catch (e) {
      debugPrint('DI: PostHog setup failed: $e');
    }
  } else {
    debugPrint('DI: PostHog token is empty. Skipping initialization.');
  }

  // 2. Providers
  sl.registerLazySingleton(() => FirebaseProvider(analytics));
  sl.registerLazySingleton(() => MixpanelProvider(mixpanel));
  sl.registerLazySingleton(() => AmplitudeProvider(amplitude));
  sl.registerLazySingleton(() => PosthogProvider(posthog));
  
  // Register Replay Wrapper for UI (GetIt doesn't allow nullable types)
  sl.registerSingleton(ReplayConfig(
    mixpanel: mixpanelReplay,
    amplitude: amplitudeReplay,
  ));

  // 3. Repository
  sl.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(
      sl<FirebaseProvider>(),
      sl<MixpanelProvider>(),
      sl<AmplitudeProvider>(),
      sl<PosthogProvider>(),
    ),
  );

  // 4. UseCases
  sl.registerLazySingleton(() => TrackEvent(sl()));
  sl.registerLazySingleton(() => TrackScreen(sl()));
  sl.registerLazySingleton(() => SetUserProperty(sl()));
  sl.registerLazySingleton(() => IdentifyUser(sl()));

  // 5. Service
  sl.registerLazySingleton(
    () => TrackingService(
      trackEvent: sl(),
      trackScreen: sl(),
      setUserPropertyUseCase: sl(),
      identifyUserUseCase: sl(),
    ),
  );
}

class ReplayConfig {
  final mix_replay.MixpanelSessionReplay? mixpanel;
  final amp_replay.SessionReplay? amplitude;

  ReplayConfig({this.mixpanel, this.amplitude});
}
