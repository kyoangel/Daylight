class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.url,
    required this.notes,
  });

  final String version;
  final int buildNumber;
  final String url;
  final String notes;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] as String,
      buildNumber: json['buildNumber'] as int,
      url: json['url'] as String,
      notes: json['notes'] as String? ?? '',
    );
  }

  bool isNewerThan(int currentBuildNumber) => buildNumber > currentBuildNumber;
}
