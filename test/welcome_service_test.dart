import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/data/content/content_loader.dart';
import 'package:daylight/data/content/content_repository.dart';
import 'package:daylight/data/storage/local_storage.dart';
import 'package:daylight/features/daily/service/welcome_service.dart';

class FakeContentLoader implements ContentLoader {
  FakeContentLoader(this.items);

  final List<Map<String, dynamic>> items;

  @override
  Future<List<Map<String, dynamic>>> loadList(String assetPath) async {
    return items;
  }
}

void main() {
  test('WelcomeService returns same message for same day', () async {
    SharedPreferences.setMockInitialValues({});
    final loader = FakeContentLoader([
      {
        'id': 'welcome_001',
        'greeting': 'Hello{name}',
        'direction': 'Step one',
        'tags': [],
        'weight': 1,
      },
      {
        'id': 'welcome_002',
        'greeting': 'Hi{name}',
        'direction': 'Step two',
        'tags': [],
        'weight': 1,
      },
    ]);
    final repo = ContentRepository(loader: loader, locale: 'en');
    final service = WelcomeService(contentRepository: repo, storage: LocalStorage());

    final first = await service.getTodayMessage(
      locale: 'en',
      now: DateTime(2025, 1, 2),
    );
    final second = await service.getTodayMessage(
      locale: 'en',
      now: DateTime(2025, 1, 2),
    );

    expect(first?.id, 'welcome_002');
    expect(second?.id, 'welcome_002');
  });

  test('WelcomeService rotates message on a new day', () async {
    SharedPreferences.setMockInitialValues({});
    final loader = FakeContentLoader([
      {
        'id': 'welcome_001',
        'greeting': 'Hello{name}',
        'direction': 'Step one',
        'tags': [],
        'weight': 1,
      },
      {
        'id': 'welcome_002',
        'greeting': 'Hi{name}',
        'direction': 'Step two',
        'tags': [],
        'weight': 1,
      },
    ]);
    final repo = ContentRepository(loader: loader, locale: 'en');
    final service = WelcomeService(contentRepository: repo, storage: LocalStorage());

    final day1 = await service.getTodayMessage(
      locale: 'en',
      now: DateTime(2025, 1, 2),
    );
    final day2 = await service.getTodayMessage(
      locale: 'en',
      now: DateTime(2025, 1, 3),
    );

    expect(day1?.id, 'welcome_002');
    expect(day2?.id, 'welcome_001');
  });
}
