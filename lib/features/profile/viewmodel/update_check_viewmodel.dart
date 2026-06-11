import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../data/models/update_info.dart';
import '../../../data/repositories/update_check_repository.dart';

class UpdateCheckState {
  const UpdateCheckState({
    this.currentVersion = '',
    this.currentBuildNumber = 0,
  });

  final String currentVersion;
  final int currentBuildNumber;

  UpdateCheckState copyWith({
    String? currentVersion,
    int? currentBuildNumber,
  }) {
    return UpdateCheckState(
      currentVersion: currentVersion ?? this.currentVersion,
      currentBuildNumber: currentBuildNumber ?? this.currentBuildNumber,
    );
  }
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
}

final updateCheckViewModelProvider =
    StateNotifierProvider<UpdateCheckViewModel, UpdateCheckState>(
  (ref) => UpdateCheckViewModel(),
);
