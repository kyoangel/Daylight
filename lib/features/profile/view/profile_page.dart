import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_model.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController _nicknameController;
  late final FocusNode _nicknameFocusNode;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileViewModelProvider);
    _nicknameController = TextEditingController(text: profile.nickname);
    _nicknameFocusNode = FocusNode();
    _nicknameFocusNode.addListener(_handleNicknameFocusChange);
  }

  @override
  void dispose() {
    _nicknameFocusNode.removeListener(_handleNicknameFocusChange);
    _nicknameFocusNode.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleNicknameFocusChange() {
    if (_nicknameFocusNode.hasFocus) return;
    final vm = ref.read(userProfileViewModelProvider.notifier);
    final current = ref.read(userProfileViewModelProvider).nickname;
    final next = _nicknameController.text.trim();
    if (next.isNotEmpty && next != current) {
      vm.updateNickname(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileViewModelProvider);
    final vm = ref.read(userProfileViewModelProvider.notifier);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final appTheme = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeProvider);
    final strings = AppStrings.of(locale);
    if (_nicknameController.text != profile.nickname &&
        !_nicknameFocusNode.hasFocus) {
      _nicknameController.text = profile.nickname;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(strings.profileTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        backgroundColor: appTheme.color,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // 暱稱編輯
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nicknameController,
                    focusNode: _nicknameFocusNode,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () => _nicknameFocusNode.unfocus(),
                    decoration: InputDecoration(
                      labelText: strings.nicknameLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: appTheme.color.withOpacity(0.08),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 主題色切換
            Align(
              alignment: Alignment.centerLeft,
              child: Text(strings.themeColor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: kAppThemes.map((color) {
                final isSelected = appTheme.hex == color.hex;
                return GestureDetector(
                  onTap: () {
                    themeNotifier.setTheme(color);
                    vm.updateThemeColor(color.hex);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black54, width: 3) : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.black54)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(strings.toneLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: profile.toneStyle,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'gentle', child: Text(strings.toneOptionLabel('gentle'))),
                DropdownMenuItem(value: 'encourage', child: Text(strings.toneOptionLabel('encourage'))),
                DropdownMenuItem(value: 'short', child: Text(strings.toneOptionLabel('short'))),
              ],
              onChanged: (value) {
                if (value == null) return;
                vm.updateToneStyle(value);
              },
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(strings.languageToggleLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: profile.language,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'zh-TW', child: Text(strings.languageOptionLabel('zh-TW'))),
                DropdownMenuItem(value: 'en', child: Text(strings.languageOptionLabel('en'))),
              ],
              onChanged: (value) {
                if (value == null) return;
                vm.updateLanguage(value);
              },
            ),
            const SizedBox(height: 32),
            // 其他設定可擴充...
          ],
        ),
      ),
    );
  }

}
