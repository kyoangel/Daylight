import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/providers/ad_status_provider.dart';
import 'package:daylight/services/iap_service.dart';
import 'package:daylight/features/profile/view/profile_page.dart';
import 'package:daylight/common/app_strings.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class FakeProfileStoreConnection implements StoreConnection {
  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      const Stream<List<PurchaseDetails>>.empty();

  @override
  Future<void> buyNonConsumable({required PurchaseParam purchaseParam}) async {}

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return ProductDetailsResponse(
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
  }

  @override
  Future<void> restorePurchases() async {}
}

void main() {
  testWidgets('ProfilePage shows nickname field and remove ads section', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = IAPService(
      storeConnection: FakeProfileStoreConnection(),
      sharedPreferencesLoader: SharedPreferences.getInstance,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [iapServiceProvider.overrideWithValue(service)],
        child: MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pump();

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.nicknameLabel), findsOneWidget);
    expect(find.text(strings.removeAdsSectionTitle), findsOneWidget);
    expect(
      find.text(
        strings.removeAdsButtonLabel(IAPService.removeAdsFallbackPriceLabel),
      ),
      findsOneWidget,
    );
  });
}
