import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/data/content/models/affirmation.dart';
import 'package:daylight/data/content/models/micro_task.dart';
import 'package:daylight/data/content/models/mindfulness_guide.dart';
import 'package:daylight/data/content/models/welcome_message.dart';

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
}
