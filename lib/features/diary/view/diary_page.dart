import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  ContentRepository _contentRepository = ContentRepository(locale: 'zh-TW');
  String _currentLocale = 'zh-TW';
  MindfulnessGuide? _guide;
  bool _loadingGuide = true;

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

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileViewModelProvider);
    final locale = normalizeLocale(profile.language);
    final strings = AppStrings.of(ref.watch(localeProvider));
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _contentRepository = ContentRepository(locale: locale);
      _loadGuide();
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.mindfulness)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.audioMissing)),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: Text(strings.playAudio),
          ),
        ],
      ),
    );
  }
}
