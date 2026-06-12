import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/companion_session.dart';
import '../../../data/repositories/companion_repository.dart';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/validation_message.dart';
import '../../../features/daily/viewmodel/daily_viewmodel.dart';
import '../../../features/profile/viewmodel/profile_viewmodel.dart';
import '../../../common/app_locale.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';

class CompanionPage extends ConsumerStatefulWidget {
  const CompanionPage({super.key});

  @override
  ConsumerState<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends ConsumerState<CompanionPage> {
  final TextEditingController _inputController = TextEditingController();
  List<CompanionSession> _sessions = [];
  ContentRepository _contentRepository = ContentRepository(locale: 'zh-TW');
  String _currentLocale = 'zh-TW';
  ValidationMessage? _contextValidation;
  bool _loadingContext = true;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadContextValidation(List<String> emotionTags) async {
    setState(() => _loadingContext = true);
    final picked = await _contentRepository.pickValidation(
      tags: emotionTags.isNotEmpty ? emotionTags : null,
    );
    if (!mounted) return;
    setState(() {
      _contextValidation = picked;
      _loadingContext = false;
    });
  }

  Future<void> _loadSessions() async {
    final repo = CompanionRepository();
    final items = await repo.loadAll();
    if (!mounted) return;
    items.sort((a, b) => b.startAt.compareTo(a.startAt));
    setState(() => _sessions = items);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileViewModelProvider);
    final locale = normalizeLocale(profile.language);
    final strings = AppStrings.of(ref.watch(localeProvider));
    final recentEntries = ref.watch(dailyViewModelProvider);

    if (_currentLocale != locale) {
      _currentLocale = locale;
      _contentRepository = ContentRepository(locale: locale);
    }

    // Derive emotion tags from the most recent daily entry
    final latestEntry = recentEntries.isEmpty ? null : recentEntries.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );
    final recentEmotionTags = latestEntry?.emotionLabels
            .expand((id) => _emotionIdToTags(id))
            .toList() ??
        [];

    if (_contextValidation == null && !_loadingContext) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadContextValidation(recentEmotionTags);
      });
    }
    if (_contextValidation == null && _loadingContext && recentEmotionTags.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadContextValidation(recentEmotionTags);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.companionTitle)),
      body: Column(
        children: [
          // Context card: shows validation based on recent emotion entry
          if (latestEntry != null && latestEntry.emotionLabels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                elevation: 0,
                color: Colors.indigo.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.companionContextLabel,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54)),
                      const SizedBox(height: 8),
                      if (_loadingContext)
                        const LinearProgressIndicator()
                      else if (_contextValidation != null)
                        Text(_contextValidation!.text,
                            style: const TextStyle(fontSize: 14, height: 1.5)),
                    ],
                  ),
                ),
              ),
            ),

          // Sessions list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Text(strings.companionHeader,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (_sessions.isEmpty)
                  Text(strings.companionEmpty)
                else
                  ..._sessions.take(3).map((session) {
                    return Card(
                      child: ListTile(
                        title: Text(session.summary),
                        trailing: Text(
                          '${session.startAt.month}/${session.startAt.day}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),

          // Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: strings.companionInputHint,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _inputController.text.trim();
                    if (text.isEmpty) return;
                    final repo = CompanionRepository();
                    final now = DateTime.now();
                    final summary = _contextValidation != null
                        ? '${_contextValidation!.text}\n\n$text'
                        : text;
                    final session = CompanionSession(
                      id: 'comp_${now.millisecondsSinceEpoch}',
                      mode: 'companion',
                      startAt: now,
                      endAt: now.add(const Duration(minutes: 10)),
                      summary: summary,
                    );
                    await repo.add(session);
                    if (!mounted) return;
                    _inputController.clear();
                    await _loadSessions();
                    final response = strings.companionReplyLine(profile.toneStyle);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response)),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Map emotion label IDs to their tags (fallback for when EmotionLabel objects aren't loaded)
  List<String> _emotionIdToTags(String id) {
    const map = <String, List<String>>{
      'em_happy':     ['happy', 'joyful'],
      'em_grateful':  ['grateful', 'thankful'],
      'em_fulfilled': ['fulfilled', 'content'],
      'em_excited':   ['excited', 'energized'],
      'em_blissful':  ['blissful', 'blessed'],
      'em_anxious':   ['anxious', 'worried'],
      'em_tired':     ['tired', 'exhausted'],
      'em_lonely':    ['lonely', 'isolated'],
      'em_irritable': ['irritable', 'frustrated'],
      'em_sad':       ['sad', 'low'],
      // legacy
      'em_calm':      ['calm', 'peaceful'],
      'em_okay':      ['okay', 'neutral'],
    };
    return map[id] ?? [];
  }
}
