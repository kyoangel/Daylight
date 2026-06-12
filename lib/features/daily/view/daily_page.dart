import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/daily_viewmodel.dart';
import '../../../data/models/daily_entry.dart';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/emotion_label.dart';
import '../../../data/content/models/validation_message.dart';
import '../../../data/content/models/reflective_prompt.dart';
import '../../../data/content/models/micro_task.dart';
import '../../../data/content/models/welcome_message.dart';
import '../../../features/profile/viewmodel/profile_viewmodel.dart';
import '../../../common/app_locale.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';
import '../service/welcome_service.dart';
import '../../../data/content/holiday_calendar.dart';
import '../../../features/history/view/history_page.dart';

class DailyPage extends ConsumerStatefulWidget {
  const DailyPage({super.key});

  @override
  ConsumerState<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends ConsumerState<DailyPage> {
  ContentRepository _contentRepository = ContentRepository(locale: 'zh-TW');
  String _currentLocale = 'zh-TW';
  WelcomeMessage? _welcomeMessage;
  bool _loadingWelcome = true;
  bool _pendingReload = false;
  final WelcomeService _welcomeService = WelcomeService();
  final TextEditingController _eventController = TextEditingController();

  List<EmotionLabel> _emotionLabels = [];
  bool _loadingEmotionLabels = true;

  Set<String> _selectedEmotionIds = {};
  int _emotionIntensity = 3;
  bool _prefillDone = false;

  ValidationMessage? _validation;
  ReflectivePrompt? _reflectivePrompt;
  MicroTask? _microTask;
  bool _loadingCompanion = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileViewModelProvider);
    _currentLocale = normalizeLocale(profile.language);
    _contentRepository = ContentRepository(locale: _currentLocale);
    _loadEmotionLabels();
    _loadWelcome(locale: _currentLocale);
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  Future<void> _loadEmotionLabels() async {
    setState(() => _loadingEmotionLabels = true);
    try {
      final labels = await _contentRepository.loadEmotionLabels();
      if (!mounted) return;
      setState(() {
        _emotionLabels = labels;
        _loadingEmotionLabels = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingEmotionLabels = false);
    }
  }

  Future<void> _loadWelcome({required String locale}) async {
    setState(() => _loadingWelcome = true);
    try {
      final message = await _welcomeService.getTodayMessage(locale: locale);
      if (!mounted) return;
      setState(() {
        _welcomeMessage = message;
        _loadingWelcome = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingWelcome = false);
    }
  }

  Future<void> _updateCompanionResponse() async {
    setState(() => _loadingCompanion = true);
    try {
      final tags = _selectedEmotionIds
          .expand((id) => _emotionLabels.where((l) => l.id == id).expand((l) => l.tags))
          .toList();
      final results = await Future.wait([
        _contentRepository.pickValidation(tags: tags.isNotEmpty ? tags : null),
        _contentRepository.pickReflectivePrompt(tags: tags.isNotEmpty ? tags : null),
        _contentRepository.pickMicroTask(tags: tags.isNotEmpty ? tags : null),
      ]);
      if (!mounted) return;
      setState(() {
        _validation = results[0] as ValidationMessage?;
        _reflectivePrompt = results[1] as ReflectivePrompt?;
        _microTask = results[2] as MicroTask?;
        _loadingCompanion = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCompanion = false);
    }
  }

  Future<void> _saveEntry({required AppStrings strings, required DailyViewModel vm}) async {
    final now = DateTime.now();
    final emotionLabels = _selectedEmotionIds.toList();
    final eventNote = _eventController.text.trim().isEmpty ? null : _eventController.text.trim();
    final draft = DailyEntry(
      date: DateTime(now.year, now.month, now.day),
      moodScore: 5,
      microTaskId: _microTask?.id ?? '',
      microTaskDone: false,
      affirmationId: '',
      nightReflection: '',
      emotionLabels: emotionLabels,
      emotionIntensity: _emotionIntensity,
      eventNote: eventNote,
    );
    await vm.upsertEntry(DailyEntry(
      date: draft.date,
      moodScore: draft.derivedMoodScore,
      microTaskId: draft.microTaskId,
      microTaskDone: draft.microTaskDone,
      affirmationId: draft.affirmationId,
      nightReflection: draft.nightReflection,
      emotionLabels: draft.emotionLabels,
      emotionIntensity: draft.emotionIntensity,
      eventNote: draft.eventNote,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.savedToday)),
    );
  }

  String _personalize(String template, String nickname, String locale) {
    if (nickname.isEmpty) return template.replaceAll('{name}', '');
    final insert = locale == 'en' ? ' $nickname' : nickname;
    return template.replaceAll('{name}', insert);
  }

  DailyEntry? _findTodayEntry(List<DailyEntry> entries) {
    final now = DateTime.now();
    for (final e in entries) {
      if (e.date.year == now.year && e.date.month == now.month && e.date.day == now.day) {
        return e;
      }
    }
    return null;
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

    // New: check emotion labels
    const negativeIds = {
      'em_anxious', 'em_tired', 'em_lonely', 'em_irritable', 'em_sad',
    };
    final recentWithLabels = recent.where((e) => e.emotionLabels.isNotEmpty).toList();
    if (recentWithLabels.length >= 2) {
      final consecutiveNegative = recentWithLabels
          .take(2)
          .every((e) => e.emotionLabels.any(negativeIds.contains));
      if (consecutiveNegative) return true;
    }

    // Fallback: legacy moodScore logic
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

  Color _chipColor(EmotionLabel label) {
    try {
      final hex = label.colorHex.replaceFirst('#', '');
      final value = int.parse('FF$hex', radix: 16);
      return Color(value).withOpacity(0.18);
    } catch (_) {
      return Colors.grey.withOpacity(0.15);
    }
  }

  Color _chipBorderColor(EmotionLabel label) {
    try {
      final hex = label.colorHex.replaceFirst('#', '');
      final value = int.parse('FF$hex', radix: 16);
      return Color(value);
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(dailyViewModelProvider.notifier);
    final entries = ref.watch(dailyViewModelProvider);
    final profile = ref.watch(userProfileViewModelProvider);
    final locale = normalizeLocale(profile.language);
    final strings = AppStrings.of(ref.watch(localeProvider));

    // Pre-fill form from today's entry (once, as soon as entries are available)
    if (!_prefillDone) {
      final todayEntry = _findTodayEntry(entries);
      if (todayEntry != null) {
        _prefillDone = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _selectedEmotionIds = todayEntry.emotionLabels.isNotEmpty
                ? {todayEntry.emotionLabels.first}
                : {};
            _emotionIntensity = todayEntry.emotionIntensity ?? 3;
            _eventController.text = todayEntry.eventNote ?? '';
          });
        });
      }
    }

    final hasTodayEntry = entries.any((e) {
      final now = DateTime.now();
      return e.date.year == now.year && e.date.month == now.month && e.date.day == now.day;
    });

    if (_currentLocale != locale) {
      _currentLocale = locale;
      _contentRepository = ContentRepository(locale: locale);
      _pendingReload = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pendingReload) return;
        _loadEmotionLabels();
        _loadWelcome(locale: locale);
      });
    }

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
    const _positiveIds = {
      'em_happy', 'em_grateful', 'em_fulfilled', 'em_excited', 'em_blissful',
      'em_calm', 'em_okay',
    };
    final hasPositiveSelected = _selectedEmotionIds.isNotEmpty &&
        _selectedEmotionIds.any(_positiveIds.contains);
    final showSoftIntervention =
        !hasPositiveSelected && _shouldShowSoftIntervention(entries, DateTime.now());
    final softSuggestions = strings.softInterventionSuggestions(toneStyle);

    return Scaffold(
      appBar: AppBar(title: Text(strings.dailyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome card
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
                        Text(tonedGreeting,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(tonedDirection, style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Soft intervention
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
                    Text(strings.softInterventionBody,
                        style: const TextStyle(color: Colors.black54)),
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

          // Emotion section
          Text(strings.emotionSectionTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(strings.emotionChipHint,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 10),

          if (_loadingEmotionLabels)
            const LinearProgressIndicator()
          else
            _EmotionChipGrid(
              labels: _emotionLabels,
              selectedIds: _selectedEmotionIds,
              chipColor: _chipColor,
              chipBorderColor: _chipBorderColor,
              onToggle: (id) {
                setState(() {
                  if (_selectedEmotionIds.contains(id)) {
                    _selectedEmotionIds = {};
                  } else {
                    _selectedEmotionIds = {id};
                  }
                });
                if (_selectedEmotionIds.isNotEmpty) {
                  _updateCompanionResponse();
                } else {
                  setState(() {
                    _validation = null;
                    _reflectivePrompt = null;
                    _microTask = null;
                  });
                }
              },
            ),

          const SizedBox(height: 16),

          // Intensity
          Text(strings.intensityLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _IntensityDots(
            value: _emotionIntensity,
            onChanged: (v) => setState(() => _emotionIntensity = v),
          ),
          const SizedBox(height: 16),

          // Event note input
          TextField(
            controller: _eventController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: strings.eventNoteHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          // Companion response card
          _CompanionResponseCard(
            strings: strings,
            isLoading: _loadingCompanion,
            hasSelection: _selectedEmotionIds.isNotEmpty,
            validation: _validation,
            reflectivePrompt: _reflectivePrompt,
            microTask: _microTask,
          ),

          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveEntry(strings: strings, vm: vm),
              child: Text(hasTodayEntry ? strings.updateButtonLabel : strings.saveButtonLabel),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              ),
              child: Text(
                strings.viewHistory,
                style: const TextStyle(color: Colors.black45, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EmotionChipGrid extends StatelessWidget {
  const _EmotionChipGrid({
    required this.labels,
    required this.selectedIds,
    required this.chipColor,
    required this.chipBorderColor,
    required this.onToggle,
  });

  final List<EmotionLabel> labels;
  final Set<String> selectedIds;
  final Color Function(EmotionLabel) chipColor;
  final Color Function(EmotionLabel) chipBorderColor;
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((label) {
        final selected = selectedIds.contains(label.id);
        return GestureDetector(
          onTap: () => onToggle(label.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? chipColor(label) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? chipBorderColor(label) : Colors.grey.shade300,
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(
              label.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? Colors.black87 : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IntensityDots extends StatelessWidget {
  const _IntensityDots({required this.value, required this.onChanged});

  final int value;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final dotValue = i + 1;
        final active = dotValue <= value;
        return GestureDetector(
          onTap: () => onChanged(dotValue),
          child: Container(
            key: Key('intensity_dot_$dotValue'),
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? theme.colorScheme.primary : Colors.grey.shade200,
              border: Border.all(
                color: active ? theme.colorScheme.primary : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                '$dotValue',
                style: TextStyle(
                  fontSize: 12,
                  color: active ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CompanionResponseCard extends StatelessWidget {
  const _CompanionResponseCard({
    required this.strings,
    required this.isLoading,
    required this.hasSelection,
    this.validation,
    this.reflectivePrompt,
    this.microTask,
  });

  final AppStrings strings;
  final bool isLoading;
  final bool hasSelection;
  final ValidationMessage? validation;
  final ReflectivePrompt? reflectivePrompt;
  final MicroTask? microTask;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.indigo.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.companionResponseTitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (isLoading)
              const LinearProgressIndicator()
            else if (!hasSelection)
              Text(strings.noEmotionSelected,
                  style: const TextStyle(color: Colors.black45, fontSize: 13))
            else ...[
              if (validation != null) ...[
                Text(validation!.text,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
                const SizedBox(height: 10),
              ],
              if (reflectivePrompt != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.black45)),
                    Expanded(
                      child: Text(reflectivePrompt!.text,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54, height: 1.4)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (microTask != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16, color: Colors.teal),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          microTask!.title,
                          style: const TextStyle(fontSize: 13, color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
