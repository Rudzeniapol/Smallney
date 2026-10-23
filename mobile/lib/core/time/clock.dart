import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dates.dart';

/// Injectable time source, so tests can freeze "now".
class Clock {
  const Clock();

  DateTime now() => DateTime.now();

  DateTime today() => Dates.dateOf(now());
}

final clockProvider = Provider<Clock>((ref) => const Clock());
