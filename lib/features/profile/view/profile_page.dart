import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_model.dart';
import '../../../common/avatar_image.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileViewModelProvider);
    final vm = ref.read(userProfileViewModelProvider.notifier);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final appTheme = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeProvider);
    final strings = AppStrings.of(locale);
    final TextEditingController nicknameController = TextEditingController(text: profile.nickname);

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
            // 個人照片
            GestureDetector(
              onTap: () async {
                final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image == null) return;
                final bytes = await image.readAsBytes();
                await _showCropper(
                  context: context,
                  vm: vm,
                  theme: appTheme,
                  original: bytes,
                  strings: strings,
                );
              },
              child: CircleAvatar(
                radius: 48,
                backgroundColor: appTheme.color.withOpacity(0.2),
                backgroundImage: avatarImageProvider(profile.avatarUrl),
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
                      labelText: strings.nicknameLabel,
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
                  child: Text(strings.save, style: const TextStyle(color: Colors.white)),
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
            // 其他設定可擴充...
          ],
        ),
      ),
    );
  }

  Future<void> _showCropper({
    required BuildContext context,
    required UserProfileViewModel vm,
    required AppTheme theme,
    required Uint8List original,
    required AppStrings strings,
  }) async {
    final controller = CropController();
    Uint8List current = original;
    double sizeRatio = 0.8;
    Size viewport = const Size(320, 320);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> rotate(int angle) async {
              final decoded = img.decodeImage(current);
              if (decoded == null) return;
              final rotated = img.copyRotate(decoded, angle: angle);
              final encoded = Uint8List.fromList(img.encodePng(rotated));
              setState(() {
                current = encoded;
                controller.image = current;
              });
            }

            void updateCropRect(double ratio) {
              sizeRatio = ratio;
              final size = (viewport.shortestSide * ratio)
                  .clamp(120.0, viewport.shortestSide)
                  .toDouble();
              final rect = Rect.fromCenter(
                center: viewport.center(Offset.zero),
                width: size,
                height: size,
              );
              controller.cropRect = rect;
            }

            return AlertDialog(
              title: Text(strings.cropPhotoTitle),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 320,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          viewport = Size(constraints.maxWidth, constraints.maxHeight);
                          return Crop(
                            image: current,
                            controller: controller,
                            withCircleUi: true,
                            interactive: true,
                            baseColor: Colors.black12,
                            maskColor: Colors.black38,
                            initialSize: sizeRatio,
                            onCropped: (cropped) async {
                              final dataUri = 'data:image/png;base64,${base64Encode(cropped)}';
                              await vm.updateAvatar(dataUri);
                              if (Navigator.of(dialogContext).canPop()) {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.rotate_left),
                          onPressed: () => rotate(-90),
                        ),
                        Expanded(
                          child: Slider(
                            value: sizeRatio,
                            min: 0.5,
                            max: 1.0,
                            divisions: 5,
                            onChanged: (value) {
                              setState(() {
                                updateCropRect(value);
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.rotate_right),
                          onPressed: () => rotate(90),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(strings.cropCancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.color),
                  onPressed: () => controller.cropCircle(),
                  child: Text(strings.cropApply, style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 
