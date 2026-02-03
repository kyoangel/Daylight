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
  test('ContentRepository pickAffirmation returns matching tag', () async {
    final loader = FakeLoader({
      'assets/content/affirmations.json': [
        {'id': 'a1', 'text': 'low', 'tags': ['low']},
        {'id': 'a2', 'text': 'high', 'tags': ['hope']},
      ],
    });

    final repo = ContentRepository(loader: loader);
    final picked = await repo.pickAffirmation(tags: ['hope']);

    expect(picked?.id, 'a2');
  });

  test('ContentRepository pickMicroTask falls back', () async {
    final loader = FakeLoader({
      'assets/content/micro_tasks.json': [
        {'id': 't1', 'title': 't', 'description': 'd', 'tags': ['x']},
      ],
    });

    final repo = ContentRepository(loader: loader);
    final picked = await repo.pickMicroTask(tags: ['missing']);

    expect(picked?.id, 't1');
  });

  test('ContentRepository pickMindfulnessGuide returns null on empty', () async {
    final loader = FakeLoader({
      'assets/content/mindfulness_guides.json': [],
    });

    final repo = ContentRepository(loader: loader);
    final picked = await repo.pickMindfulnessGuide(tags: ['calm']);

    expect(picked, isNull);
  });
}
