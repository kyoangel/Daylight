import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/data/content/content_loader.dart';
import 'package:daylight/data/content/content_repository.dart';
import 'package:daylight/data/content/content_history_store.dart';

class FakeLoader implements ContentLoader {
  FakeLoader(this._map);

  final Map<String, List<Map<String, dynamic>>> _map;

  @override
  Future<List<Map<String, dynamic>>> loadList(String assetPath) async {
    return _map[assetPath] ?? [];
  }
}

class FakeHistoryStore extends ContentHistoryStore {
  final Map<String, String> _store = {};

  @override
  Future<List<String>> readAffirmationIds() async =>
      _store['aff'] == null ? [] : [_store['aff']!];

  @override
  Future<List<String>> readMicroTaskIds() async =>
      _store['task'] == null ? [] : [_store['task']!];

  @override
  Future<List<String>> readMindfulnessIds() async =>
      _store['guide'] == null ? [] : [_store['guide']!];

  @override
  Future<void> writeAffirmationId(String id) async => _store['aff'] = id;

  @override
  Future<void> writeMicroTaskId(String id) async => _store['task'] = id;

  @override
  Future<void> writeMindfulnessId(String id) async => _store['guide'] = id;
}

void main() {
  test('ContentRepository pickAffirmation returns matching tag', () async {
    final loader = FakeLoader({
      'assets/content/affirmations.json': [
        {'id': 'a1', 'text': 'low', 'tags': ['low'], 'weight': 1},
        {'id': 'a2', 'text': 'high', 'tags': ['hope'], 'weight': 1},
      ],
    });

    final repo = ContentRepository(
      loader: loader,
      historyStore: FakeHistoryStore(),
      random: Random(0),
    );
    final picked = await repo.pickAffirmation(tags: ['hope']);

    expect(picked?.id, 'a2');
  });

  test('ContentRepository pickMicroTask falls back', () async {
    final loader = FakeLoader({
      'assets/content/micro_tasks.json': [
        {'id': 't1', 'title': 't', 'description': 'd', 'tags': ['x'], 'weight': 1},
      ],
    });

    final repo = ContentRepository(
      loader: loader,
      historyStore: FakeHistoryStore(),
      random: Random(0),
    );
    final picked = await repo.pickMicroTask(tags: ['missing']);

    expect(picked?.id, 't1');
  });

  test('ContentRepository pickMindfulnessGuide returns null on empty', () async {
    final loader = FakeLoader({
      'assets/content/mindfulness_guides.json': [],
    });

    final repo = ContentRepository(
      loader: loader,
      historyStore: FakeHistoryStore(),
      random: Random(0),
    );
    final picked = await repo.pickMindfulnessGuide(tags: ['calm']);

    expect(picked, isNull);
  });
}
