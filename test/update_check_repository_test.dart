import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:daylight/data/models/update_info.dart';
import 'package:daylight/data/repositories/update_check_repository.dart';

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

    test('isNewerThan returns true only when buildNumber is greater', () {
      const info = UpdateInfo(
        version: '1.1.0',
        buildNumber: 11,
        url: 'https://example.com',
        notes: '',
      );

      expect(info.isNewerThan(10), isTrue);
      expect(info.isNewerThan(11), isFalse);
      expect(info.isNewerThan(12), isFalse);
    });
  });

  group('UpdateCheckRepository', () {
    test('fetchLatest returns UpdateInfo when the request succeeds', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://raw.githubusercontent.com/kyoangel/Daylight/main/version.json',
        );
        return http.Response(
          jsonEncode({
            'version': '1.1.0',
            'buildNumber': 11,
            'url': 'https://drive.google.com/file/d/abc/view',
            'notes': '修正已知問題',
          }),
          200,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final repository = UpdateCheckRepository(client: client);

      final info = await repository.fetchLatest();

      expect(info, isNotNull);
      expect(info!.version, '1.1.0');
      expect(info.buildNumber, 11);
    });

    test('fetchLatest returns null when the server responds with an error status', () async {
      final client = MockClient((request) async => http.Response('Not Found', 404));
      final repository = UpdateCheckRepository(client: client);

      final info = await repository.fetchLatest();

      expect(info, isNull);
    });

    test('fetchLatest returns null when the request throws', () async {
      final client = MockClient((request) async => throw Exception('network error'));
      final repository = UpdateCheckRepository(client: client);

      final info = await repository.fetchLatest();

      expect(info, isNull);
    });
  });
}
