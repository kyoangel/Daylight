import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_model.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileViewModelProvider);
    final vm = ref.read(userProfileViewModelProvider.notifier);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final appTheme = ref.watch(themeNotifierProvider);
    final TextEditingController nicknameController = TextEditingController(text: profile.nickname);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('個人', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
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
            // 個人照片
            GestureDetector(
              onTap: () async {
                final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  final cropped = await ImageCropper().cropImage(
                    sourcePath: image.path,
                    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                    uiSettings: [
                      AndroidUiSettings(
                        toolbarTitle: '裁切照片',
                        toolbarColor: appTheme.color,
                        toolbarWidgetColor: Colors.white,
                        lockAspectRatio: true,
                      ),
                      IOSUiSettings(title: '裁切照片'),
                      WebUiSettings(
                        context: context,
                      ),
                    ],
                  );
                  if (cropped != null) {
                    vm.updateAvatar(cropped.path);
                  }
                }
              },
              child: CircleAvatar(
                radius: 48,
                backgroundColor: appTheme.color.withOpacity(0.2),
                backgroundImage: profile.avatarUrl != null ? FileImage(File(profile.avatarUrl!)) : null,
                child: profile.avatarUrl == null
                    ? Icon(Icons.camera_alt, color: appTheme.color, size: 36)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            // 暱稱編輯
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      labelText: '暱稱',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: appTheme.color.withOpacity(0.08),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    vm.updateNickname(nicknameController.text);
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text('儲存', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 主題色切換
            Align(
              alignment: Alignment.centerLeft,
              child: Text('主題色', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
            // 其他設定可擴充...
          ],
        ),
      ),
    );
  }
} 
