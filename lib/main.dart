import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'data/storage/data_migrator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataMigrator().migrate();
  runApp(const ProviderScope(child: DaylightApp()));
}
