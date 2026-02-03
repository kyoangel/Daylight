import '../data_keys.dart';
import '../models/user_profile_model.dart';
import '../storage/local_storage.dart';

class UserProfileRepository {
  UserProfileRepository({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  Future<UserProfileModel> load() async {
    final json = await _storage.readJson(DataKeys.userProfile);
    if (json == null) return UserProfileModel.initial();
    return UserProfileModel.fromJson(json);
  }

  Future<void> save(UserProfileModel profile) async {
    await _storage.writeJson(DataKeys.userProfile, profile.toJson());
  }
}
