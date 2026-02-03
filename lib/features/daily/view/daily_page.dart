import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/daily_viewmodel.dart';
import '../../../data/models/daily_entry.dart';

class DailyPage extends ConsumerStatefulWidget {
  const DailyPage({super.key});

  @override
  ConsumerState<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends ConsumerState<DailyPage> {
  double _moodScore = 5;
  final TextEditingController _reflectionController = TextEditingController();

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(dailyViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('日常節奏')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('今日心情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Slider(
            value: _moodScore,
            min: 0,
            max: 10,
            divisions: 10,
            label: _moodScore.toStringAsFixed(0),
            onChanged: (value) {
              setState(() {
                _moodScore = value;
              });
            },
          ),
          const SizedBox(height: 12),
          const Text('晚安反思', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _reflectionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '今天哪一刻你覺得稍微輕鬆？',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final entry = DailyEntry(
                date: DateTime.now(),
                moodScore: _moodScore.round(),
                microTaskId: 'default',
                microTaskDone: true,
                affirmationId: 'default',
                nightReflection: _reflectionController.text.trim(),
              );
              await vm.upsertEntry(entry);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('今日已保存')),
              );
            },
            child: const Text('保存今日'),
          ),
        ],
      ),
    );
  }
}
