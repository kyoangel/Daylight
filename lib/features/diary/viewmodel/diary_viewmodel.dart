import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/diary_entry.dart';
import '../../../data/repositories/diary_repository.dart';

class DiaryViewModel extends StateNotifier<List<DiaryEntry>> {
  DiaryViewModel({DiaryRepository? repository})
      : _repository = repository ?? DiaryRepository(),
        super([]) {
    _load();
  }

  final DiaryRepository _repository;

  Future<void> _load() async {
    final loaded = await _repository.loadAll();
    state = loaded;
  }

  Future<void> addEntry(DiaryEntry entry) async {
    await _repository.add(entry);
    await _load();
  }
}

final diaryViewModelProvider = StateNotifierProvider<DiaryViewModel, List<DiaryEntry>>(
  (ref) => DiaryViewModel(),
);
