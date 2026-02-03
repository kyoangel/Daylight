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
  test('ContentRepository loads items via loader', () async {
    final loader = FakeLoader({
      'assets/content/affirmations.json': [
        {'id': 'a1', 'text': 'hello', 'tags': ['t1']}
      ],
      'assets/content/micro_tasks.json': [
        {'id': 't1', 'title': 'title', 'description': 'desc', 'tags': ['x']}
      ],
      'assets/content/mindfulness_guides.json': [
        {
          'id': 'm1',
          'title': 'title',
          'duration': '1 min',
          'steps': ['s1'],
          'tags': ['y']
        }
      ],
    });

    final repo = ContentRepository(loader: loader);

    final affirmations = await repo.loadAffirmations();
    final tasks = await repo.loadMicroTasks();
    final guides = await repo.loadMindfulnessGuides();

    expect(affirmations.first.id, 'a1');
    expect(tasks.first.id, 't1');
    expect(guides.first.id, 'm1');
  });
}
