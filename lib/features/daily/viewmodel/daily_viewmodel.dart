import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/daily_entry.dart';
import '../../../data/repositories/daily_repository.dart';

class DailyViewModel extends StateNotifier<List<DailyEntry>> {
  DailyViewModel({DailyRepository? repository})
      : _repository = repository ?? DailyRepository(),
        super([]) {
    _load();
  }

  final DailyRepository _repository;

  Future<void> _load() async {
    final loaded = await _repository.loadAll();
    state = loaded;
  }

  Future<void> upsertEntry(DailyEntry entry) async {
    await _repository.upsert(entry);
    await _load();
  }
}

final dailyViewModelProvider = StateNotifierProvider<DailyViewModel, List<DailyEntry>>(
  (ref) => DailyViewModel(),
);
