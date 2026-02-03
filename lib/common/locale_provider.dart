import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/profile/viewmodel/profile_viewmodel.dart';
import 'app_locale.dart';

final localeProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileViewModelProvider);
  return normalizeLocale(profile.language);
});
