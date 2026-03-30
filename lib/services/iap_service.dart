import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdStatusState {
  const AdStatusState({
    required this.isAdRemoved,
    required this.isStoreAvailable,
    required this.isLoading,
    required this.isPurchasePending,
    required this.isRestoring,
    required this.priceLabel,
    this.productDetails,
    this.errorMessage,
    this.statusMessage,
  });

  factory AdStatusState.initial() => const AdStatusState(
    isAdRemoved: false,
    isStoreAvailable: false,
    isLoading: true,
    isPurchasePending: false,
    isRestoring: false,
    priceLabel: IAPService.removeAdsFallbackPriceLabel,
  );

  final bool isAdRemoved;
  final bool isStoreAvailable;
  final bool isLoading;
  final bool isPurchasePending;
  final bool isRestoring;
  final String priceLabel;
  final ProductDetails? productDetails;
  final String? errorMessage;
  final String? statusMessage;

  bool get canPurchase =>
      !isAdRemoved &&
      !isLoading &&
      !isPurchasePending &&
      isStoreAvailable &&
      productDetails != null;

  AdStatusState copyWith({
    bool? isAdRemoved,
    bool? isStoreAvailable,
    bool? isLoading,
    bool? isPurchasePending,
    bool? isRestoring,
    String? priceLabel,
    ProductDetails? productDetails,
    bool clearProductDetails = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return AdStatusState(
      isAdRemoved: isAdRemoved ?? this.isAdRemoved,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      isLoading: isLoading ?? this.isLoading,
      isPurchasePending: isPurchasePending ?? this.isPurchasePending,
      isRestoring: isRestoring ?? this.isRestoring,
      priceLabel: priceLabel ?? this.priceLabel,
      productDetails:
          clearProductDetails ? null : (productDetails ?? this.productDetails),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      statusMessage:
          clearStatusMessage ? null : (statusMessage ?? this.statusMessage),
    );
  }
}

abstract class StoreConnection {
  Stream<List<PurchaseDetails>> get purchaseStream;

  Future<bool> isAvailable();

  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);

  Future<void> buyNonConsumable({required PurchaseParam purchaseParam});

  Future<void> restorePurchases();

  Future<void> completePurchase(PurchaseDetails purchase);
}

class OfficialStoreConnection implements StoreConnection {
  OfficialStoreConnection([InAppPurchase? instance])
    : _instance = instance ?? InAppPurchase.instance;

  final InAppPurchase _instance;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _instance.purchaseStream;

  @override
  Future<bool> isAvailable() => _instance.isAvailable();

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    return _instance.queryProductDetails(identifiers);
  }

  @override
  Future<void> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    await _instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases() => _instance.restorePurchases();

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return _instance.completePurchase(purchase);
  }
}

