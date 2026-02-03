import 'dart:convert';
import 'package:flutter/services.dart';

abstract class ContentLoader {
  Future<List<Map<String, dynamic>>> loadList(String assetPath);
}

class AssetContentLoader implements ContentLoader {
  const AssetContentLoader();

  @override
  Future<List<Map<String, dynamic>>> loadList(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }
}
