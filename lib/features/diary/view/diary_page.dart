import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/diary_viewmodel.dart';
import '../../../data/models/diary_entry.dart';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/mindfulness_guide.dart';
import '../../../features/profile/viewmodel/profile_viewmodel.dart';
import '../../../common/app_locale.dart';

class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  final TextEditingController _contentController = TextEditingController();
  String _moodTag = 'calm';
  String _template = 'gratitude';
  ContentRepository _contentRepository = ContentRepository(locale: 'zh-TW');
  String _currentLocale = 'zh-TW';
  MindfulnessGuide? _guide;
  bool _loadingGuide = true;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadGuide();
  }

  Future<void> _loadGuide() async {
    final guides = await _contentRepository.loadMindfulnessGuides();
    if (!mounted) return;
    setState(() {
      _guide = guides.isNotEmpty ? guides.first : null;
      _loadingGuide = false;
    });
  }

  Future<void> _refreshGuideByMood() async {
    setState(() {
      _loadingGuide = true;
    });
    final picked = await _contentRepository.pickMindfulnessGuide(tags: [_moodTag]);
    if (!mounted) return;
    setState(() {
      _guide = picked;
      _loadingGuide = false;
    });
  }

  Map<String, int> _buildMoodCounts(List<DiaryEntry> entries) {
    if (entries.isEmpty) return {};
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
    final counts = <String, int>{};
    for (final entry in entries) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (day.isBefore(start)) continue;
      counts.update(entry.moodTag, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  String _buildWeeklySummary(Map<String, int> counts) {
    if (counts.isEmpty) return '';
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return '本週最常出現的心情是「${_labelForMood(top.key)}」（${top.value} 次）。';
  }

  String _labelForMood(String tag) {
    switch (tag) {
      case 'calm':
        return '平靜';
      case 'sad':
        return '低落';
      case 'anxious':
        return '焦慮';
      default:
        return tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(diaryViewModelProvider.notifier);
    final entries = ref.watch(diaryViewModelProvider);
    final moodCounts = _buildMoodCounts(entries);
    final summary = _buildWeeklySummary(moodCounts);
    final profile = ref.watch(userProfileViewModelProvider);
    final locale = normalizeLocale(profile.language);
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _contentRepository = ContentRepository(locale: locale);
      _loadGuide();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('情緒日記')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('本週心情分佈', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (moodCounts.isEmpty)
            const Text('尚無紀錄')
          else
            MoodBarChart(counts: moodCounts),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(summary, style: const TextStyle(color: Colors.black54)),
          ],
          const SizedBox(height: 16),
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
              _refreshGuideByMood();
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
          const Text('正念引導', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_loadingGuide)
            const LinearProgressIndicator()
          else if (_guide != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_guide!.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('時長：${_guide!.duration}'),
                    const SizedBox(height: 6),
                    ..._guide!.steps.map((step) => Text('- $step')),
                  ],
                ),
              ),
            )
          else
            const Text('尚無引導內容'),
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

class MoodBarChart extends StatelessWidget {
  const MoodBarChart({super.key, required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final maxValue = counts.values.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b);
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((entry) {
        final ratio = entry.value / maxValue;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 60, child: Text(entry.key)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio.clamp(0.05, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.value.toString()),
            ],
          ),
        );
      }).toList(),
    );
  }
}
