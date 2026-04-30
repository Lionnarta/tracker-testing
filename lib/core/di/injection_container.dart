import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart'; // Added this
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:tracker_testing/core/config/env.dart';
import 'package:tracker_testing/core/tracking_service.dart';
import 'package:tracker_testing/features/tracking/data/providers/amplitude_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/firebase_provider.dart';
import 'package:tracker_testing/features/tracking/data/providers/mixpanel_provider.dart';
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

  final mixpanel = await Mixpanel.init(
    Env.mixpanelToken,
    trackAutomaticEvents: true,
  );

  // 3. Initialize Amplitude (New 4.5.0 API)
  // We use the constructor directly and await isBuilt
  final amplitude = Amplitude(Configuration(apiKey: Env.amplitudeToken));
  await amplitude.isBuilt;

  // 2. Providers
  sl.registerLazySingleton(() => FirebaseProvider(analytics));
  sl.registerLazySingleton(() => MixpanelProvider(mixpanel));
  sl.registerLazySingleton(() => AmplitudeProvider(amplitude));

  // 3. Repository
  sl.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(
      sl<FirebaseProvider>(),
      sl<MixpanelProvider>(),
      sl<AmplitudeProvider>(),
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
