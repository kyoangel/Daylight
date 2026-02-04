import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/diary_viewmodel.dart';
import '../../../data/models/diary_entry.dart';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/mindfulness_guide.dart';
import '../../../features/profile/viewmodel/profile_viewmodel.dart';
import '../../../common/app_locale.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';

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

  String _buildWeeklySummary(Map<String, int> counts, AppStrings strings, String toneStyle) {
    if (counts.isEmpty) return '';
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final base = strings.weeklyMoodSummary(strings.moodLabel(top.key), top.value);
    final closing = strings.weeklyClosingLine(toneStyle);
    return '$base $closing';
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(diaryViewModelProvider.notifier);
    final entries = ref.watch(diaryViewModelProvider);
    final moodCounts = _buildMoodCounts(entries);
    final profile = ref.watch(userProfileViewModelProvider);
    final locale = normalizeLocale(profile.language);
    final strings = AppStrings.of(ref.watch(localeProvider));
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _contentRepository = ContentRepository(locale: locale);
      _loadGuide();
    }
    final summary = _buildWeeklySummary(moodCounts, strings, profile.toneStyle);

    return Scaffold(
      appBar: AppBar(title: Text(strings.diaryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(strings.weeklyDistribution, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (moodCounts.isEmpty)
            Text(strings.noRecords)
          else
            MoodBarChart(counts: moodCounts, labelForMood: strings.moodLabel),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(summary, style: const TextStyle(color: Colors.black54)),
          ],
          const SizedBox(height: 16),
          Text(strings.moodSelect, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _moodTag,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: 'calm', child: Text(strings.moodLabel('calm'))),
              DropdownMenuItem(value: 'sad', child: Text(strings.moodLabel('sad'))),
              DropdownMenuItem(value: 'anxious', child: Text(strings.moodLabel('anxious'))),
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
          Text(strings.diaryTemplate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _template,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: 'gratitude', child: Text(strings.templateLabel('gratitude'))),
              DropdownMenuItem(value: 'release', child: Text(strings.templateLabel('release'))),
              DropdownMenuItem(value: 'hope', child: Text(strings.templateLabel('hope'))),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _template = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Text(strings.mindfulness, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    Text(strings.mindfulnessDuration(_guide!.duration)),
                    const SizedBox(height: 6),
                    ..._guide!.steps.map((step) => Text('- $step')),
                  ],
                ),
              ),
            )
          else
            Text(strings.noGuide),
          const SizedBox(height: 12),
          Text(strings.diaryContent, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: strings.diaryHint,
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
                SnackBar(content: Text(strings.diarySaved)),
              );
            },
            child: Text(strings.saveDiary),
          ),
        ],
      ),
    );
  }
}

class MoodBarChart extends StatelessWidget {
  const MoodBarChart({super.key, required this.counts, required this.labelForMood});

  final Map<String, int> counts;
  final String Function(String) labelForMood;

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
              SizedBox(width: 60, child: Text(labelForMood(entry.key))),
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
