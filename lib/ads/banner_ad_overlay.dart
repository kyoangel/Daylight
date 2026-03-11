import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_ids.dart';

class BannerAdOverlay extends StatefulWidget {
  const BannerAdOverlay({super.key});

  @override
  State<BannerAdOverlay> createState() => _BannerAdOverlayState();
}

class _BannerAdOverlayState extends State<BannerAdOverlay> {
  static const double _fallbackBannerHeight = 50;
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    if (kIsWeb) return;

    final platform = defaultTargetPlatform;
    final adUnitId = AdMobIds.bannerAdUnitId(platform);
    if (adUnitId == null) return;

    final bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
          debugPrint('BannerAd failed to load: $error');
        },
      ),
    );

    await bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (!_isLoaded || ad == null) {
      return const SafeArea(
        top: false,
        child: SizedBox(height: _fallbackBannerHeight),
      );
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
