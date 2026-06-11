import 'package:flutter_test/flutter_test.dart';
import 'package:daylight/data/models/update_info.dart';

void main() {
  group('UpdateInfo', () {
    test('fromJson parses version, buildNumber, url and notes', () {
      final json = {
        'version': '1.1.0',
        'buildNumber': 11,
        'url': 'https://drive.google.com/file/d/abc/view',
        'notes': '修正已知問題',
      };

      final info = UpdateInfo.fromJson(json);

      expect(info.version, '1.1.0');
      expect(info.buildNumber, 11);
      expect(info.url, 'https://drive.google.com/file/d/abc/view');
      expect(info.notes, '修正已知問題');
    });
  });
}
