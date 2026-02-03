import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/daily_viewmodel.dart';
import '../../../data/models/daily_entry.dart';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/affirmation.dart';
import '../../../data/content/models/micro_task.dart';

class DailyPage extends ConsumerStatefulWidget {
  const DailyPage({super.key});

  @override
  ConsumerState<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends ConsumerState<DailyPage> {
  double _moodScore = 5;
  final TextEditingController _reflectionController = TextEditingController();
  final ContentRepository _contentRepository = ContentRepository();
  Affirmation? _affirmation;
  MicroTask? _microTask;
  bool _loadingContent = true;

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final affirmations = await _contentRepository.loadAffirmations();
    final tasks = await _contentRepository.loadMicroTasks();
    if (!mounted) return;
    setState(() {
      _affirmation = affirmations.isNotEmpty ? affirmations.first : null;
      _microTask = tasks.isNotEmpty ? tasks.first : null;
      _loadingContent = false;
    });
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
          const Text('今日小任務', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_loadingContent)
            const LinearProgressIndicator()
          else if (_microTask != null)
            Card(
              child: ListTile(
                title: Text(_microTask!.title),
                subtitle: Text(_microTask!.description),
              ),
            )
          else
            const Text('尚無任務內容'),
          const SizedBox(height: 12),
          const Text('今日肯定語', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_loadingContent)
            const LinearProgressIndicator()
          else if (_affirmation != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_affirmation!.text),
              ),
            )
          else
            const Text('尚無肯定語'),
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
                microTaskId: _microTask?.id ?? 'default',
                microTaskDone: _microTask != null,
                affirmationId: _affirmation?.id ?? 'default',
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
