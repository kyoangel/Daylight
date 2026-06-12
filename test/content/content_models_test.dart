import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/data/content/models/affirmation.dart';
import 'package:daylight/data/content/models/micro_task.dart';
import 'package:daylight/data/content/models/mindfulness_guide.dart';
import 'package:daylight/data/content/models/welcome_message.dart';
import 'package:daylight/data/content/models/emotion_label.dart';
import 'package:daylight/data/content/models/validation_message.dart';
import 'package:daylight/data/content/models/reflective_prompt.dart';

void main() {
  test('Affirmation json roundtrip', () {
    const model = Affirmation(id: 'a1', text: 'text', tags: ['t1'], weight: 2);
    final json = model.toJson();
    final decoded = Affirmation.fromJson(json);

    expect(decoded.id, 'a1');
    expect(decoded.text, 'text');
    expect(decoded.tags, ['t1']);
  });

  test('MicroTask json roundtrip', () {
    const model = MicroTask(
      id: 't1',
      title: 'title',
      description: 'desc',
      tags: ['tag'],
      weight: 2,
    );
    final json = model.toJson();
    final decoded = MicroTask.fromJson(json);

    expect(decoded.id, 't1');
    expect(decoded.title, 'title');
    expect(decoded.description, 'desc');
    expect(decoded.tags, ['tag']);
  });

  test('MindfulnessGuide json roundtrip', () {
    const model = MindfulnessGuide(
      id: 'm1',
      title: 'title',
      duration: '1 min',
      steps: ['step'],
      tags: ['tag'],
      weight: 2,
    );
    final json = model.toJson();
    final decoded = MindfulnessGuide.fromJson(json);

    expect(decoded.id, 'm1');
    expect(decoded.title, 'title');
    expect(decoded.duration, '1 min');
    expect(decoded.steps, ['step']);
    expect(decoded.tags, ['tag']);
  });

  test('WelcomeMessage json roundtrip', () {
    const model = WelcomeMessage(
      id: 'w1',
      greeting: 'hello',
      direction: 'step',
      tags: ['soft'],
      weight: 2,
    );
    final json = {
      'id': model.id,
      'greeting': model.greeting,
      'direction': model.direction,
      'tags': model.tags,
      'weight': model.weight,
    };
    final decoded = WelcomeMessage.fromJson(json);

    expect(decoded.id, 'w1');
    expect(decoded.greeting, 'hello');
    expect(decoded.direction, 'step');
    expect(decoded.tags, ['soft']);
  });

  test('EmotionLabel json roundtrip', () {
    const model = EmotionLabel(
      id: 'em_anxious',
      label: '焦慮',
      tags: ['anxious', 'worried'],
      colorHex: '#FFB347',
      weight: 1,
    );
    final json = model.toJson();
    final decoded = EmotionLabel.fromJson(json);

    expect(decoded.id, 'em_anxious');
    expect(decoded.label, '焦慮');
    expect(decoded.tags, ['anxious', 'worried']);
    expect(decoded.colorHex, '#FFB347');
    expect(decoded.weight, 1);
  });

  test('ValidationMessage json roundtrip', () {
    const model = ValidationMessage(
      id: 'val_001',
      text: '這是驗證語',
      tags: ['anxious'],
      weight: 2,
    );
    final json = model.toJson();
    final decoded = ValidationMessage.fromJson(json);

    expect(decoded.id, 'val_001');
    expect(decoded.text, '這是驗證語');
    expect(decoded.tags, ['anxious']);
    expect(decoded.weight, 2);
  });

  test('ReflectivePrompt json roundtrip', () {
    const model = ReflectivePrompt(
      id: 'rp_001',
      text: '如果你的好朋友也有這樣的感受？',
      tags: ['sad'],
      weight: 2,
    );
    final json = model.toJson();
    final decoded = ReflectivePrompt.fromJson(json);

    expect(decoded.id, 'rp_001');
    expect(decoded.text, '如果你的好朋友也有這樣的感受？');
    expect(decoded.tags, ['sad']);
    expect(decoded.weight, 2);
  });
}
