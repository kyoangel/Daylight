import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/common/avatar_image.dart';

void main() {
  test('avatarMimeFromPath detects png', () {
    expect(avatarMimeFromPath('a.png'), 'image/png');
  });

  test('avatarMimeFromPath defaults to jpeg', () {
    expect(avatarMimeFromPath('a.jpg'), 'image/jpeg');
  });
}
