import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/common/avatar_image.dart';

void main() {
  test('avatarImageProvider handles data uri', () {
    final bytes = [0, 1, 2, 3];
    final dataUri = 'data:image/png;base64,${base64Encode(bytes)}';
    final provider = avatarImageProvider(dataUri);

    expect(provider, isA<MemoryImage>());
  });

  test('avatarImageProvider handles http url', () {
    final provider = avatarImageProvider('https://example.com/a.png');
    expect(provider, isA<NetworkImage>());
  });
}
