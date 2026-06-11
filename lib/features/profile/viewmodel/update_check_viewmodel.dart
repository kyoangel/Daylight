import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../data/models/update_info.dart';
import '../../../data/repositories/update_check_repository.dart';

class UpdateCheckState {
  const UpdateCheckState({
    this.currentVersion = '',
    this.currentBuildNumber = 0,
    this.isChecking = false,
    this.hasChecked = false,
    this.checkFailed = false,
    this.latestInfo,
  });

  final String currentVersion;
  final int currentBuildNumber;
  final bool isChecking;
  final bool hasChecked;
  final bool checkFailed;
  final UpdateInfo? latestInfo;

  UpdateCheckState copyWith({
    String? currentVersion,
    int? currentBuildNumber,
    bool? isChecking,
    bool? hasChecked,
    bool? checkFailed,
    UpdateInfo? latestInfo,
  }) {
    return UpdateCheckState(
      currentVersion: currentVersion ?? this.currentVersion,
      currentBuildNumber: currentBuildNumber ?? this.currentBuildNumber,
      isChecking: isChecking ?? this.isChecking,
      hasChecked: hasChecked ?? this.hasChecked,
      checkFailed: checkFailed ?? this.checkFailed,
      latestInfo: latestInfo ?? this.latestInfo,
    );
  }

  bool get hasUpdate =>
      latestInfo != null && latestInfo!.isNewerThan(currentBuildNumber);
}

class UpdateCheckViewModel extends StateNotifier<UpdateCheckState> {
  UpdateCheckViewModel({UpdateCheckRepository? repository})
      : _repository = repository ?? UpdateCheckRepository(),
        super(const UpdateCheckState()) {
    _loadCurrentVersion();
  }

  final UpdateCheckRepository _repository;

  Future<void> _loadCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    state = state.copyWith(
      currentVersion: info.version,
      currentBuildNumber: int.tryParse(info.buildNumber) ?? 0,
    );
  }

  Future<void> checkForUpdate() async {
    state = state.copyWith(isChecking: true, checkFailed: false);
    final latest = await _repository.fetchLatest();
    state = state.copyWith(
      isChecking: false,
      hasChecked: true,
      checkFailed: latest == null,
      latestInfo: latest,
    );
  }
}

final updateCheckViewModelProvider =
    StateNotifierProvider<UpdateCheckViewModel, UpdateCheckState>(
  (ref) => UpdateCheckViewModel(),
);
