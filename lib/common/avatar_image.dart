import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ImageProvider? avatarImageProvider(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) return null;

  if (avatarUrl.startsWith('data:image')) {
    final commaIndex = avatarUrl.indexOf(',');
    if (commaIndex == -1) return null;
    final base64Data = avatarUrl.substring(commaIndex + 1);
    final bytes = base64Decode(base64Data);
    return MemoryImage(bytes);
  }

  if (avatarUrl.startsWith('http') || avatarUrl.startsWith('blob:')) {
    return NetworkImage(avatarUrl);
  }

  if (kIsWeb) return null;
  return FileImage(File(avatarUrl));
}

String avatarMimeFromPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
