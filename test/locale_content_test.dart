import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/data/content/content_loader.dart';
import 'package:daylight/data/content/content_repository.dart';

class FakeLoader implements ContentLoader {
  FakeLoader(this._map);

  final Map<String, List<Map<String, dynamic>>> _map;

  @override
  Future<List<Map<String, dynamic>>> loadList(String assetPath) async {
    return _map[assetPath] ?? [];
  }
}

void main() {
  test('ContentRepository loads by locale path', () async {
    final loader = FakeLoader({
      'assets/content/en/affirmations.json': [
        {'id': 'a1', 'text': 'hello', 'tags': [], 'weight': 1}
      ],
    });

    final repo = ContentRepository(loader: loader, locale: 'en');
    final items = await repo.loadAffirmations();

    expect(items.first.text, 'hello');
  });
}
