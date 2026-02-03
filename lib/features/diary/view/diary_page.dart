import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/diary_viewmodel.dart';
import '../../../data/models/diary_entry.dart';

class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  final TextEditingController _contentController = TextEditingController();
  String _moodTag = 'calm';
  String _template = 'gratitude';

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(diaryViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('情緒日記')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('心情選擇', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _moodTag,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'calm', child: Text('平靜')),
              DropdownMenuItem(value: 'sad', child: Text('低落')),
              DropdownMenuItem(value: 'anxious', child: Text('焦慮')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _moodTag = value;
              });
            },
          ),
          const SizedBox(height: 12),
          const Text('日記模板', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _template,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'gratitude', child: Text('感謝')),
              DropdownMenuItem(value: 'release', child: Text('放下')),
              DropdownMenuItem(value: 'hope', child: Text('希望')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _template = value;
              });
            },
          ),
          const SizedBox(height: 12),
          const Text('日記內容', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: '你願意寫下現在的感覺嗎？',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final now = DateTime.now();
              final entry = DiaryEntry(
                id: 'diary_${now.millisecondsSinceEpoch}',
                date: now,
                moodTag: _moodTag,
                template: _template,
                content: _contentController.text.trim(),
              );
              await vm.addEntry(entry);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('日記已保存')),
              );
            },
            child: const Text('保存日記'),
          ),
        ],
      ),
    );
  }
}
