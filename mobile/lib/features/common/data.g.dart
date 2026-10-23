// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settings)
final settingsProvider = SettingsProvider._();

final class SettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsRow?>,
          SettingsRow?,
          Stream<SettingsRow?>
        >
    with $FutureModifier<SettingsRow?>, $StreamProvider<SettingsRow?> {
  SettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsHash();

  @$internal
  @override
  $StreamProviderElement<SettingsRow?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SettingsRow?> create(Ref ref) {
    return settings(ref);
  }
}

String _$settingsHash() => r'e84bf71722ca6aca9c7ed7272b739375c19b7020';

@ProviderFor(accounts)
final accountsProvider = AccountsFamily._();

final class AccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountWithBalance>>,
          List<AccountWithBalance>,
          Stream<List<AccountWithBalance>>
        >
    with
        $FutureModifier<List<AccountWithBalance>>,
        $StreamProvider<List<AccountWithBalance>> {
  AccountsProvider._({
    required AccountsFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'accountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountsHash();

  @override
  String toString() {
    return r'accountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AccountWithBalance>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AccountWithBalance>> create(Ref ref) {
    final argument = this.argument as bool;
    return accounts(ref, includeArchived: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountsHash() => r'83e97b2518abfa9168c778502a513a7d7409153b';

final class AccountsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AccountWithBalance>>, bool> {
  AccountsFamily._()
    : super(
        retry: null,
        name: r'accountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountsProvider call({bool includeArchived = false}) =>
      AccountsProvider._(argument: includeArchived, from: this);

  @override
  String toString() => r'accountsProvider';
}

@ProviderFor(categoriesById)
final categoriesByIdProvider = CategoriesByIdProvider._();

final class CategoriesByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, CategoryRow>>,
          Map<String, CategoryRow>,
          Stream<Map<String, CategoryRow>>
        >
    with
        $FutureModifier<Map<String, CategoryRow>>,
        $StreamProvider<Map<String, CategoryRow>> {
  CategoriesByIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesByIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesByIdHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, CategoryRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, CategoryRow>> create(Ref ref) {
    return categoriesById(ref);
  }
}

String _$categoriesByIdHash() => r'8e33e0f6e68c3c4e537e1e6297def08ac5c17c98';

@ProviderFor(lastSyncAt)
final lastSyncAtProvider = LastSyncAtProvider._();

final class LastSyncAtProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  LastSyncAtProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastSyncAtProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastSyncAtHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return lastSyncAt(ref);
  }
}

String _$lastSyncAtHash() => r'315e35110ad771640587600e9bf94e114b6cf289';

@ProviderFor(outbox)
final outboxProvider = OutboxProvider._();

final class OutboxProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OutboxRow>>,
          List<OutboxRow>,
          Stream<List<OutboxRow>>
        >
    with $FutureModifier<List<OutboxRow>>, $StreamProvider<List<OutboxRow>> {
  OutboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxHash();

  @$internal
  @override
  $StreamProviderElement<List<OutboxRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<OutboxRow>> create(Ref ref) {
    return outbox(ref);
  }
}

String _$outboxHash() => r'f46e408f9d06a08ddd525aaa8847c225c7c806fe';

@ProviderFor(capital)
final capitalProvider = CapitalProvider._();

final class CapitalProvider
    extends $FunctionalProvider<Capital?, Capital?, Capital?>
    with $Provider<Capital?> {
  CapitalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'capitalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$capitalHash();

  @$internal
  @override
  $ProviderElement<Capital?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Capital? create(Ref ref) {
    return capital(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Capital? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Capital?>(value),
    );
  }
}

String _$capitalHash() => r'5887b4cf5f09cba569159340413bace1a36a397c';

@ProviderFor(currentMonth)
final currentMonthProvider = CurrentMonthProvider._();

final class CurrentMonthProvider
    extends $FunctionalProvider<MonthWindow, MonthWindow, MonthWindow>
    with $Provider<MonthWindow> {
  CurrentMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentMonthHash();

  @$internal
  @override
  $ProviderElement<MonthWindow> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MonthWindow create(Ref ref) {
    return currentMonth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthWindow value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthWindow>(value),
    );
  }
}

String _$currentMonthHash() => r'a430e2750ada33f072a76b79dace616e8808135c';
