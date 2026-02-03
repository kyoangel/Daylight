import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/onboarding_viewmodel.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('歡迎')),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          vm.setStep(index);
        },
        children: [
          _buildWelcomePage(),
          _buildBasicPage(),
          _buildPreferencePage(),
          _buildSafetyPage(),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _pageShell(
      title: '一日之光',
      body: const Text('你不是一個人，我們陪你走一小步'),
      primaryLabel: '開始',
      onPrimary: () async {
        await _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
    );
  }

  Widget _buildBasicPage() {
    return _pageShell(
      title: '基本設定',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(labelText: '暱稱'),
          ),
          const SizedBox(height: 12),
          const Text('語言'),
          DropdownButton<String>(
            value: _language,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'zh-TW', child: Text('繁體中文')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _language = value;
              });
            },
          ),
          const SizedBox(height: 12),
          const Text('提醒時段（可多選）'),
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
      primaryLabel: '下一步',
      onPrimary: () async {
        await _saveProfile();
        await _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
      secondaryLabel: '上一步',
      onSecondary: () async {
        await _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
    );
  }

  Widget _buildPreferencePage() {
    return _pageShell(
      title: '情緒偏好',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('互動方式（多選）'),
          Wrap(
            spacing: 8,
            children: ['text', 'voice', 'task'].map((mode) {
              final selected = _preferredModes.contains(mode);
              return FilterChip(
                label: Text(mode),
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
          const Text('觸發源（多選）'),
          Wrap(
            spacing: 8,
            children: ['lonely', 'stress', 'body'].map((trigger) {
              final selected = _triggers.contains(trigger);
              return FilterChip(
                label: Text(trigger),
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
          const Text('心情基準'),
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
      primaryLabel: '下一步',
      onPrimary: () async {
        await _saveProfile();
        await _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
      secondaryLabel: '上一步',
      onSecondary: () async {
        await _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
    );
  }

  Widget _buildSafetyPage() {
    return _pageShell(
      title: '安全提示',
      body: const Text('這不是醫療服務，如有緊急狀況請使用 SOS。'),
      primaryLabel: '進入首頁',
      onPrimary: () async {
        final vm = ref.read(onboardingViewModelProvider.notifier);
        await vm.markCompleted();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/daily');
      },
      secondaryLabel: '上一步',
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
