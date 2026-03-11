import 'package:flutter/foundation.dart';

class AdMobIds {
  AdMobIds._();

  static const String _androidDebugBanner =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosDebugBanner =
      'ca-app-pub-3940256099942544/2934735716';

  static const String _androidReleaseBanner =
      'ca-app-pub-5935990202404330/6410634988';
  static const String _iosReleaseBanner =
      'ca-app-pub-5935990202404330/8386061637';

  static String? bannerAdUnitId(TargetPlatform platform) {
    if (kDebugMode) {
      return switch (platform) {
        TargetPlatform.android => _androidDebugBanner,
        TargetPlatform.iOS => _iosDebugBanner,
        _ => null,
      };
    }

    return switch (platform) {
      TargetPlatform.android => _androidReleaseBanner,
      TargetPlatform.iOS => _iosReleaseBanner,
      _ => null,
    };
  }
}
