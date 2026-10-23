import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// UUID v7 ids are generated on the device (offline-first).
abstract final class Ids {
  static const _uuid = Uuid();

  static String newId() => _uuid.v7();

  static bool isV7(String id) {
    final value = id.toLowerCase();
    return RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$').hasMatch(value);
  }

  /// The server's deterministic id of a recurring rule occurrence (docs/decisions.md, D28):
  /// timestamp = midnight UTC of [date], the rest from SHA-256("ruleId|yyyy-MM-dd").
  static String occurrenceId(String ruleId, DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    final seed = '${ruleId.toLowerCase()}|${_iso(day)}';
    final hash = sha256.convert(utf8.encode(seed)).bytes;
    final bytes = Uint8List(16);
    final ms = day.millisecondsSinceEpoch;
    for (var i = 0; i < 6; i++) {
      bytes[i] = (ms >> (8 * (5 - i))) & 0xFF;
    }
    bytes[6] = 0x70 | (hash[0] & 0x0F);
    bytes[7] = hash[1];
    bytes[8] = 0x80 | (hash[2] & 0x3F);
    for (var i = 0; i < 7; i++) {
      bytes[9 + i] = hash[3 + i];
    }
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  /// Creation time encoded in a UUID v7 (milliseconds since epoch), 0 when the id is not v7.
  static int timestampMs(String id) {
    if (!isV7(id)) return 0;
    final hex = id.replaceAll('-', '').substring(0, 12);
    return int.parse(hex, radix: 16);
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
