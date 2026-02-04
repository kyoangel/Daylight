import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/common/app_strings.dart';

void main() {
  test('AppStrings nightly closing respects tone', () {
    final strings = AppStrings.of('zh-TW');

    expect(strings.nightlyClosingBody('gentle'), strings.nightlyClosingBodyGentle);
    expect(strings.nightlyClosingBody('encourage'), strings.nightlyClosingBodyEncourage);
    expect(strings.nightlyClosingBody('short'), strings.nightlyClosingBodyShort);
  });
}
