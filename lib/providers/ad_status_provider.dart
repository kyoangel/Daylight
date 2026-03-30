import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/iap_service.dart';

final iapServiceProvider = Provider<IAPService>((ref) {
  final service = IAPService();
  ref.onDispose(service.dispose);
  return service;
});

class AdStatusNotifier extends StateNotifier<AdStatusState> {
  AdStatusNotifier(this._iapService) : super(_iapService.state) {
    _subscription = _iapService.stream.listen((nextState) {
      state = nextState;
    });
    unawaited(_iapService.initialize());
  }

  final IAPService _iapService;
  StreamSubscription<AdStatusState>? _subscription;

  Future<void> purchaseRemoveAds() => _iapService.purchaseRemoveAds();

  Future<void> restorePurchases() => _iapService.restorePurchases();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final adStatusProvider = StateNotifierProvider<AdStatusNotifier, AdStatusState>(
  (ref) {
    return AdStatusNotifier(ref.watch(iapServiceProvider));
  },
);
