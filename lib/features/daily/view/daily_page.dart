import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/daily_viewmodel.dart';
import '../../../data/models/daily_entry.dart';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/affirmation.dart';
import '../../../data/content/models/micro_task.dart';
import '../../../features/profile/viewmodel/profile_viewmodel.dart';
import '../../../common/app_locale.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';
import '../service/welcome_service.dart';
import '../../../data/content/models/welcome_message.dart';

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
  WelcomeMessage? _welcomeMessage;
  bool _loadingContent = true;
  bool _loadingWelcome = true;
  bool _pendingReload = false;
  final WelcomeService _welcomeService = WelcomeService();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileViewModelProvider);
    _currentLocale = normalizeLocale(profile.language);
    _contentRepository = ContentRepository(locale: _currentLocale);
    _loadContent();
    _loadWelcome(locale: _currentLocale);
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

  Future<void> _loadWelcome({required String locale}) async {
    setState(() {
      _loadingWelcome = true;
    });
    final message = await _welcomeService.getTodayMessage(locale: locale);
    if (!mounted) return;
    setState(() {
      _welcomeMessage = message;
      _loadingWelcome = false;
    });
  }

  String _personalize(String template, String nickname, String locale) {
    if (nickname.isEmpty) {
      return template.replaceAll('{name}', '');
    }
    final insert = locale == 'en' ? ' $nickname' : nickname;
    return template.replaceAll('{name}', insert);
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

  bool _shouldShowSoftIntervention(List<DailyEntry> entries, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final recent = entries.where((entry) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      final diff = today.difference(day).inDays;
      return diff >= 0 && diff <= 2;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (recent.length < 2) return false;

    final avg = recent.map((e) => e.moodScore).reduce((a, b) => a + b) / recent.length;
    if (avg <= 4) return true;

    var consecutive = 0;
    for (final entry in recent) {
      if (entry.moodScore <= 3) {
        consecutive += 1;
        if (consecutive >= 2) return true;
      } else {
        consecutive = 0;
      }
    }
    return false;
  }

  String _buildWeeklySummary(List<DailyEntry> entries, AppStrings strings) {
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
    return strings.weeklySummary(avg, max, min);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(dailyViewModelProvider.notifier);
    final entries = ref.watch(dailyViewModelProvider);
    final trend = _buildWeeklyTrend(entries);
    final profile = ref.watch(userProfileViewModelProvider);
    final locale = normalizeLocale(profile.language);
    final strings = AppStrings.of(ref.watch(localeProvider));
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _contentRepository = ContentRepository(locale: locale);
      _pendingReload = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pendingReload) return;
        _loadContent();
        _loadWelcome(locale: locale);
      });
    }

    final summary = _buildWeeklySummary(entries, strings);
    final nickname = profile.nickname.trim();
    final toneStyle = profile.toneStyle;
    final greeting = _welcomeMessage == null
        ? strings.welcomeFallbackGreeting
        : _personalize(_welcomeMessage!.greeting, nickname, locale);
    final direction = _welcomeMessage == null
        ? strings.welcomeFallbackDirection
        : _personalize(_welcomeMessage!.direction, nickname, locale);
    final tonedGreeting = strings.applyToneToGreeting(greeting, toneStyle);
    final tonedDirection = strings.applyToneToDirection(direction, toneStyle);
    final showSoftIntervention = _shouldShowSoftIntervention(entries, DateTime.now());
    final softSuggestions = strings.softInterventionSuggestions(toneStyle);

    return Scaffold(
      appBar: AppBar(title: Text(strings.dailyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: Colors.teal.withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _loadingWelcome
                  ? const LinearProgressIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tonedGreeting, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(tonedDirection, style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (showSoftIntervention) ...[
            Card(
              elevation: 0,
              color: Colors.orange.withOpacity(0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.softInterventionTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(strings.softInterventionBody, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),
                    ...softSuggestions.map((text) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: Colors.black54)),
                              Expanded(child: Text(text)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(strings.weeklyTrend, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (trend.isEmpty)
            Text(strings.noRecords)
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
          Text(strings.todayMood, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          Text(strings.todayTask, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Text(strings.noTask),
          const SizedBox(height: 12),
          Text(strings.todayAffirmation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_loadingContent)
            const LinearProgressIndicator()
          else if (_affirmation != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(strings.applyToneToAffirmation(_affirmation!.text, toneStyle)),
              ),
            )
          else
            Text(strings.noAffirmation),
          const SizedBox(height: 12),
          Text(strings.nightReflection, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _reflectionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: strings.reflectionHint,
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
                SnackBar(content: Text(strings.savedToday)),
              );
            },
            child: Text(strings.saveToday),
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
