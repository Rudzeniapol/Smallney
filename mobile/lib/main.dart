import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/db/app_database.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([initializeDateFormatting('ru'), initializeDateFormatting('en')]);
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(AppDatabase.open()),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const SmallneyApp(),
  ));
}
