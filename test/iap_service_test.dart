import 'dart:async';

import 'package:daylight/services/iap_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeStoreConnection implements StoreConnection {
  final StreamController<List<PurchaseDetails>> controller =
      StreamController<List<PurchaseDetails>>.broadcast();

  bool available = true;
  bool buyCalled = false;
  bool restoreCalled = false;
  bool completeCalled = false;
  ProductDetailsResponse response = ProductDetailsResponse(
    productDetails: <ProductDetails>[
      ProductDetails(
        id: IAPService.removeAdsProductId,
        title: 'Remove Ads',
        description: 'Remove ads permanently',
        price: 'NT\$ 30',
        rawPrice: 30,
        currencyCode: 'TWD',
      ),
    ],
    notFoundIDs: <String>[],
    error: null,
  );

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => controller.stream;

  @override
  Future<void> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyCalled = true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completeCalled = true;
  }

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return response;
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalled = true;
  }

  void dispose() {
    controller.close();
  }
}

void main() {
  late FakeStoreConnection store;
  late IAPService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = FakeStoreConnection();
    service = IAPService(
      storeConnection: store,
      sharedPreferencesLoader: SharedPreferences.getInstance,
    );
  });

  tearDown(() {
    service.dispose();
    store.dispose();
  });

  test('initialize loads product details and keeps cached state', () async {
    await service.initialize();

    expect(service.state.isStoreAvailable, isTrue);
    expect(service.state.priceLabel, 'NT\$ 30');
    expect(service.state.isAdRemoved, isFalse);
  });

  test('purchaseRemoveAds starts non-consumable flow', () async {
    await service.initialize();

    await service.purchaseRemoveAds();

    expect(store.buyCalled, isTrue);
    expect(service.state.isPurchasePending, isTrue);
  });

  test('restored purchase persists ad removal state', () async {
    await service.initialize();

    store.controller.add([
      PurchaseDetails(
        productID: IAPService.removeAdsProductId,
        verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: '',
          source: 'test',
        ),
        transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
        status: PurchaseStatus.restored,
      )..pendingCompletePurchase = true,
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(service.state.isAdRemoved, isTrue);
    expect(store.completeCalled, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(IAPService.adRemovedPreferenceKey), isTrue);
  });

  test('canceled purchase surfaces user-facing error', () async {
    await service.initialize();

    store.controller.add([
      PurchaseDetails(
        productID: IAPService.removeAdsProductId,
        verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: '',
          source: 'test',
        ),
        transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
        status: PurchaseStatus.canceled,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(service.state.errorMessage, '你已取消購買。');
  });

  test('store unavailable returns safe state', () async {
    store.available = false;

    await service.initialize();

    expect(service.state.isStoreAvailable, isFalse);
    expect(service.state.errorMessage, isNotNull);
  });
}
