import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyViewModel extends StateNotifier<List<String>> {
  DailyViewModel() : super([]);

  void setGoals(List<String> goals) {
    state = goals;
  }
}

final dailyViewModelProvider = StateNotifierProvider<DailyViewModel, List<String>>((ref) => DailyViewModel()); 