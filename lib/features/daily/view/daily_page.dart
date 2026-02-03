import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/daily_viewmodel.dart';
import '../../../data/models/daily_entry.dart';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/affirmation.dart';
import '../../../data/content/models/micro_task.dart';
import '../../../features/profile/viewmodel/profile_viewmodel.dart';
import '../../../common/app_locale.dart';

class DailyPage extends ConsumerStatefulWidget {
  const DailyPage({super.key});

  @override
  ConsumerState<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends ConsumerState<DailyPage> {
  double _moodScore = 5;
  final TextEditingController _reflectionController = TextEditingController();
  ContentRepository _contentRepository = ContentRepository(locale: 'zh-TW');
  String _currentLocale = 'zh-TW';
  Affirmation? _affirmation;
  MicroTask? _microTask;
  bool _loadingContent = true;
  bool _pendingReload = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileViewModelProvider);
    _currentLocale = normalizeLocale(profile.language);
    _contentRepository = ContentRepository(locale: _currentLocale);
    _loadContent();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _loadingContent = true;
    });
    final affirmations = await _contentRepository.loadAffirmations();
    final tasks = await _contentRepository.loadMicroTasks();
    if (!mounted) return;
    setState(() {
      _affirmation = affirmations.isNotEmpty ? affirmations.first : null;
      _microTask = tasks.isNotEmpty ? tasks.first : null;
      _loadingContent = false;
      _pendingReload = false;
    });
  }

  Future<void> _refreshContentByMood() async {
    setState(() {
      _loadingContent = true;
    });
    final tags = _tagsForMood(_moodScore.round());
    final pickedAffirmation = await _contentRepository.pickAffirmation(tags: tags);
    final pickedTask = await _contentRepository.pickMicroTask(tags: tags);
    if (!mounted) return;
    setState(() {
      _affirmation = pickedAffirmation;
      _microTask = pickedTask;
      _loadingContent = false;
    });
  }

  List<String> _tagsForMood(int mood) {
    if (mood <= 3) return ['low', 'calm', 'self-kindness'];
    if (mood <= 6) return ['calm', 'reset'];
    return ['hope', 'gentle', 'refresh'];
  }

  List<double> _buildWeeklyTrend(List<DailyEntry> entries) {
    if (entries.isEmpty) return [];
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
    final byDate = <String, DailyEntry>{};
    for (final entry in entries) {
      final key = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
      byDate[key] = entry;
    }
    final trend = <double>[];
    for (var i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      final value = byDate[key]?.moodScore.toDouble();
      trend.add(value ?? 0);
    }
    return trend;
  }

  String _buildWeeklySummary(List<DailyEntry> entries) {
    if (entries.isEmpty) return '';
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
    final recent = entries.where((entry) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      return !day.isBefore(start);
    }).toList();
    if (recent.isEmpty) return '';
    final scores = recent.map((e) => e.moodScore).toList();
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    final min = scores.reduce((a, b) => a < b ? a : b);
    final max = scores.reduce((a, b) => a > b ? a : b);
    return '本週平均心情 ${avg.toStringAsFixed(1)}，最高 $max，最低 $min。';
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(dailyViewModelProvider.notifier);
    final entries = ref.watch(dailyViewModelProvider);
    final trend = _buildWeeklyTrend(entries);
    final profile = ref.watch(userProfileViewModelProvider);
    final locale = normalizeLocale(profile.language);
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _contentRepository = ContentRepository(locale: locale);
      _pendingReload = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pendingReload) return;
        _loadContent();
      });
    }

    final summary = _buildWeeklySummary(entries);

    return Scaffold(
      appBar: AppBar(title: const Text('日常節奏')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('本週心情趨勢', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (trend.isEmpty)
            const Text('尚無紀錄')
          else
            SizedBox(
              height: 140,
              child: MoodTrendChart(values: trend),
            ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(summary, style: const TextStyle(color: Colors.black54)),
          ],
          const SizedBox(height: 16),
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
              _refreshContentByMood();
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

class MoodTrendChart extends StatelessWidget {
  const MoodTrendChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MoodTrendPainter(values: values),
      child: Container(),
    );
  }
}

class _MoodTrendPainter extends CustomPainter {
  _MoodTrendPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = values.length > 1 ? size.width / (values.length - 1) : size.width;
    for (var i = 0; i < values.length; i++) {
      final x = stepX * i;
      final normalized = (values[i] / 10).clamp(0, 1);
      final y = size.height - (size.height * normalized);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MoodTrendPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
