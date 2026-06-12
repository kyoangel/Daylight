import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../viewmodel/update_check_viewmodel.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_model.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';
import '../../../features/daily/viewmodel/daily_viewmodel.dart';
import '../../../data/models/daily_entry.dart';
import '../../../data/repositories/daily_repository.dart';

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
    final updateState = ref.watch(updateCheckViewModelProvider);
    final updateVm = ref.read(updateCheckViewModelProvider.notifier);
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
        title: Text(
          strings.profileTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        backgroundColor: appTheme.color,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: appTheme.color.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.themeColor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  kAppThemes.map((color) {
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
                          border:
                              isSelected
                                  ? Border.all(color: Colors.black54, width: 3)
                                  : null,
                        ),
                        child:
                            isSelected
                                ? const Icon(Icons.check, color: Colors.black54)
                                : null,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.toneLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: profile.toneStyle,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: 'gentle',
                  child: Text(strings.toneOptionLabel('gentle')),
                ),
                DropdownMenuItem(
                  value: 'encourage',
                  child: Text(strings.toneOptionLabel('encourage')),
                ),
                DropdownMenuItem(
                  value: 'short',
                  child: Text(strings.toneOptionLabel('short')),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                vm.updateToneStyle(value);
              },
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.languageToggleLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: profile.language,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: 'zh-TW',
                  child: Text(strings.languageOptionLabel('zh-TW')),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(strings.languageOptionLabel('en')),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                vm.updateLanguage(value);
              },
            ),
            const SizedBox(height: 32),

            // --- Data backup ---
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('資料備份',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('換手機前請先匯出，再到新手機匯入。',
                        style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _exportData(context),
                            icon: const Icon(Icons.upload_outlined, size: 18),
                            label: const Text('匯出資料'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _importData(context),
                            icon: const Icon(Icons.download_outlined, size: 18),
                            label: const Text('匯入資料'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- App update ---
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.appUpdateTitle,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${strings.appUpdateCurrentVersionLabel}: ${updateState.currentVersion} (${updateState.currentBuildNumber})',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    if (updateState.hasUpdate) ...[
                      Text(
                        '${strings.appUpdateAvailableLabel}: ${updateState.latestInfo!.version}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _openDownloadUrl(updateState.latestInfo!.url),
                          icon: const Icon(Icons.download_outlined, size: 18),
                          label: Text(strings.appUpdateDownloadButton),
                        ),
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: updateState.isChecking
                              ? null
                              : () => updateVm.checkForUpdate(),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(
                            updateState.checkFailed
                                ? strings.appUpdateCheckFailed
                                : (updateState.hasChecked
                                    ? strings.appUpdateUpToDate
                                    : strings.appUpdateCheckButton),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _openDownloadUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final repo = DailyRepository();
      final entries = await repo.loadAll();
      if (entries.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('目前沒有任何紀錄可以匯出')),
          );
        }
        return;
      }
      final json = jsonEncode(entries.map((e) => e.toJson()).toList());
      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final filename =
          'daylight_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
      final file = File('${dir.path}/$filename');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Daylight 資料備份',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('匯出失敗：$e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('匯入資料'),
        content: const Text('匯入後同日期的紀錄會被覆蓋，其他日期保留。確定繼續？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('確定')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> raw = jsonDecode(content);
      final entries = raw.map((e) => DailyEntry.fromJson(e as Map<String, dynamic>)).toList();

      final vm = ref.read(dailyViewModelProvider.notifier);
      for (final entry in entries) {
        await vm.upsertEntry(entry);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已匯入 ${entries.length} 筆紀錄')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('匯入失敗：請確認選取的是正確的備份檔案')),
        );
      }
    }
  }

}
