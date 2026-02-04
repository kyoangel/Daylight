import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/common/app_strings.dart';

void main() {
  test('AppStrings nightly closing respects tone', () {
    final strings = AppStrings.of('zh-TW');

    expect(strings.nightlyClosingBody('gentle'), strings.nightlyClosingBodyGentle);
    expect(strings.nightlyClosingBody('encourage'), strings.nightlyClosingBodyEncourage);
    expect(strings.nightlyClosingBody('short'), strings.nightlyClosingBodyShort);
  });

  test('AppStrings weekly closing respects tone', () {
    final strings = AppStrings.of('zh-TW');

    expect(strings.weeklyClosingLine('gentle'), strings.weeklyClosingGentle);
    expect(strings.weeklyClosingLine('encourage'), strings.weeklyClosingEncourage);
    expect(strings.weeklyClosingLine('short'), strings.weeklyClosingShort);
  });

  test('AppStrings response lines respect tone', () {
    final strings = AppStrings.of('zh-TW');

    expect(strings.responseSavedLine('gentle'), strings.responseSavedGentle);
    expect(strings.responseSavedLine('encourage'), strings.responseSavedEncourage);
    expect(strings.responseSavedLine('short'), strings.responseSavedShort);
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
