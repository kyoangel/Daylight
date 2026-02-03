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
  Future<String?> readAffirmationId() async => _store['aff'];

  @override
  Future<String?> readMicroTaskId() async => _store['task'];

  @override
  Future<String?> readMindfulnessId() async => _store['guide'];

  @override
  Future<void> writeAffirmationId(String id) async => _store['aff'] = id;

  @override
  Future<void> writeMicroTaskId(String id) async => _store['task'] = id;

  @override
  Future<void> writeMindfulnessId(String id) async => _store['guide'] = id;
}

void main() {
  test('pickAffirmation avoids last id when possible', () async {
    final loader = FakeLoader({
      'assets/content/affirmations.json': [
        {'id': 'a1', 'text': 'one', 'tags': ['calm']},
        {'id': 'a2', 'text': 'two', 'tags': ['calm']},
      ],
    });
    final history = FakeHistoryStore()..writeAffirmationId('a1');
    final repo = ContentRepository(
      loader: loader,
      historyStore: history,
      random: Random(0),
    );

    final picked = await repo.pickAffirmation(tags: ['calm']);
    expect(picked?.id, isNot('a1'));
  });

  test('pickMicroTask falls back when only last exists', () async {
    final loader = FakeLoader({
      'assets/content/micro_tasks.json': [
        {'id': 't1', 'title': 't', 'description': 'd', 'tags': ['x']},
      ],
    });
    final history = FakeHistoryStore()..writeMicroTaskId('t1');
    final repo = ContentRepository(
      loader: loader,
      historyStore: history,
      random: Random(0),
    );

    final picked = await repo.pickMicroTask(tags: ['x']);
    expect(picked?.id, 't1');
  });
}
