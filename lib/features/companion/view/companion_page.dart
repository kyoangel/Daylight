import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/companion_session.dart';
import '../../../data/repositories/companion_repository.dart';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/affirmation.dart';
import '../../../features/profile/viewmodel/profile_viewmodel.dart';
import '../../../common/app_locale.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';
import 'walking_cat_pet.dart';

class CompanionPage extends ConsumerStatefulWidget {
  const CompanionPage({super.key});

  @override
  ConsumerState<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends ConsumerState<CompanionPage> {
  final TextEditingController _inputController = TextEditingController();
  String _selectedMode = 'listen';
  List<CompanionSession> _sessions = [];
  ContentRepository _contentRepository = ContentRepository(locale: 'zh-TW');
  String _currentLocale = 'zh-TW';
  Affirmation? _affirmation;
  bool _loadingAffirmation = true;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAffirmation();
    _loadSessions();
  }

  Future<void> _loadAffirmation() async {
    final affirmations = await _contentRepository.loadAffirmations();
    if (!mounted) return;
    setState(() {
      _affirmation = affirmations.isNotEmpty ? affirmations.first : null;
      _loadingAffirmation = false;
    });
  }

  Future<void> _loadSessions() async {
    final repo = CompanionRepository();
    final items = await repo.loadAll();
    if (!mounted) return;
    items.sort((a, b) => b.startAt.compareTo(a.startAt));
    setState(() {
      _sessions = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileViewModelProvider);
    final locale = normalizeLocale(profile.language);
    final strings = AppStrings.of(ref.watch(localeProvider));
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _contentRepository = ContentRepository(locale: locale);
      _loadAffirmation();
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.companionTitle)),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _loadingAffirmation
                    ? const LinearProgressIndicator()
                    : _affirmation != null
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(_affirmation!.text),
                            ),
                          )
                        : Text(strings.noAffirmation),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButton<String>(
                  value: _selectedMode,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'listen', child: Text(strings.companionModeLabel('listen'))),
                    DropdownMenuItem(value: 'calm', child: Text(strings.companionModeLabel('calm'))),
                    DropdownMenuItem(value: 'companion', child: Text(strings.companionModeLabel('companion'))),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedMode = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Text(strings.companionHeader,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (_sessions.isEmpty)
                      Text(strings.companionEmpty)
                    else
                      ..._sessions.take(3).map((session) {
                        final modeLabel = strings.companionModeLabel(session.mode);
                        return Card(
                          child: ListTile(
                            title: Text(modeLabel),
                            subtitle: Text(session.summary),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        decoration: InputDecoration(hintText: strings.companionInputHint),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final repo = CompanionRepository();
                        final now = DateTime.now();
                        final session = CompanionSession(
                          id: 'comp_${now.millisecondsSinceEpoch}',
                          mode: _selectedMode,
                          startAt: now,
                          endAt: now.add(const Duration(minutes: 10)),
                          summary: _inputController.text.trim().isEmpty
                              ? (_affirmation?.text ?? '')
                              : _inputController.text.trim(),
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
          const WalkingCatPet(),
        ],
      ),
    );
  }
}
