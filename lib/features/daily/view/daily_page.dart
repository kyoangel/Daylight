import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/daily_viewmodel.dart';
import '../../../data/models/daily_entry.dart';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/affirmation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../features/profile/viewmodel/profile_viewmodel.dart';
import '../../../common/app_locale.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';
import '../service/welcome_service.dart';
import '../../../data/content/models/welcome_message.dart';
import '../../../data/models/gratitude_entry.dart';
import '../../../data/repositories/gratitude_repository.dart';

class DailyPage extends ConsumerStatefulWidget {
  const DailyPage({super.key});

  @override
  ConsumerState<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends ConsumerState<DailyPage> {
  double _moodScore = 5;
  ContentRepository _contentRepository = ContentRepository(locale: 'zh-TW');
  String _currentLocale = 'zh-TW';
  Affirmation? _affirmation;
  WelcomeMessage? _welcomeMessage;
  bool _loadingContent = true;
  bool _loadingWelcome = true;
  bool _pendingReload = false;
  final WelcomeService _welcomeService = WelcomeService();
  final GratitudeRepository _gratitudeRepository = GratitudeRepository();
  final TextEditingController _gratitudeController = TextEditingController();
  List<GratitudeEntry> _gratitudeEntries = [];
  bool _loadingGratitude = true;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileViewModelProvider);
    _currentLocale = normalizeLocale(profile.language);
    _contentRepository = ContentRepository(locale: _currentLocale);
    _loadContent();
    _loadWelcome(locale: _currentLocale);
    _loadGratitude();
  }

  @override
  void dispose() {
    _gratitudeController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _loadingContent = true;
    });
    final affirmations = await _contentRepository.loadAffirmations();
    if (!mounted) return;
    setState(() {
      _affirmation = affirmations.isNotEmpty ? affirmations.first : null;
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

  Future<void> _loadGratitude() async {
    setState(() {
      _loadingGratitude = true;
    });
    final items = await _gratitudeRepository.loadAll();
    if (!mounted) return;
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _gratitudeEntries = items;
      _loadingGratitude = false;
    });
  }

  Future<void> _saveGratitude(AppStrings strings) async {
    final content = _gratitudeController.text.trim();
    if (content.isEmpty) return;
    final now = DateTime.now();
    final entry = GratitudeEntry(
      id: 'grat_${now.millisecondsSinceEpoch}',
      createdAt: now,
      content: content,
    );
    await _gratitudeRepository.add(entry);
    if (!mounted) return;
    _gratitudeController.clear();
    await _loadGratitude();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.gratitudeSaved)),
    );
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
    if (!mounted) return;
    setState(() {
      _affirmation = pickedAffirmation;
      _loadingContent = false;
    });
  }

  Future<void> _saveQuickEntry({
    required int moodScore,
    required DailyViewModel vm,
    required AppStrings strings,
    required String toneStyle,
  }) async {
    final entry = DailyEntry(
      date: DateTime.now(),
      moodScore: moodScore,
      microTaskId: 'default',
      microTaskDone: false,
      affirmationId: _affirmation?.id ?? 'default',
      nightReflection: '',
    );
    await vm.upsertEntry(entry);
    if (!mounted) return;
    final response = strings.responseSavedLine(toneStyle);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response)),
    );
    final closingBody = strings.nightlyClosingBody(toneStyle);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.nightlyClosingTitle),
          content: Text(closingBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.close),
            ),
          ],
        );
      },
    );
  }

  List<String> _tagsForMood(int mood) {
    if (mood <= 3) return ['low', 'calm', 'self-kindness'];
    if (mood <= 6) return ['calm', 'reset'];
    return ['hope', 'gentle', 'refresh'];
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

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(dailyViewModelProvider.notifier);
    final entries = ref.watch(dailyViewModelProvider);
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
          Text(strings.todayMood, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                key: const Key('mood_low'),
                onTap: () async {
                  setState(() {
                    _moodScore = 3;
                  });
                  await _refreshContentByMood();
                  await _saveQuickEntry(
                    moodScore: 3,
                    vm: vm,
                    strings: strings,
                    toneStyle: toneStyle,
                  );
                },
                child: _MoodIconButton(asset: 'assets/icons/mood_low.svg'),
              ),
              GestureDetector(
                key: const Key('mood_mid'),
                onTap: () async {
                  setState(() {
                    _moodScore = 6;
                  });
                  await _refreshContentByMood();
                  await _saveQuickEntry(
                    moodScore: 6,
                    vm: vm,
                    strings: strings,
                    toneStyle: toneStyle,
                  );
                },
                child: _MoodIconButton(asset: 'assets/icons/mood_mid.svg'),
              ),
              GestureDetector(
                key: const Key('mood_high'),
                onTap: () async {
                  setState(() {
                    _moodScore = 9;
                  });
                  await _refreshContentByMood();
                  await _saveQuickEntry(
                    moodScore: 9,
                    vm: vm,
                    strings: strings,
                    toneStyle: toneStyle,
                  );
                },
                child: _MoodIconButton(asset: 'assets/icons/mood_high.svg'),
              ),
            ],
          ),
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
          const SizedBox(height: 16),
          Text(strings.gratitudeTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _gratitudeController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: strings.gratitudeHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadingGratitude ? null : () => _saveGratitude(strings),
              child: Text(strings.gratitudeSave),
            ),
          ),
          const SizedBox(height: 8),
          if (_loadingGratitude)
            const LinearProgressIndicator()
          else if (_gratitudeEntries.isEmpty)
            Text(strings.gratitudeEmpty)
          else ...[
            ..._gratitudeEntries.take(3).map((entry) {
              final dateLabel = '${entry.createdAt.month}/${entry.createdAt.day}';
              return Card(
                child: ListTile(
                  title: Text(entry.content),
                  trailing: Text(dateLabel, style: const TextStyle(color: Colors.black54)),
                ),
              );
            }),
            if (_gratitudeEntries.length > 3)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  strings.gratitudeAllTitle,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _gratitudeEntries.length,
                                  itemBuilder: (context, index) {
                                    final entry = _gratitudeEntries[index];
                                    final dateLabel = '${entry.createdAt.month}/${entry.createdAt.day}';
                                    return ListTile(
                                      title: Text(entry.content),
                                      trailing: Text(dateLabel,
                                          style: const TextStyle(color: Colors.black54)),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text(strings.gratitudeViewAll),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MoodIconButton extends StatelessWidget {
  const _MoodIconButton({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: SvgPicture.asset(asset),
    );
  }
}
