import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time/dates.dart';

/// Calendar dates are stored as sortable ISO text ("2026-10-22").
class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(String fromDb) => Dates.parse(fromDb);

  @override
  String toSql(DateTime value) => Dates.iso(value);
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) => (jsonDecode(fromDb) as List).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
