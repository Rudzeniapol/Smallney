import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../model/enums.dart';

class CategoriesRepository {
  CategoriesRepository(this._db);

  final AppDatabase _db;

  Stream<List<CategoryRow>> watchAll({CategoryKind? kind, bool includeArchived = false}) {
    final query = _db.select(_db.categories);
    query.where((c) {
      Expression<bool> e = const Constant(true);
      if (kind != null) e = e & c.kind.equalsValue(kind);
      if (!includeArchived) e = e & c.isArchived.equals(false);
      return e;
    });
    query.orderBy([(c) => OrderingTerm.asc(c.name, nulls: NullsOrder.last)]);
    return query.watch();
  }

  Stream<Map<String, CategoryRow>> watchById() =>
      _db.select(_db.categories).watch().map((rows) => {for (final c in rows) c.id: c});

  /// Categories for the quick add grid: most recently used first, then the rest alphabetically;
  /// parents that have subcategories are left out (the subcategory is more precise).
  Stream<List<CategoryRow>> watchQuickPicks(CategoryKind kind) => _db
      .customSelect(
        '''
        SELECT c.*, (SELECT MAX(t.created_at_us) FROM transactions t WHERE t.category_id = c.id) AS last_used
        FROM categories c
        WHERE c.kind = ?1 AND c.is_archived = 0
          AND NOT EXISTS (SELECT 1 FROM categories ch WHERE ch.parent_id = c.id AND ch.is_archived = 0)
        ORDER BY last_used IS NULL, last_used DESC, c.system_code IS NOT NULL, c.name COLLATE NOCASE
        ''',
        variables: [Variable.withString(kind.name)],
        readsFrom: {_db.categories, _db.transactions},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.categories.map(r.data)).toList());
}
