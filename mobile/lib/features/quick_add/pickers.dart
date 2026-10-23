import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/db/app_database.dart';
import '../../data/model/enums.dart';
import '../../data/providers.dart';
import '../../data/repositories/accounts_repository.dart';
import '../common/visuals.dart';

Future<String?> pickAccount(BuildContext context, List<AccountWithBalance> accounts) => showAppSheet<String>(
      context,
      (context) {
        final l10n = context.l10n;
        return SafeArea(
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
            Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 12), child: Text(l10n.chooseAccount, style: Theme.of(context).textTheme.titleLarge)),
            if (accounts.isEmpty) EmptyState(icon: 'card', title: l10n.noAccountsYet),
            for (final a in accounts)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: IconTile(icon: accountVisual(a.account.type).icon, color: accountVisual(a.account.type).color, size: 40),
                title: Text(a.account.name),
                trailing: Text(context.money(a.money), style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, a.account.id),
              ),
          ]),
        );
      },
    );

/// All categories of a kind, subcategories under their parent.
Future<String?> pickCategory(BuildContext context, CategoryKind kind, String? selectedId) => showAppSheet<String>(
      context,
      (context) => _CategorySheet(kind: kind, selectedId: selectedId),
    );

class _CategorySheet extends ConsumerWidget {
  const _CategorySheet({required this.kind, required this.selectedId});

  final CategoryKind kind;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final categories = ref.watch(_categoriesProvider(kind)).value ?? const <CategoryRow>[];
    final roots = categories.where((x) => x.parentId == null).toList();

    Widget tile(CategoryRow category, {bool child = false}) {
      final visual = categoryVisual(category);
      return ListTile(
        contentPadding: EdgeInsets.only(left: child ? 36 : 4, right: 4),
        leading: IconTile(icon: visual.icon, color: visual.color, size: child ? 34 : 40, iconSize: child ? 18 : 22),
        title: Text(category.name),
        trailing: category.id == selectedId ? AppIconCheck(color: c.accentText) : null,
        onTap: () => Navigator.pop(context, category.id),
      );
    }

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(controller: controller, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(context.l10n.categories, style: Theme.of(context).textTheme.titleLarge),
          ),
          for (final root in roots) ...[
            tile(root),
            for (final sub in categories.where((x) => x.parentId == root.id)) tile(sub, child: true),
          ],
        ]),
      ),
    );
  }
}

final _categoriesProvider = StreamProvider.family<List<CategoryRow>, CategoryKind>(
  (ref, kind) => ref.watch(categoriesRepositoryProvider).watchAll(kind: kind),
);

class AppIconCheck extends StatelessWidget {
  const AppIconCheck({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Icon(Icons.check_rounded, color: color);
}

typedef NoteResult = ({String? note, List<String> tags});

Future<NoteResult?> editNote(BuildContext context, {String? note, List<String> tags = const []}) => showAppSheet<NoteResult>(
      context,
      (context) => _NoteSheet(note: note, tags: tags),
    );

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.note, required this.tags});

  final String? note;
  final List<String> tags;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final _note = TextEditingController(text: widget.note);
  late final _tags = TextEditingController(text: widget.tags.join(', '));

  @override
  void dispose() {
    _note.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _done() => Navigator.pop<NoteResult>(context, (
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        tags: _tags.text.split(',').map((t) => t.trim().replaceFirst('#', '')).where((t) => t.isNotEmpty).toList(),
      ));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l10n.note, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(controller: _note, autofocus: true, maxLength: 500, decoration: InputDecoration(hintText: l10n.noteHint, counterText: '')),
          const SizedBox(height: 10),
          TextField(
            controller: _tags,
            decoration: InputDecoration(labelText: l10n.tags, hintText: l10n.tagsHint),
            onSubmitted: (_) => _done(),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: l10n.done, onPressed: _done),
        ]),
      ),
    );
  }
}
