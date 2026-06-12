import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences.setMockInitialValues({});
    final loader = FakeLoader({
      'assets/content/zh-TW/affirmations.json': [
        {'id': 'a1', 'text': 'hello', 'tags': ['t1'], 'weight': 1}
      ],
      'assets/content/zh-TW/micro_tasks.json': [
        {'id': 't1', 'title': 'title', 'description': 'desc', 'tags': ['x'], 'weight': 1}
      ],
      'assets/content/zh-TW/mindfulness_guides.json': [
        {
          'id': 'm1',
          'title': 'title',
          'duration': '1 min',
          'steps': ['s1'],
          'tags': ['y'],
          'weight': 1
        }
      ],
      'assets/content/zh-TW/welcome_messages.json': [
        {'id': 'w1', 'greeting': 'hi', 'direction': 'step', 'tags': ['z'], 'weight': 1}
      ],
      'assets/content/zh-TW/emotion_labels.json': [],
      'assets/content/zh-TW/validations.json': [],
      'assets/content/zh-TW/reflective_prompts.json': [],
    });

    final repo = ContentRepository(loader: loader);

    final affirmations = await repo.loadAffirmations();
    final tasks = await repo.loadMicroTasks();
    final guides = await repo.loadMindfulnessGuides();
    final welcomes = await repo.loadWelcomeMessages();

    expect(affirmations.first.id, 'a1');
    expect(tasks.first.id, 't1');
    expect(guides.first.id, 'm1');
    expect(welcomes.first.id, 'w1');
  });

  test('ContentRepository loads emotion labels', () async {
    SharedPreferences.setMockInitialValues({});
    final loader = FakeLoader({
      'assets/content/zh-TW/emotion_labels.json': [
        {'id': 'em_anxious', 'label': '焦慮', 'tags': ['anxious'], 'colorHex': '#FFB347', 'weight': 1}
      ],
    });
    final repo = ContentRepository(loader: loader);
    final labels = await repo.loadEmotionLabels();
    expect(labels.length, 1);
    expect(labels.first.id, 'em_anxious');
  });

  test('ContentRepository pickValidation returns item matching tags', () async {
    SharedPreferences.setMockInitialValues({});
    final loader = FakeLoader({
      'assets/content/zh-TW/validations.json': [
        {'id': 'val_001', 'text': '焦慮很耗人', 'tags': ['anxious'], 'weight': 2},
        {'id': 'val_002', 'text': '還好很正常', 'tags': ['okay'],    'weight': 1},
      ],
    });
    final repo = ContentRepository(loader: loader);
    final picked = await repo.pickValidation(tags: ['anxious']);
    expect(picked, isNotNull);
    expect(picked!.id, 'val_001');
  });

  test('ContentRepository pickValidation falls back when no tag match', () async {
    SharedPreferences.setMockInitialValues({});
    final loader = FakeLoader({
      'assets/content/zh-TW/validations.json': [
        {'id': 'val_001', 'text': '一般驗證語', 'tags': [], 'weight': 1},
      ],
    });
    final repo = ContentRepository(loader: loader);
    final picked = await repo.pickValidation(tags: ['nonexistent']);
    expect(picked, isNotNull);
  });

  test('ContentRepository pickReflectivePrompt returns item matching tags', () async {
    SharedPreferences.setMockInitialValues({});
    final loader = FakeLoader({
      'assets/content/zh-TW/reflective_prompts.json': [
        {'id': 'rp_001', 'text': '你的好朋友問句', 'tags': ['sad'], 'weight': 2},
        {'id': 'rp_002', 'text': '通用問句',       'tags': [],      'weight': 1},
      ],
    });
    final repo = ContentRepository(loader: loader);
    final picked = await repo.pickReflectivePrompt(tags: ['sad']);
    expect(picked, isNotNull);
    expect(picked!.id, 'rp_001');
  });
}
