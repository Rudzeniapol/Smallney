import 'package:flutter_test/flutter_test.dart';
import 'package:smallney/core/ids/uuid_v7.dart';
import 'package:smallney/core/time/dates.dart';

void main() {
  test('new ids are UUID v7', () {
    final id = Ids.newId();
    expect(Ids.isV7(id), isTrue);
    expect(Ids.isV7('d1b4b6c2-9b1d-4f6e-9f1a-1c2d3e4f5a6b'), isFalse, reason: 'v4');
    expect(Ids.timestampMs(id), closeTo(DateTime.now().millisecondsSinceEpoch, 5000));
  });

  test('occurrence id matches the server (shared test vector)', () {
    // Asserted by the backend as well: RecurringRuleTests.Occurrence_id_matches_the_shared_test_vector.
    expect(
      Ids.occurrenceId('0190a5d2-ac96-774b-bcce-b302099a8057', Dates.of(2026, 10, 22)),
      '01a160e8-5000-782c-bb47-103347a1eb6b',
    );
    expect(Ids.occurrenceId('0190A5D2-AC96-774B-BCCE-B302099A8057', Dates.of(2026, 10, 22)), '01a160e8-5000-782c-bb47-103347a1eb6b');
  });

  test('financial month follows the first day', () {
    final october = FinancialMonth.containing(Dates.of(2026, 10, 22), 5);
    expect(october.toString(), '2026-10');
    expect(october.start(5), Dates.of(2026, 10, 5));
    expect(october.end(5), Dates.of(2026, 11, 4));
    expect(FinancialMonth.containing(Dates.of(2026, 10, 4), 5).toString(), '2026-09');
    expect(FinancialMonth.containing(Dates.of(2026, 1, 3), 5).toString(), '2025-12');
    expect(const FinancialMonth(2026, 12).add(1), const FinancialMonth(2027, 1));
  });
}
