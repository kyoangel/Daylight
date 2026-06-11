import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/update_info.dart';

class UpdateCheckRepository {
  UpdateCheckRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _versionUrl =
      'https://raw.githubusercontent.com/kyoangel/Daylight/main/version.json';

  Future<UpdateInfo?> fetchLatest() async {
    final response = await _client.get(Uri.parse(_versionUrl));
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UpdateInfo.fromJson(json);
  }
}
