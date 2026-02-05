import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/common/app_strings.dart';

void main() {
  test('AppStrings nightly closing respects tone', () {
    final strings = AppStrings.of('zh-TW');

    expect(strings.nightlyClosingBody('gentle').isNotEmpty, true);
    expect(strings.nightlyClosingBody('encourage').isNotEmpty, true);
    expect(strings.nightlyClosingBody('short').isNotEmpty, true);
  });

  test('AppStrings weekly closing respects tone', () {
    final strings = AppStrings.of('zh-TW');

    expect(strings.weeklyClosingLine('gentle'), strings.weeklyClosingGentle);
    expect(strings.weeklyClosingLine('encourage'), strings.weeklyClosingEncourage);
    expect(strings.weeklyClosingLine('short'), strings.weeklyClosingShort);
  });

  test('AppStrings response lines respect tone', () {
    final strings = AppStrings.of('zh-TW');

    expect(strings.responseSavedLine('gentle').isNotEmpty, true);
    expect(strings.responseSavedLine('encourage').isNotEmpty, true);
    expect(strings.responseSavedLine('short').isNotEmpty, true);
    expect(strings.responseTaskDoneLine('gentle'), strings.responseTaskDoneGentle);
    expect(strings.responseTaskDoneLine('encourage'), strings.responseTaskDoneEncourage);
    expect(strings.responseTaskDoneLine('short'), strings.responseTaskDoneShort);
  });

  test('AppStrings companion reply respects tone', () {
    final strings = AppStrings.of('zh-TW');

    expect(strings.companionReplyLine('gentle'), strings.companionReplyGentle);
    expect(strings.companionReplyLine('encourage'), strings.companionReplyEncourage);
    expect(strings.companionReplyLine('short'), strings.companionReplyShort);
  });
}
