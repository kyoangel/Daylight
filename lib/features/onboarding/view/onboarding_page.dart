import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/onboarding_viewmodel.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _controller = PageController();
  final TextEditingController _nicknameController = TextEditingController();

  String _language = 'zh-TW';
  final List<String> _reminderTimes = [];
  final List<String> _preferredModes = [];
  final List<String> _triggers = [];
  double _moodBaseline = 5;

  @override
  void dispose() {
    _controller.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final vm = ref.read(onboardingViewModelProvider.notifier);
    await vm.updateProfile(
      nickname: _nicknameController.text.trim(),
      language: _language,
      reminderTimes: _reminderTimes,
      preferredModes: _preferredModes,
      triggers: _triggers,
      moodBaseline: _moodBaseline.round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(onboardingViewModelProvider.notifier);
    final locale = ref.watch(localeProvider);
    final strings = AppStrings.of(locale);

    return Scaffold(
      appBar: AppBar(title: Text(strings.onboardingWelcome)),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          vm.setStep(index);
        },
        children: [
          _buildWelcomePage(strings),
          _buildBasicPage(strings),
          _buildPreferencePage(strings),
          _buildSafetyPage(strings),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(AppStrings strings) {
    return _pageShell(
      title: strings.appTitle,
      body: Text(strings.onboardingWelcomeBody),
      primaryLabel: strings.onboardingStart,
      onPrimary: () async {
        await _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
    );
  }

  Widget _buildBasicPage(AppStrings strings) {
    return _pageShell(
      title: strings.onboardingBasic,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nicknameController,
            decoration: InputDecoration(labelText: strings.nicknameLabel),
          ),
          const SizedBox(height: 12),
          Text(strings.languageLabel),
          DropdownButton<String>(
            value: _language,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: 'zh-TW', child: Text(strings.languageOptionLabel('zh-TW'))),
              DropdownMenuItem(value: 'en', child: Text(strings.languageOptionLabel('en'))),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _language = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Text(strings.reminderTimesLabel),
          Wrap(
            spacing: 8,
            children: ['08:00', '12:00', '21:00'].map((time) {
              final selected = _reminderTimes.contains(time);
              return FilterChip(
                label: Text(time),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _reminderTimes.add(time);
                    } else {
                      _reminderTimes.remove(time);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      primaryLabel: strings.onboardingNext,
      onPrimary: () async {
        await _saveProfile();
        await _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
      secondaryLabel: strings.onboardingBack,
      onSecondary: () async {
        await _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
    );
  }

  Widget _buildPreferencePage(AppStrings strings) {
    return _pageShell(
      title: strings.onboardingPreferences,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.preferredInteractionLabel),
          Wrap(
            spacing: 8,
            children: ['text', 'voice', 'task'].map((mode) {
              final selected = _preferredModes.contains(mode);
              return FilterChip(
                label: Text(strings.preferredModeLabel(mode)),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _preferredModes.add(mode);
                    } else {
                      _preferredModes.remove(mode);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(strings.triggersLabel),
          Wrap(
            spacing: 8,
            children: ['lonely', 'stress', 'body'].map((trigger) {
              final selected = _triggers.contains(trigger);
              return FilterChip(
                label: Text(strings.triggerLabel(trigger)),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _triggers.add(trigger);
                    } else {
                      _triggers.remove(trigger);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(strings.moodBaselineLabel),
          Slider(
            value: _moodBaseline,
            min: 0,
            max: 10,
            divisions: 10,
            label: _moodBaseline.toStringAsFixed(0),
            onChanged: (value) {
              setState(() {
                _moodBaseline = value;
              });
            },
          ),
        ],
      ),
      primaryLabel: strings.onboardingNext,
      onPrimary: () async {
        await _saveProfile();
        await _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
      secondaryLabel: strings.onboardingBack,
      onSecondary: () async {
        await _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
    );
  }

  Widget _buildSafetyPage(AppStrings strings) {
    return _pageShell(
      title: strings.onboardingSafety,
      body: Text(strings.safetyHint),
      primaryLabel: strings.onboardingEnter,
      onPrimary: () async {
        final vm = ref.read(onboardingViewModelProvider.notifier);
        await vm.markCompleted();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/daily');
      },
      secondaryLabel: strings.onboardingBack,
      onSecondary: () async {
        await _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
    );
  }

  Widget _pageShell({
    required String title,
    required Widget body,
    required String primaryLabel,
    required VoidCallback onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(child: SingleChildScrollView(child: body)),
          Row(
            children: [
              if (secondaryLabel != null && onSecondary != null)
                OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel)),
              const Spacer(),
              ElevatedButton(onPressed: onPrimary, child: Text(primaryLabel)),
            ],
          ),
        ],
      ),
    );
  }
}