class IAPService {
  IAPService({
    StoreConnection? storeConnection,
    Future<SharedPreferences> Function()? sharedPreferencesLoader,
  }) : _storeConnection = storeConnection ?? OfficialStoreConnection(),
       _sharedPreferencesLoader =
           sharedPreferencesLoader ?? SharedPreferences.getInstance {
    _purchaseSubscription = _storeConnection.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        _emit(
          _state.copyWith(
            isLoading: false,
            isPurchasePending: false,
            isRestoring: false,
            errorMessage: '購買流程發生錯誤：$error',
          ),
        );
      },
    );
  }

  static const String removeAdsProductId = 'remove_ads';
  static const String removeAdsFallbackPriceLabel = 'NT\$ 30';
  static const String adRemovedPreferenceKey = 'is_ad_removed';

  final StoreConnection _storeConnection;
  final Future<SharedPreferences> Function() _sharedPreferencesLoader;
  final StreamController<AdStatusState> _controller =
      StreamController<AdStatusState>.broadcast();

  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  AdStatusState _state = AdStatusState.initial();
  SharedPreferences? _preferences;
  bool _initialized = false;

  AdStatusState get state => _state;

  Stream<AdStatusState> get stream => _controller.stream;

  Future<void> initialize() async {
    if (_initialized) {
      _controller.add(_state);
      return;
    }
    _initialized = true;

    try {
      _preferences ??= await _sharedPreferencesLoader();
      final cachedAdRemoved =
          _preferences?.getBool(adRemovedPreferenceKey) ?? false;
      _emit(
        _state.copyWith(
          isAdRemoved: cachedAdRemoved,
          isLoading: true,
          clearErrorMessage: true,
          clearStatusMessage: true,
        ),
      );

      final isAvailable = await _storeConnection.isAvailable();
      if (!isAvailable) {
        _emit(
          _state.copyWith(
            isStoreAvailable: false,
            isLoading: false,
            errorMessage: '商店目前無法連線，請稍後再試。',
          ),
        );
        return;
      }

      final response = await _storeConnection.queryProductDetails({
        removeAdsProductId,
      });

      if (response.error != null) {
        _emit(
          _state.copyWith(
            isStoreAvailable: true,
            isLoading: false,
            errorMessage: response.error!.message,
          ),
        );
        return;
      }

      if (response.notFoundIDs.contains(removeAdsProductId) ||
          response.productDetails.isEmpty) {
        _emit(
          _state.copyWith(
            isStoreAvailable: true,
            isLoading: false,
            errorMessage: '找不到商品 remove_ads，請確認 App Store / Google Play 設定。',
          ),
        );
        return;
      }

      final product = response.productDetails.firstWhere(
        (item) => item.id == removeAdsProductId,
        orElse: () => response.productDetails.first,
      );

      _emit(
        _state.copyWith(
          isStoreAvailable: true,
          isLoading: false,
          productDetails: product,
          priceLabel:
              product.price.isNotEmpty
                  ? product.price
                  : removeAdsFallbackPriceLabel,
          clearErrorMessage: true,
        ),
      );
    } on MissingPluginException {
      _emit(
        _state.copyWith(
          isStoreAvailable: false,
          isLoading: false,
          errorMessage: '目前環境不支援內購插件，正式裝置上才可使用。',
        ),
      );
    } on PlatformException catch (error) {
      _emit(
        _state.copyWith(
          isStoreAvailable: false,
          isLoading: false,
          errorMessage: error.message ?? '商店初始化失敗。',
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          isStoreAvailable: false,
          isLoading: false,
          errorMessage: '商店初始化失敗：$error',
        ),
      );
    }
  }

  Future<void> purchaseRemoveAds() async {
    final product = _state.productDetails;
    if (product == null) {
      _emit(
        _state.copyWith(
          errorMessage: '商品資訊尚未載入完成，請稍後再試。',
          clearStatusMessage: true,
        ),
      );
      return;
    }

    try {
      _emit(
        _state.copyWith(
          isPurchasePending: true,
          clearErrorMessage: true,
          statusMessage: '正在連接商店...',
        ),
      );
      final purchaseParam = PurchaseParam(productDetails: product);
      await _storeConnection.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (error) {
      _emit(
        _state.copyWith(
          isPurchasePending: false,
          errorMessage: error.message ?? '無法發起購買流程。',
          clearStatusMessage: true,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          isPurchasePending: false,
          errorMessage: '無法發起購買流程：$error',
          clearStatusMessage: true,
        ),
      );
    }
  }

  Future<void> restorePurchases() async {
    try {
      _emit(
        _state.copyWith(
          isRestoring: true,
          clearErrorMessage: true,
          statusMessage: '正在回復購買...',
        ),
      );
      await _storeConnection.restorePurchases();
    } on PlatformException catch (error) {
      _emit(
        _state.copyWith(
          isRestoring: false,
          errorMessage: error.message ?? '無法回復購買。',
          clearStatusMessage: true,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          isRestoring: false,
          errorMessage: '無法回復購買：$error',
          clearStatusMessage: true,
        ),
      );
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != removeAdsProductId) {
        if (purchase.pendingCompletePurchase) {
          await _safeCompletePurchase(purchase);
        }
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _emit(
            _state.copyWith(
              isPurchasePending: true,
              isRestoring: false,
              statusMessage: '交易處理中，請稍候。',
              clearErrorMessage: true,
            ),
          );
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _setAdRemoved(true);
          _emit(
            _state.copyWith(
              isAdRemoved: true,
              isLoading: false,
              isPurchasePending: false,
              isRestoring: false,
              statusMessage:
                  purchase.status == PurchaseStatus.restored
                      ? '已回復購買，廣告已移除。'
                      : '購買成功，廣告已移除。',
              clearErrorMessage: true,
            ),
          );
          break;
        case PurchaseStatus.error:
          final error = purchase.error;
          _emit(
            _state.copyWith(
              isPurchasePending: false,
              isRestoring: false,
              errorMessage: _mapPurchaseError(error),
              clearStatusMessage: true,
            ),
          );
          break;
        case PurchaseStatus.canceled:
          _emit(
            _state.copyWith(
              isPurchasePending: false,
              isRestoring: false,
              errorMessage: '你已取消購買。',
              clearStatusMessage: true,
            ),
          );
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _safeCompletePurchase(purchase);
      }
    }
  }

  String _mapPurchaseError(IAPError? error) {
    final code = error?.code.toLowerCase();
    if (code == 'purchase_not_allowed') {
      return '目前帳號不允許內購。';
    }
    if (code == 'store_unavailable') {
      return '商店暫時無法使用。';
    }
    return error?.message ?? '購買失敗，請稍後再試。';
  }

  Future<void> _safeCompletePurchase(PurchaseDetails purchase) async {
    try {
      await _storeConnection.completePurchase(purchase);
    } catch (error) {
      debugPrint('completePurchase failed: $error');
    }
  }

  Future<void> _setAdRemoved(bool value) async {
    _preferences ??= await _sharedPreferencesLoader();
    await _preferences!.setBool(adRemovedPreferenceKey, value);
  }

  void _emit(AdStatusState nextState) {
    _state = nextState;
    if (!_controller.isClosed) {
      _controller.add(nextState);
    }
  }

  void dispose() {
    _purchaseSubscription.cancel();
    _controller.close();
  }
}
