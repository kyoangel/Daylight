import 'package:daylight/data/models/update_info.dart';
import 'package:daylight/data/repositories/update_check_repository.dart';

class FakeUpdateCheckRepository extends UpdateCheckRepository {
  FakeUpdateCheckRepository(this.result);

  final UpdateInfo? result;

  @override
  Future<UpdateInfo?> fetchLatest() async => result;
}
