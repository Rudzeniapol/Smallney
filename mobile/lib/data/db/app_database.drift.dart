// dart format width=80
// ignore_for_file: type=lint
part of 'app_database.dart';

class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AccountType>($AccountsTable.$convertertype);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta(
    'initialBalance',
  );
  @override
  late final GeneratedColumn<int> initialBalance = GeneratedColumn<int>(
    'initial_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _includeInTotalsMeta = const VerificationMeta(
    'includeInTotals',
  );
  @override
  late final GeneratedColumn<bool> includeInTotals = GeneratedColumn<bool>(
    'include_in_totals',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_in_totals" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<int> creditLimit = GeneratedColumn<int>(
    'credit_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interestRatePercentMeta =
      const VerificationMeta('interestRatePercent');
  @override
  late final GeneratedColumn<String> interestRatePercent =
      GeneratedColumn<String>(
        'interest_rate_percent',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<CapitalizationPeriod?, String>
  capitalizationPeriod =
      GeneratedColumn<String>(
        'capitalization_period',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CapitalizationPeriod?>(
        $AccountsTable.$convertercapitalizationPeriodn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> openDate =
      GeneratedColumn<String>(
        'open_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($AccountsTable.$converteropenDaten);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> maturityDate =
      GeneratedColumn<String>(
        'maturity_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($AccountsTable.$convertermaturityDaten);
  @override
  List<GeneratedColumn> get $columns => [
    version,
    id,
    name,
    type,
    currency,
    initialBalance,
    includeInTotals,
    isArchived,
    sortOrder,
    color,
    icon,
    creditLimit,
    interestRatePercent,
    capitalizationPeriod,
    openDate,
    maturityDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
        _initialBalanceMeta,
        initialBalance.isAcceptableOrUnknown(
          data['initial_balance']!,
          _initialBalanceMeta,
        ),
      );
    }
    if (data.containsKey('include_in_totals')) {
      context.handle(
        _includeInTotalsMeta,
        includeInTotals.isAcceptableOrUnknown(
          data['include_in_totals']!,
          _includeInTotalsMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('interest_rate_percent')) {
      context.handle(
        _interestRatePercentMeta,
        interestRatePercent.isAcceptableOrUnknown(
          data['interest_rate_percent']!,
          _interestRatePercentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $AccountsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      initialBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_balance'],
      )!,
      includeInTotals: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_in_totals'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit'],
      ),
      interestRatePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_rate_percent'],
      ),
      capitalizationPeriod: $AccountsTable.$convertercapitalizationPeriodn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}capitalization_period'],
            ),
          ),
      openDate: $AccountsTable.$converteropenDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}open_date'],
        ),
      ),
      maturityDate: $AccountsTable.$convertermaturityDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}maturity_date'],
        ),
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountType, String, String> $convertertype =
      const EnumNameConverter<AccountType>(AccountType.values);
  static JsonTypeConverter2<CapitalizationPeriod, String, String>
  $convertercapitalizationPeriod =
      const EnumNameConverter<CapitalizationPeriod>(
        CapitalizationPeriod.values,
      );
  static JsonTypeConverter2<CapitalizationPeriod?, String?, String?>
  $convertercapitalizationPeriodn = JsonTypeConverter2.asNullable(
    $convertercapitalizationPeriod,
  );
  static TypeConverter<DateTime, String> $converteropenDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converteropenDaten =
      NullAwareTypeConverter.wrap($converteropenDate);
  static TypeConverter<DateTime, String> $convertermaturityDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $convertermaturityDaten =
      NullAwareTypeConverter.wrap($convertermaturityDate);
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final int? version;
  final String id;
  final String name;
  final AccountType type;
  final String currency;
  final int initialBalance;
  final bool includeInTotals;
  final bool isArchived;
  final int sortOrder;
  final String? color;
  final String? icon;
  final int? creditLimit;

  /// Decimal as text (a rate is not money, but floats are still avoided).
  final String? interestRatePercent;
  final CapitalizationPeriod? capitalizationPeriod;
  final DateTime? openDate;
  final DateTime? maturityDate;
  const AccountRow({
    this.version,
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.initialBalance,
    required this.includeInTotals,
    required this.isArchived,
    required this.sortOrder,
    this.color,
    this.icon,
    this.creditLimit,
    this.interestRatePercent,
    this.capitalizationPeriod,
    this.openDate,
    this.maturityDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($AccountsTable.$convertertype.toSql(type));
    }
    map['currency'] = Variable<String>(currency);
    map['initial_balance'] = Variable<int>(initialBalance);
    map['include_in_totals'] = Variable<bool>(includeInTotals);
    map['is_archived'] = Variable<bool>(isArchived);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<int>(creditLimit);
    }
    if (!nullToAbsent || interestRatePercent != null) {
      map['interest_rate_percent'] = Variable<String>(interestRatePercent);
    }
    if (!nullToAbsent || capitalizationPeriod != null) {
      map['capitalization_period'] = Variable<String>(
        $AccountsTable.$convertercapitalizationPeriodn.toSql(
          capitalizationPeriod,
        ),
      );
    }
    if (!nullToAbsent || openDate != null) {
      map['open_date'] = Variable<String>(
        $AccountsTable.$converteropenDaten.toSql(openDate),
      );
    }
    if (!nullToAbsent || maturityDate != null) {
      map['maturity_date'] = Variable<String>(
        $AccountsTable.$convertermaturityDaten.toSql(maturityDate),
      );
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      id: Value(id),
      name: Value(name),
      type: Value(type),
      currency: Value(currency),
      initialBalance: Value(initialBalance),
      includeInTotals: Value(includeInTotals),
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      interestRatePercent: interestRatePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(interestRatePercent),
      capitalizationPeriod: capitalizationPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(capitalizationPeriod),
      openDate: openDate == null && nullToAbsent
          ? const Value.absent()
          : Value(openDate),
      maturityDate: maturityDate == null && nullToAbsent
          ? const Value.absent()
          : Value(maturityDate),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      version: serializer.fromJson<int?>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $AccountsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      currency: serializer.fromJson<String>(json['currency']),
      initialBalance: serializer.fromJson<int>(json['initialBalance']),
      includeInTotals: serializer.fromJson<bool>(json['includeInTotals']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      creditLimit: serializer.fromJson<int?>(json['creditLimit']),
      interestRatePercent: serializer.fromJson<String?>(
        json['interestRatePercent'],
      ),
      capitalizationPeriod: $AccountsTable.$convertercapitalizationPeriodn
          .fromJson(serializer.fromJson<String?>(json['capitalizationPeriod'])),
      openDate: serializer.fromJson<DateTime?>(json['openDate']),
      maturityDate: serializer.fromJson<DateTime?>(json['maturityDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int?>(version),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $AccountsTable.$convertertype.toJson(type),
      ),
      'currency': serializer.toJson<String>(currency),
      'initialBalance': serializer.toJson<int>(initialBalance),
      'includeInTotals': serializer.toJson<bool>(includeInTotals),
      'isArchived': serializer.toJson<bool>(isArchived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
      'creditLimit': serializer.toJson<int?>(creditLimit),
      'interestRatePercent': serializer.toJson<String?>(interestRatePercent),
      'capitalizationPeriod': serializer.toJson<String?>(
        $AccountsTable.$convertercapitalizationPeriodn.toJson(
          capitalizationPeriod,
        ),
      ),
      'openDate': serializer.toJson<DateTime?>(openDate),
      'maturityDate': serializer.toJson<DateTime?>(maturityDate),
    };
  }

  AccountRow copyWith({
    Value<int?> version = const Value.absent(),
    String? id,
    String? name,
    AccountType? type,
    String? currency,
    int? initialBalance,
    bool? includeInTotals,
    bool? isArchived,
    int? sortOrder,
    Value<String?> color = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<int?> creditLimit = const Value.absent(),
    Value<String?> interestRatePercent = const Value.absent(),
    Value<CapitalizationPeriod?> capitalizationPeriod = const Value.absent(),
    Value<DateTime?> openDate = const Value.absent(),
    Value<DateTime?> maturityDate = const Value.absent(),
  }) => AccountRow(
    version: version.present ? version.value : this.version,
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    initialBalance: initialBalance ?? this.initialBalance,
    includeInTotals: includeInTotals ?? this.includeInTotals,
    isArchived: isArchived ?? this.isArchived,
    sortOrder: sortOrder ?? this.sortOrder,
    color: color.present ? color.value : this.color,
    icon: icon.present ? icon.value : this.icon,
    creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
    interestRatePercent: interestRatePercent.present
        ? interestRatePercent.value
        : this.interestRatePercent,
    capitalizationPeriod: capitalizationPeriod.present
        ? capitalizationPeriod.value
        : this.capitalizationPeriod,
    openDate: openDate.present ? openDate.value : this.openDate,
    maturityDate: maturityDate.present ? maturityDate.value : this.maturityDate,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      includeInTotals: data.includeInTotals.present
          ? data.includeInTotals.value
          : this.includeInTotals,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      interestRatePercent: data.interestRatePercent.present
          ? data.interestRatePercent.value
          : this.interestRatePercent,
      capitalizationPeriod: data.capitalizationPeriod.present
          ? data.capitalizationPeriod.value
          : this.capitalizationPeriod,
      openDate: data.openDate.present ? data.openDate.value : this.openDate,
      maturityDate: data.maturityDate.present
          ? data.maturityDate.value
          : this.maturityDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('includeInTotals: $includeInTotals, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('interestRatePercent: $interestRatePercent, ')
          ..write('capitalizationPeriod: $capitalizationPeriod, ')
          ..write('openDate: $openDate, ')
          ..write('maturityDate: $maturityDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    version,
    id,
    name,
    type,
    currency,
    initialBalance,
    includeInTotals,
    isArchived,
    sortOrder,
    color,
    icon,
    creditLimit,
    interestRatePercent,
    capitalizationPeriod,
    openDate,
    maturityDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.version == this.version &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.initialBalance == this.initialBalance &&
          other.includeInTotals == this.includeInTotals &&
          other.isArchived == this.isArchived &&
          other.sortOrder == this.sortOrder &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.creditLimit == this.creditLimit &&
          other.interestRatePercent == this.interestRatePercent &&
          other.capitalizationPeriod == this.capitalizationPeriod &&
          other.openDate == this.openDate &&
          other.maturityDate == this.maturityDate);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<int?> version;
  final Value<String> id;
  final Value<String> name;
  final Value<AccountType> type;
  final Value<String> currency;
  final Value<int> initialBalance;
  final Value<bool> includeInTotals;
  final Value<bool> isArchived;
  final Value<int> sortOrder;
  final Value<String?> color;
  final Value<String?> icon;
  final Value<int?> creditLimit;
  final Value<String?> interestRatePercent;
  final Value<CapitalizationPeriod?> capitalizationPeriod;
  final Value<DateTime?> openDate;
  final Value<DateTime?> maturityDate;
  final Value<int> rowid;
  const AccountsCompanion({
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.includeInTotals = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.interestRatePercent = const Value.absent(),
    this.capitalizationPeriod = const Value.absent(),
    this.openDate = const Value.absent(),
    this.maturityDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.version = const Value.absent(),
    required String id,
    required String name,
    required AccountType type,
    required String currency,
    this.initialBalance = const Value.absent(),
    this.includeInTotals = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.interestRatePercent = const Value.absent(),
    this.capitalizationPeriod = const Value.absent(),
    this.openDate = const Value.absent(),
    this.maturityDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       currency = Value(currency);
  static Insertable<AccountRow> custom({
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<int>? initialBalance,
    Expression<bool>? includeInTotals,
    Expression<bool>? isArchived,
    Expression<int>? sortOrder,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? creditLimit,
    Expression<String>? interestRatePercent,
    Expression<String>? capitalizationPeriod,
    Expression<String>? openDate,
    Expression<String>? maturityDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (includeInTotals != null) 'include_in_totals': includeInTotals,
      if (isArchived != null) 'is_archived': isArchived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (interestRatePercent != null)
        'interest_rate_percent': interestRatePercent,
      if (capitalizationPeriod != null)
        'capitalization_period': capitalizationPeriod,
      if (openDate != null) 'open_date': openDate,
      if (maturityDate != null) 'maturity_date': maturityDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<int?>? version,
    Value<String>? id,
    Value<String>? name,
    Value<AccountType>? type,
    Value<String>? currency,
    Value<int>? initialBalance,
    Value<bool>? includeInTotals,
    Value<bool>? isArchived,
    Value<int>? sortOrder,
    Value<String?>? color,
    Value<String?>? icon,
    Value<int?>? creditLimit,
    Value<String?>? interestRatePercent,
    Value<CapitalizationPeriod?>? capitalizationPeriod,
    Value<DateTime?>? openDate,
    Value<DateTime?>? maturityDate,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      version: version ?? this.version,
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
      includeInTotals: includeInTotals ?? this.includeInTotals,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      creditLimit: creditLimit ?? this.creditLimit,
      interestRatePercent: interestRatePercent ?? this.interestRatePercent,
      capitalizationPeriod: capitalizationPeriod ?? this.capitalizationPeriod,
      openDate: openDate ?? this.openDate,
      maturityDate: maturityDate ?? this.maturityDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $AccountsTable.$convertertype.toSql(type.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<int>(initialBalance.value);
    }
    if (includeInTotals.present) {
      map['include_in_totals'] = Variable<bool>(includeInTotals.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<int>(creditLimit.value);
    }
    if (interestRatePercent.present) {
      map['interest_rate_percent'] = Variable<String>(
        interestRatePercent.value,
      );
    }
    if (capitalizationPeriod.present) {
      map['capitalization_period'] = Variable<String>(
        $AccountsTable.$convertercapitalizationPeriodn.toSql(
          capitalizationPeriod.value,
        ),
      );
    }
    if (openDate.present) {
      map['open_date'] = Variable<String>(
        $AccountsTable.$converteropenDaten.toSql(openDate.value),
      );
    }
    if (maturityDate.present) {
      map['maturity_date'] = Variable<String>(
        $AccountsTable.$convertermaturityDaten.toSql(maturityDate.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('includeInTotals: $includeInTotals, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('interestRatePercent: $interestRatePercent, ')
          ..write('capitalizationPeriod: $capitalizationPeriod, ')
          ..write('openDate: $openDate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategoryKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CategoryKind>($CategoriesTable.$converterkind);
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _systemCodeMeta = const VerificationMeta(
    'systemCode',
  );
  @override
  late final GeneratedColumn<String> systemCode = GeneratedColumn<String>(
    'system_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    version,
    id,
    name,
    kind,
    parentId,
    icon,
    color,
    isArchived,
    systemCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('system_code')) {
      context.handle(
        _systemCodeMeta,
        systemCode.isAcceptableOrUnknown(data['system_code']!, _systemCodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $CategoriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      systemCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_code'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoryKind, String, String> $converterkind =
      const EnumNameConverter<CategoryKind>(CategoryKind.values);
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int? version;
  final String id;
  final String name;
  final CategoryKind kind;
  final String? parentId;
  final String? icon;
  final String? color;
  final bool isArchived;
  final String? systemCode;
  const CategoryRow({
    this.version,
    required this.id,
    required this.name,
    required this.kind,
    this.parentId,
    this.icon,
    this.color,
    required this.isArchived,
    this.systemCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || systemCode != null) {
      map['system_code'] = Variable<String>(systemCode);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      isArchived: Value(isArchived),
      systemCode: systemCode == null && nullToAbsent
          ? const Value.absent()
          : Value(systemCode),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      version: serializer.fromJson<int?>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $CategoriesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      parentId: serializer.fromJson<String?>(json['parentId']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      systemCode: serializer.fromJson<String?>(json['systemCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int?>(version),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $CategoriesTable.$converterkind.toJson(kind),
      ),
      'parentId': serializer.toJson<String?>(parentId),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'isArchived': serializer.toJson<bool>(isArchived),
      'systemCode': serializer.toJson<String?>(systemCode),
    };
  }

  CategoryRow copyWith({
    Value<int?> version = const Value.absent(),
    String? id,
    String? name,
    CategoryKind? kind,
    Value<String?> parentId = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    bool? isArchived,
    Value<String?> systemCode = const Value.absent(),
  }) => CategoryRow(
    version: version.present ? version.value : this.version,
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    parentId: parentId.present ? parentId.value : this.parentId,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    isArchived: isArchived ?? this.isArchived,
    systemCode: systemCode.present ? systemCode.value : this.systemCode,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      systemCode: data.systemCode.present
          ? data.systemCode.value
          : this.systemCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('parentId: $parentId, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived, ')
          ..write('systemCode: $systemCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    version,
    id,
    name,
    kind,
    parentId,
    icon,
    color,
    isArchived,
    systemCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.version == this.version &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.parentId == this.parentId &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isArchived == this.isArchived &&
          other.systemCode == this.systemCode);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int?> version;
  final Value<String> id;
  final Value<String> name;
  final Value<CategoryKind> kind;
  final Value<String?> parentId;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<bool> isArchived;
  final Value<String?> systemCode;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.parentId = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.systemCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.version = const Value.absent(),
    required String id,
    required String name,
    required CategoryKind kind,
    this.parentId = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.systemCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind);
  static Insertable<CategoryRow> custom({
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? parentId,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? isArchived,
    Expression<String>? systemCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (parentId != null) 'parent_id': parentId,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isArchived != null) 'is_archived': isArchived,
      if (systemCode != null) 'system_code': systemCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<int?>? version,
    Value<String>? id,
    Value<String>? name,
    Value<CategoryKind>? kind,
    Value<String?>? parentId,
    Value<String?>? icon,
    Value<String?>? color,
    Value<bool>? isArchived,
    Value<String?>? systemCode,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      version: version ?? this.version,
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      systemCode: systemCode ?? this.systemCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (systemCode.present) {
      map['system_code'] = Variable<String>(systemCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('parentId: $parentId, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived, ')
          ..write('systemCode: $systemCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionType>($TransactionsTable.$convertertype);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TransactionsTable.$converterdate);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($TransactionsTable.$convertertags);
  @override
  late final GeneratedColumnWithTypeConverter<TransactionStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TransactionStatus>($TransactionsTable.$converterstatus);
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
    'to_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toAmountMeta = const VerificationMeta(
    'toAmount',
  );
  @override
  late final GeneratedColumn<int> toAmount = GeneratedColumn<int>(
    'to_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savingsGoalIdMeta = const VerificationMeta(
    'savingsGoalId',
  );
  @override
  late final GeneratedColumn<String> savingsGoalId = GeneratedColumn<String>(
    'savings_goal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringRuleIdMeta = const VerificationMeta(
    'recurringRuleId',
  );
  @override
  late final GeneratedColumn<String> recurringRuleId = GeneratedColumn<String>(
    'recurring_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String>
  recurrenceDate = GeneratedColumn<String>(
    'recurrence_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<DateTime?>($TransactionsTable.$converterrecurrenceDaten);
  static const VerificationMeta _createdAtUsMeta = const VerificationMeta(
    'createdAtUs',
  );
  @override
  late final GeneratedColumn<int> createdAtUs = GeneratedColumn<int>(
    'created_at_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    version,
    id,
    accountId,
    type,
    amount,
    categoryId,
    date,
    note,
    tags,
    status,
    toAccountId,
    toAmount,
    savingsGoalId,
    recurringRuleId,
    recurrenceDate,
    createdAtUs,
    searchText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('to_amount')) {
      context.handle(
        _toAmountMeta,
        toAmount.isAcceptableOrUnknown(data['to_amount']!, _toAmountMeta),
      );
    }
    if (data.containsKey('savings_goal_id')) {
      context.handle(
        _savingsGoalIdMeta,
        savingsGoalId.isAcceptableOrUnknown(
          data['savings_goal_id']!,
          _savingsGoalIdMeta,
        ),
      );
    }
    if (data.containsKey('recurring_rule_id')) {
      context.handle(
        _recurringRuleIdMeta,
        recurringRuleId.isAcceptableOrUnknown(
          data['recurring_rule_id']!,
          _recurringRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at_us')) {
      context.handle(
        _createdAtUsMeta,
        createdAtUs.isAcceptableOrUnknown(
          data['created_at_us']!,
          _createdAtUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUsMeta);
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      type: $TransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      date: $TransactionsTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tags: $TransactionsTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      status: $TransactionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_id'],
      ),
      toAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_amount'],
      ),
      savingsGoalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}savings_goal_id'],
      ),
      recurringRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_rule_id'],
      ),
      recurrenceDate: $TransactionsTable.$converterrecurrenceDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence_date'],
        ),
      ),
      createdAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_us'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, String, String> $convertertype =
      const EnumNameConverter<TransactionType>(TransactionType.values);
  static TypeConverter<DateTime, String> $converterdate =
      const DateOnlyConverter();
  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
  static JsonTypeConverter2<TransactionStatus, String, String>
  $converterstatus = const EnumNameConverter<TransactionStatus>(
    TransactionStatus.values,
  );
  static TypeConverter<DateTime, String> $converterrecurrenceDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterrecurrenceDaten =
      NullAwareTypeConverter.wrap($converterrecurrenceDate);
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final int? version;
  final String id;
  final String accountId;
  final TransactionType type;
  final int amount;
  final String? categoryId;
  final DateTime date;
  final String? note;
  final List<String> tags;
  final TransactionStatus status;
  final String? toAccountId;
  final int? toAmount;
  final String? savingsGoalId;
  final String? recurringRuleId;
  final DateTime? recurrenceDate;

  /// Local creation order, used to sort operations of the same day.
  final int createdAtUs;

  /// Note and tags lowercased in Dart: SQLite's LOWER() only folds ASCII, so Cyrillic search needs this.
  final String searchText;
  const TransactionRow({
    this.version,
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    this.categoryId,
    required this.date,
    this.note,
    required this.tags,
    required this.status,
    this.toAccountId,
    this.toAmount,
    this.savingsGoalId,
    this.recurringRuleId,
    this.recurrenceDate,
    required this.createdAtUs,
    required this.searchText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type),
      );
    }
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    {
      map['date'] = Variable<String>(
        $TransactionsTable.$converterdate.toSql(date),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['tags'] = Variable<String>(
        $TransactionsTable.$convertertags.toSql(tags),
      );
    }
    {
      map['status'] = Variable<String>(
        $TransactionsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    if (!nullToAbsent || toAmount != null) {
      map['to_amount'] = Variable<int>(toAmount);
    }
    if (!nullToAbsent || savingsGoalId != null) {
      map['savings_goal_id'] = Variable<String>(savingsGoalId);
    }
    if (!nullToAbsent || recurringRuleId != null) {
      map['recurring_rule_id'] = Variable<String>(recurringRuleId);
    }
    if (!nullToAbsent || recurrenceDate != null) {
      map['recurrence_date'] = Variable<String>(
        $TransactionsTable.$converterrecurrenceDaten.toSql(recurrenceDate),
      );
    }
    map['created_at_us'] = Variable<int>(createdAtUs);
    map['search_text'] = Variable<String>(searchText);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      id: Value(id),
      accountId: Value(accountId),
      type: Value(type),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tags: Value(tags),
      status: Value(status),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      toAmount: toAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(toAmount),
      savingsGoalId: savingsGoalId == null && nullToAbsent
          ? const Value.absent()
          : Value(savingsGoalId),
      recurringRuleId: recurringRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRuleId),
      recurrenceDate: recurrenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceDate),
      createdAtUs: Value(createdAtUs),
      searchText: Value(searchText),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      version: serializer.fromJson<int?>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      type: $TransactionsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      amount: serializer.fromJson<int>(json['amount']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      status: $TransactionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      toAmount: serializer.fromJson<int?>(json['toAmount']),
      savingsGoalId: serializer.fromJson<String?>(json['savingsGoalId']),
      recurringRuleId: serializer.fromJson<String?>(json['recurringRuleId']),
      recurrenceDate: serializer.fromJson<DateTime?>(json['recurrenceDate']),
      createdAtUs: serializer.fromJson<int>(json['createdAtUs']),
      searchText: serializer.fromJson<String>(json['searchText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int?>(version),
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'type': serializer.toJson<String>(
        $TransactionsTable.$convertertype.toJson(type),
      ),
      'amount': serializer.toJson<int>(amount),
      'categoryId': serializer.toJson<String?>(categoryId),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'tags': serializer.toJson<List<String>>(tags),
      'status': serializer.toJson<String>(
        $TransactionsTable.$converterstatus.toJson(status),
      ),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'toAmount': serializer.toJson<int?>(toAmount),
      'savingsGoalId': serializer.toJson<String?>(savingsGoalId),
      'recurringRuleId': serializer.toJson<String?>(recurringRuleId),
      'recurrenceDate': serializer.toJson<DateTime?>(recurrenceDate),
      'createdAtUs': serializer.toJson<int>(createdAtUs),
      'searchText': serializer.toJson<String>(searchText),
    };
  }

  TransactionRow copyWith({
    Value<int?> version = const Value.absent(),
    String? id,
    String? accountId,
    TransactionType? type,
    int? amount,
    Value<String?> categoryId = const Value.absent(),
    DateTime? date,
    Value<String?> note = const Value.absent(),
    List<String>? tags,
    TransactionStatus? status,
    Value<String?> toAccountId = const Value.absent(),
    Value<int?> toAmount = const Value.absent(),
    Value<String?> savingsGoalId = const Value.absent(),
    Value<String?> recurringRuleId = const Value.absent(),
    Value<DateTime?> recurrenceDate = const Value.absent(),
    int? createdAtUs,
    String? searchText,
  }) => TransactionRow(
    version: version.present ? version.value : this.version,
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    tags: tags ?? this.tags,
    status: status ?? this.status,
    toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
    toAmount: toAmount.present ? toAmount.value : this.toAmount,
    savingsGoalId: savingsGoalId.present
        ? savingsGoalId.value
        : this.savingsGoalId,
    recurringRuleId: recurringRuleId.present
        ? recurringRuleId.value
        : this.recurringRuleId,
    recurrenceDate: recurrenceDate.present
        ? recurrenceDate.value
        : this.recurrenceDate,
    createdAtUs: createdAtUs ?? this.createdAtUs,
    searchText: searchText ?? this.searchText,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      tags: data.tags.present ? data.tags.value : this.tags,
      status: data.status.present ? data.status.value : this.status,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      toAmount: data.toAmount.present ? data.toAmount.value : this.toAmount,
      savingsGoalId: data.savingsGoalId.present
          ? data.savingsGoalId.value
          : this.savingsGoalId,
      recurringRuleId: data.recurringRuleId.present
          ? data.recurringRuleId.value
          : this.recurringRuleId,
      recurrenceDate: data.recurrenceDate.present
          ? data.recurrenceDate.value
          : this.recurrenceDate,
      createdAtUs: data.createdAtUs.present
          ? data.createdAtUs.value
          : this.createdAtUs,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('status: $status, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('toAmount: $toAmount, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('recurrenceDate: $recurrenceDate, ')
          ..write('createdAtUs: $createdAtUs, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    version,
    id,
    accountId,
    type,
    amount,
    categoryId,
    date,
    note,
    tags,
    status,
    toAccountId,
    toAmount,
    savingsGoalId,
    recurringRuleId,
    recurrenceDate,
    createdAtUs,
    searchText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.version == this.version &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.date == this.date &&
          other.note == this.note &&
          other.tags == this.tags &&
          other.status == this.status &&
          other.toAccountId == this.toAccountId &&
          other.toAmount == this.toAmount &&
          other.savingsGoalId == this.savingsGoalId &&
          other.recurringRuleId == this.recurringRuleId &&
          other.recurrenceDate == this.recurrenceDate &&
          other.createdAtUs == this.createdAtUs &&
          other.searchText == this.searchText);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<int?> version;
  final Value<String> id;
  final Value<String> accountId;
  final Value<TransactionType> type;
  final Value<int> amount;
  final Value<String?> categoryId;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<List<String>> tags;
  final Value<TransactionStatus> status;
  final Value<String?> toAccountId;
  final Value<int?> toAmount;
  final Value<String?> savingsGoalId;
  final Value<String?> recurringRuleId;
  final Value<DateTime?> recurrenceDate;
  final Value<int> createdAtUs;
  final Value<String> searchText;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.status = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.toAmount = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.recurrenceDate = const Value.absent(),
    this.createdAtUs = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.version = const Value.absent(),
    required String id,
    required String accountId,
    required TransactionType type,
    required int amount,
    this.categoryId = const Value.absent(),
    required DateTime date,
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    required TransactionStatus status,
    this.toAccountId = const Value.absent(),
    this.toAmount = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.recurrenceDate = const Value.absent(),
    required int createdAtUs,
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       type = Value(type),
       amount = Value(amount),
       date = Value(date),
       status = Value(status),
       createdAtUs = Value(createdAtUs);
  static Insertable<TransactionRow> custom({
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? categoryId,
    Expression<String>? date,
    Expression<String>? note,
    Expression<String>? tags,
    Expression<String>? status,
    Expression<String>? toAccountId,
    Expression<int>? toAmount,
    Expression<String>? savingsGoalId,
    Expression<String>? recurringRuleId,
    Expression<String>? recurrenceDate,
    Expression<int>? createdAtUs,
    Expression<String>? searchText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (tags != null) 'tags': tags,
      if (status != null) 'status': status,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (toAmount != null) 'to_amount': toAmount,
      if (savingsGoalId != null) 'savings_goal_id': savingsGoalId,
      if (recurringRuleId != null) 'recurring_rule_id': recurringRuleId,
      if (recurrenceDate != null) 'recurrence_date': recurrenceDate,
      if (createdAtUs != null) 'created_at_us': createdAtUs,
      if (searchText != null) 'search_text': searchText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<int?>? version,
    Value<String>? id,
    Value<String>? accountId,
    Value<TransactionType>? type,
    Value<int>? amount,
    Value<String?>? categoryId,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<List<String>>? tags,
    Value<TransactionStatus>? status,
    Value<String?>? toAccountId,
    Value<int?>? toAmount,
    Value<String?>? savingsGoalId,
    Value<String?>? recurringRuleId,
    Value<DateTime?>? recurrenceDate,
    Value<int>? createdAtUs,
    Value<String>? searchText,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      version: version ?? this.version,
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      toAccountId: toAccountId ?? this.toAccountId,
      toAmount: toAmount ?? this.toAmount,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      recurrenceDate: recurrenceDate ?? this.recurrenceDate,
      createdAtUs: createdAtUs ?? this.createdAtUs,
      searchText: searchText ?? this.searchText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $TransactionsTable.$converterdate.toSql(date.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $TransactionsTable.$convertertags.toSql(tags.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TransactionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (toAmount.present) {
      map['to_amount'] = Variable<int>(toAmount.value);
    }
    if (savingsGoalId.present) {
      map['savings_goal_id'] = Variable<String>(savingsGoalId.value);
    }
    if (recurringRuleId.present) {
      map['recurring_rule_id'] = Variable<String>(recurringRuleId.value);
    }
    if (recurrenceDate.present) {
      map['recurrence_date'] = Variable<String>(
        $TransactionsTable.$converterrecurrenceDaten.toSql(
          recurrenceDate.value,
        ),
      );
    }
    if (createdAtUs.present) {
      map['created_at_us'] = Variable<int>(createdAtUs.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('status: $status, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('toAmount: $toAmount, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('recurrenceDate: $recurrenceDate, ')
          ..write('createdAtUs: $createdAtUs, ')
          ..write('searchText: $searchText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionType>($RecurringRulesTable.$convertertype);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($RecurringRulesTable.$convertertags);
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
    'to_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toAmountMeta = const VerificationMeta(
    'toAmount',
  );
  @override
  late final GeneratedColumn<int> toAmount = GeneratedColumn<int>(
    'to_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savingsGoalIdMeta = const VerificationMeta(
    'savingsGoalId',
  );
  @override
  late final GeneratedColumn<String> savingsGoalId = GeneratedColumn<String>(
    'savings_goal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Frequency, String> frequency =
      GeneratedColumn<String>(
        'frequency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Frequency>($RecurringRulesTable.$converterfrequency);
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<String> dayOfWeek = GeneratedColumn<String>(
    'day_of_week',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RecurringRulesTable.$converterstartDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> endDate =
      GeneratedColumn<String>(
        'end_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RecurringRulesTable.$converterendDaten);
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    version,
    id,
    name,
    accountId,
    type,
    amount,
    categoryId,
    note,
    tags,
    toAccountId,
    toAmount,
    savingsGoalId,
    frequency,
    interval,
    dayOfMonth,
    dayOfWeek,
    startDate,
    endDate,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('to_amount')) {
      context.handle(
        _toAmountMeta,
        toAmount.isAcceptableOrUnknown(data['to_amount']!, _toAmountMeta),
      );
    }
    if (data.containsKey('savings_goal_id')) {
      context.handle(
        _savingsGoalIdMeta,
        savingsGoalId.isAcceptableOrUnknown(
          data['savings_goal_id']!,
          _savingsGoalIdMeta,
        ),
      );
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRuleRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      type: $RecurringRulesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tags: $RecurringRulesTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_id'],
      ),
      toAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_amount'],
      ),
      savingsGoalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}savings_goal_id'],
      ),
      frequency: $RecurringRulesTable.$converterfrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}frequency'],
        )!,
      ),
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      ),
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_of_week'],
      ),
      startDate: $RecurringRulesTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      endDate: $RecurringRulesTable.$converterendDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_date'],
        ),
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, String, String> $convertertype =
      const EnumNameConverter<TransactionType>(TransactionType.values);
  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
  static JsonTypeConverter2<Frequency, String, String> $converterfrequency =
      const EnumNameConverter<Frequency>(Frequency.values);
  static TypeConverter<DateTime, String> $converterstartDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime, String> $converterendDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterendDaten =
      NullAwareTypeConverter.wrap($converterendDate);
}

class RecurringRuleRow extends DataClass
    implements Insertable<RecurringRuleRow> {
  final int? version;
  final String id;
  final String name;
  final String accountId;
  final TransactionType type;
  final int amount;
  final String? categoryId;
  final String? note;
  final List<String> tags;
  final String? toAccountId;
  final int? toAmount;
  final String? savingsGoalId;
  final Frequency frequency;
  final int interval;
  final int? dayOfMonth;

  /// Server name of the weekday ("Monday").
  final String? dayOfWeek;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  const RecurringRuleRow({
    this.version,
    required this.id,
    required this.name,
    required this.accountId,
    required this.type,
    required this.amount,
    this.categoryId,
    this.note,
    required this.tags,
    this.toAccountId,
    this.toAmount,
    this.savingsGoalId,
    required this.frequency,
    required this.interval,
    this.dayOfMonth,
    this.dayOfWeek,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['account_id'] = Variable<String>(accountId);
    {
      map['type'] = Variable<String>(
        $RecurringRulesTable.$convertertype.toSql(type),
      );
    }
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['tags'] = Variable<String>(
        $RecurringRulesTable.$convertertags.toSql(tags),
      );
    }
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    if (!nullToAbsent || toAmount != null) {
      map['to_amount'] = Variable<int>(toAmount);
    }
    if (!nullToAbsent || savingsGoalId != null) {
      map['savings_goal_id'] = Variable<String>(savingsGoalId);
    }
    {
      map['frequency'] = Variable<String>(
        $RecurringRulesTable.$converterfrequency.toSql(frequency),
      );
    }
    map['interval'] = Variable<int>(interval);
    if (!nullToAbsent || dayOfMonth != null) {
      map['day_of_month'] = Variable<int>(dayOfMonth);
    }
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<String>(dayOfWeek);
    }
    {
      map['start_date'] = Variable<String>(
        $RecurringRulesTable.$converterstartDate.toSql(startDate),
      );
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(
        $RecurringRulesTable.$converterendDaten.toSql(endDate),
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      id: Value(id),
      name: Value(name),
      accountId: Value(accountId),
      type: Value(type),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tags: Value(tags),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      toAmount: toAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(toAmount),
      savingsGoalId: savingsGoalId == null && nullToAbsent
          ? const Value.absent()
          : Value(savingsGoalId),
      frequency: Value(frequency),
      interval: Value(interval),
      dayOfMonth: dayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfMonth),
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
    );
  }

  factory RecurringRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRuleRow(
      version: serializer.fromJson<int?>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accountId: serializer.fromJson<String>(json['accountId']),
      type: $RecurringRulesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      amount: serializer.fromJson<int>(json['amount']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      note: serializer.fromJson<String?>(json['note']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      toAmount: serializer.fromJson<int?>(json['toAmount']),
      savingsGoalId: serializer.fromJson<String?>(json['savingsGoalId']),
      frequency: $RecurringRulesTable.$converterfrequency.fromJson(
        serializer.fromJson<String>(json['frequency']),
      ),
      interval: serializer.fromJson<int>(json['interval']),
      dayOfMonth: serializer.fromJson<int?>(json['dayOfMonth']),
      dayOfWeek: serializer.fromJson<String?>(json['dayOfWeek']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int?>(version),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'accountId': serializer.toJson<String>(accountId),
      'type': serializer.toJson<String>(
        $RecurringRulesTable.$convertertype.toJson(type),
      ),
      'amount': serializer.toJson<int>(amount),
      'categoryId': serializer.toJson<String?>(categoryId),
      'note': serializer.toJson<String?>(note),
      'tags': serializer.toJson<List<String>>(tags),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'toAmount': serializer.toJson<int?>(toAmount),
      'savingsGoalId': serializer.toJson<String?>(savingsGoalId),
      'frequency': serializer.toJson<String>(
        $RecurringRulesTable.$converterfrequency.toJson(frequency),
      ),
      'interval': serializer.toJson<int>(interval),
      'dayOfMonth': serializer.toJson<int?>(dayOfMonth),
      'dayOfWeek': serializer.toJson<String?>(dayOfWeek),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  RecurringRuleRow copyWith({
    Value<int?> version = const Value.absent(),
    String? id,
    String? name,
    String? accountId,
    TransactionType? type,
    int? amount,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    List<String>? tags,
    Value<String?> toAccountId = const Value.absent(),
    Value<int?> toAmount = const Value.absent(),
    Value<String?> savingsGoalId = const Value.absent(),
    Frequency? frequency,
    int? interval,
    Value<int?> dayOfMonth = const Value.absent(),
    Value<String?> dayOfWeek = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? isActive,
  }) => RecurringRuleRow(
    version: version.present ? version.value : this.version,
    id: id ?? this.id,
    name: name ?? this.name,
    accountId: accountId ?? this.accountId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    note: note.present ? note.value : this.note,
    tags: tags ?? this.tags,
    toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
    toAmount: toAmount.present ? toAmount.value : this.toAmount,
    savingsGoalId: savingsGoalId.present
        ? savingsGoalId.value
        : this.savingsGoalId,
    frequency: frequency ?? this.frequency,
    interval: interval ?? this.interval,
    dayOfMonth: dayOfMonth.present ? dayOfMonth.value : this.dayOfMonth,
    dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
  );
  RecurringRuleRow copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRuleRow(
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      tags: data.tags.present ? data.tags.value : this.tags,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      toAmount: data.toAmount.present ? data.toAmount.value : this.toAmount,
      savingsGoalId: data.savingsGoalId.present
          ? data.savingsGoalId.value
          : this.savingsGoalId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      interval: data.interval.present ? data.interval.value : this.interval,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRuleRow(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('toAmount: $toAmount, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    version,
    id,
    name,
    accountId,
    type,
    amount,
    categoryId,
    note,
    tags,
    toAccountId,
    toAmount,
    savingsGoalId,
    frequency,
    interval,
    dayOfMonth,
    dayOfWeek,
    startDate,
    endDate,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRuleRow &&
          other.version == this.version &&
          other.id == this.id &&
          other.name == this.name &&
          other.accountId == this.accountId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.tags == this.tags &&
          other.toAccountId == this.toAccountId &&
          other.toAmount == this.toAmount &&
          other.savingsGoalId == this.savingsGoalId &&
          other.frequency == this.frequency &&
          other.interval == this.interval &&
          other.dayOfMonth == this.dayOfMonth &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRuleRow> {
  final Value<int?> version;
  final Value<String> id;
  final Value<String> name;
  final Value<String> accountId;
  final Value<TransactionType> type;
  final Value<int> amount;
  final Value<String?> categoryId;
  final Value<String?> note;
  final Value<List<String>> tags;
  final Value<String?> toAccountId;
  final Value<int?> toAmount;
  final Value<String?> savingsGoalId;
  final Value<Frequency> frequency;
  final Value<int> interval;
  final Value<int?> dayOfMonth;
  final Value<String?> dayOfWeek;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isActive;
  final Value<int> rowid;
  const RecurringRulesCompanion({
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accountId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.toAmount = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    this.version = const Value.absent(),
    required String id,
    required String name,
    required String accountId,
    required TransactionType type,
    required int amount,
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.toAmount = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    required Frequency frequency,
    this.interval = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       accountId = Value(accountId),
       type = Value(type),
       amount = Value(amount),
       frequency = Value(frequency),
       startDate = Value(startDate);
  static Insertable<RecurringRuleRow> custom({
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? accountId,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<String>? tags,
    Expression<String>? toAccountId,
    Expression<int>? toAmount,
    Expression<String>? savingsGoalId,
    Expression<String>? frequency,
    Expression<int>? interval,
    Expression<int>? dayOfMonth,
    Expression<String>? dayOfWeek,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accountId != null) 'account_id': accountId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (tags != null) 'tags': tags,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (toAmount != null) 'to_amount': toAmount,
      if (savingsGoalId != null) 'savings_goal_id': savingsGoalId,
      if (frequency != null) 'frequency': frequency,
      if (interval != null) 'interval': interval,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<int?>? version,
    Value<String>? id,
    Value<String>? name,
    Value<String>? accountId,
    Value<TransactionType>? type,
    Value<int>? amount,
    Value<String?>? categoryId,
    Value<String?>? note,
    Value<List<String>>? tags,
    Value<String?>? toAccountId,
    Value<int?>? toAmount,
    Value<String?>? savingsGoalId,
    Value<Frequency>? frequency,
    Value<int>? interval,
    Value<int?>? dayOfMonth,
    Value<String?>? dayOfWeek,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return RecurringRulesCompanion(
      version: version ?? this.version,
      id: id ?? this.id,
      name: name ?? this.name,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      toAccountId: toAccountId ?? this.toAccountId,
      toAmount: toAmount ?? this.toAmount,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $RecurringRulesTable.$convertertype.toSql(type.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $RecurringRulesTable.$convertertags.toSql(tags.value),
      );
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (toAmount.present) {
      map['to_amount'] = Variable<int>(toAmount.value);
    }
    if (savingsGoalId.present) {
      map['savings_goal_id'] = Variable<String>(savingsGoalId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(
        $RecurringRulesTable.$converterfrequency.toSql(frequency.value),
      );
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<String>(dayOfWeek.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $RecurringRulesTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(
        $RecurringRulesTable.$converterendDaten.toSql(endDate.value),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('toAmount: $toAmount, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedIncomeMeta = const VerificationMeta(
    'expectedIncome',
  );
  @override
  late final GeneratedColumn<int> expectedIncome = GeneratedColumn<int>(
    'expected_income',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    version,
    id,
    month,
    currency,
    expectedIncome,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('expected_income')) {
      context.handle(
        _expectedIncomeMeta,
        expectedIncome.isAcceptableOrUnknown(
          data['expected_income']!,
          _expectedIncomeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      expectedIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_income'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class BudgetRow extends DataClass implements Insertable<BudgetRow> {
  final int? version;
  final String id;

  /// yyyy-MM of the financial month.
  final String month;
  final String currency;
  final int expectedIncome;
  const BudgetRow({
    this.version,
    required this.id,
    required this.month,
    required this.currency,
    required this.expectedIncome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['id'] = Variable<String>(id);
    map['month'] = Variable<String>(month);
    map['currency'] = Variable<String>(currency);
    map['expected_income'] = Variable<int>(expectedIncome);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      id: Value(id),
      month: Value(month),
      currency: Value(currency),
      expectedIncome: Value(expectedIncome),
    );
  }

  factory BudgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      version: serializer.fromJson<int?>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      month: serializer.fromJson<String>(json['month']),
      currency: serializer.fromJson<String>(json['currency']),
      expectedIncome: serializer.fromJson<int>(json['expectedIncome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int?>(version),
      'id': serializer.toJson<String>(id),
      'month': serializer.toJson<String>(month),
      'currency': serializer.toJson<String>(currency),
      'expectedIncome': serializer.toJson<int>(expectedIncome),
    };
  }

  BudgetRow copyWith({
    Value<int?> version = const Value.absent(),
    String? id,
    String? month,
    String? currency,
    int? expectedIncome,
  }) => BudgetRow(
    version: version.present ? version.value : this.version,
    id: id ?? this.id,
    month: month ?? this.month,
    currency: currency ?? this.currency,
    expectedIncome: expectedIncome ?? this.expectedIncome,
  );
  BudgetRow copyWithCompanion(BudgetsCompanion data) {
    return BudgetRow(
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      month: data.month.present ? data.month.value : this.month,
      currency: data.currency.present ? data.currency.value : this.currency,
      expectedIncome: data.expectedIncome.present
          ? data.expectedIncome.value
          : this.expectedIncome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('month: $month, ')
          ..write('currency: $currency, ')
          ..write('expectedIncome: $expectedIncome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(version, id, month, currency, expectedIncome);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.version == this.version &&
          other.id == this.id &&
          other.month == this.month &&
          other.currency == this.currency &&
          other.expectedIncome == this.expectedIncome);
}

class BudgetsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<int?> version;
  final Value<String> id;
  final Value<String> month;
  final Value<String> currency;
  final Value<int> expectedIncome;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.month = const Value.absent(),
    this.currency = const Value.absent(),
    this.expectedIncome = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.version = const Value.absent(),
    required String id,
    required String month,
    required String currency,
    this.expectedIncome = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       month = Value(month),
       currency = Value(currency);
  static Insertable<BudgetRow> custom({
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? month,
    Expression<String>? currency,
    Expression<int>? expectedIncome,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (month != null) 'month': month,
      if (currency != null) 'currency': currency,
      if (expectedIncome != null) 'expected_income': expectedIncome,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<int?>? version,
    Value<String>? id,
    Value<String>? month,
    Value<String>? currency,
    Value<int>? expectedIncome,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      version: version ?? this.version,
      id: id ?? this.id,
      month: month ?? this.month,
      currency: currency ?? this.currency,
      expectedIncome: expectedIncome ?? this.expectedIncome,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (expectedIncome.present) {
      map['expected_income'] = Variable<int>(expectedIncome.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('month: $month, ')
          ..write('currency: $currency, ')
          ..write('expectedIncome: $expectedIncome, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetLinesTable extends BudgetLines
    with TableInfo<$BudgetLinesTable, BudgetLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedAmountMeta = const VerificationMeta(
    'plannedAmount',
  );
  @override
  late final GeneratedColumn<int> plannedAmount = GeneratedColumn<int>(
    'planned_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rolloverMeta = const VerificationMeta(
    'rollover',
  );
  @override
  late final GeneratedColumn<bool> rollover = GeneratedColumn<bool>(
    'rollover',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rollover" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    version,
    id,
    budgetId,
    categoryId,
    plannedAmount,
    rollover,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('planned_amount')) {
      context.handle(
        _plannedAmountMeta,
        plannedAmount.isAcceptableOrUnknown(
          data['planned_amount']!,
          _plannedAmountMeta,
        ),
      );
    }
    if (data.containsKey('rollover')) {
      context.handle(
        _rolloverMeta,
        rollover.isAcceptableOrUnknown(data['rollover']!, _rolloverMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetLineRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      plannedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_amount'],
      )!,
      rollover: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rollover'],
      )!,
    );
  }

  @override
  $BudgetLinesTable createAlias(String alias) {
    return $BudgetLinesTable(attachedDatabase, alias);
  }
}

class BudgetLineRow extends DataClass implements Insertable<BudgetLineRow> {
  final int? version;
  final String id;
  final String budgetId;
  final String categoryId;
  final int plannedAmount;
  final bool rollover;
  const BudgetLineRow({
    this.version,
    required this.id,
    required this.budgetId,
    required this.categoryId,
    required this.plannedAmount,
    required this.rollover,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['id'] = Variable<String>(id);
    map['budget_id'] = Variable<String>(budgetId);
    map['category_id'] = Variable<String>(categoryId);
    map['planned_amount'] = Variable<int>(plannedAmount);
    map['rollover'] = Variable<bool>(rollover);
    return map;
  }

  BudgetLinesCompanion toCompanion(bool nullToAbsent) {
    return BudgetLinesCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      id: Value(id),
      budgetId: Value(budgetId),
      categoryId: Value(categoryId),
      plannedAmount: Value(plannedAmount),
      rollover: Value(rollover),
    );
  }

  factory BudgetLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetLineRow(
      version: serializer.fromJson<int?>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      budgetId: serializer.fromJson<String>(json['budgetId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      plannedAmount: serializer.fromJson<int>(json['plannedAmount']),
      rollover: serializer.fromJson<bool>(json['rollover']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int?>(version),
      'id': serializer.toJson<String>(id),
      'budgetId': serializer.toJson<String>(budgetId),
      'categoryId': serializer.toJson<String>(categoryId),
      'plannedAmount': serializer.toJson<int>(plannedAmount),
      'rollover': serializer.toJson<bool>(rollover),
    };
  }

  BudgetLineRow copyWith({
    Value<int?> version = const Value.absent(),
    String? id,
    String? budgetId,
    String? categoryId,
    int? plannedAmount,
    bool? rollover,
  }) => BudgetLineRow(
    version: version.present ? version.value : this.version,
    id: id ?? this.id,
    budgetId: budgetId ?? this.budgetId,
    categoryId: categoryId ?? this.categoryId,
    plannedAmount: plannedAmount ?? this.plannedAmount,
    rollover: rollover ?? this.rollover,
  );
  BudgetLineRow copyWithCompanion(BudgetLinesCompanion data) {
    return BudgetLineRow(
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      plannedAmount: data.plannedAmount.present
          ? data.plannedAmount.value
          : this.plannedAmount,
      rollover: data.rollover.present ? data.rollover.value : this.rollover,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetLineRow(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('plannedAmount: $plannedAmount, ')
          ..write('rollover: $rollover')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(version, id, budgetId, categoryId, plannedAmount, rollover);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetLineRow &&
          other.version == this.version &&
          other.id == this.id &&
          other.budgetId == this.budgetId &&
          other.categoryId == this.categoryId &&
          other.plannedAmount == this.plannedAmount &&
          other.rollover == this.rollover);
}

class BudgetLinesCompanion extends UpdateCompanion<BudgetLineRow> {
  final Value<int?> version;
  final Value<String> id;
  final Value<String> budgetId;
  final Value<String> categoryId;
  final Value<int> plannedAmount;
  final Value<bool> rollover;
  final Value<int> rowid;
  const BudgetLinesCompanion({
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.plannedAmount = const Value.absent(),
    this.rollover = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetLinesCompanion.insert({
    this.version = const Value.absent(),
    required String id,
    required String budgetId,
    required String categoryId,
    this.plannedAmount = const Value.absent(),
    this.rollover = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       budgetId = Value(budgetId),
       categoryId = Value(categoryId);
  static Insertable<BudgetLineRow> custom({
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? budgetId,
    Expression<String>? categoryId,
    Expression<int>? plannedAmount,
    Expression<bool>? rollover,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (budgetId != null) 'budget_id': budgetId,
      if (categoryId != null) 'category_id': categoryId,
      if (plannedAmount != null) 'planned_amount': plannedAmount,
      if (rollover != null) 'rollover': rollover,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetLinesCompanion copyWith({
    Value<int?>? version,
    Value<String>? id,
    Value<String>? budgetId,
    Value<String>? categoryId,
    Value<int>? plannedAmount,
    Value<bool>? rollover,
    Value<int>? rowid,
  }) {
    return BudgetLinesCompanion(
      version: version ?? this.version,
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      rollover: rollover ?? this.rollover,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (plannedAmount.present) {
      map['planned_amount'] = Variable<int>(plannedAmount.value);
    }
    if (rollover.present) {
      map['rollover'] = Variable<bool>(rollover.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetLinesCompanion(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('plannedAmount: $plannedAmount, ')
          ..write('rollover: $rollover, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetGoalAllocationsTable extends BudgetGoalAllocations
    with TableInfo<$BudgetGoalAllocationsTable, BudgetAllocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetGoalAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savingsGoalIdMeta = const VerificationMeta(
    'savingsGoalId',
  );
  @override
  late final GeneratedColumn<String> savingsGoalId = GeneratedColumn<String>(
    'savings_goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedAmountMeta = const VerificationMeta(
    'plannedAmount',
  );
  @override
  late final GeneratedColumn<int> plannedAmount = GeneratedColumn<int>(
    'planned_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    version,
    id,
    budgetId,
    savingsGoalId,
    plannedAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_goal_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetAllocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('savings_goal_id')) {
      context.handle(
        _savingsGoalIdMeta,
        savingsGoalId.isAcceptableOrUnknown(
          data['savings_goal_id']!,
          _savingsGoalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savingsGoalIdMeta);
    }
    if (data.containsKey('planned_amount')) {
      context.handle(
        _plannedAmountMeta,
        plannedAmount.isAcceptableOrUnknown(
          data['planned_amount']!,
          _plannedAmountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetAllocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetAllocationRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      savingsGoalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}savings_goal_id'],
      )!,
      plannedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_amount'],
      )!,
    );
  }

  @override
  $BudgetGoalAllocationsTable createAlias(String alias) {
    return $BudgetGoalAllocationsTable(attachedDatabase, alias);
  }
}

class BudgetAllocationRow extends DataClass
    implements Insertable<BudgetAllocationRow> {
  final int? version;
  final String id;
  final String budgetId;
  final String savingsGoalId;
  final int plannedAmount;
  const BudgetAllocationRow({
    this.version,
    required this.id,
    required this.budgetId,
    required this.savingsGoalId,
    required this.plannedAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['id'] = Variable<String>(id);
    map['budget_id'] = Variable<String>(budgetId);
    map['savings_goal_id'] = Variable<String>(savingsGoalId);
    map['planned_amount'] = Variable<int>(plannedAmount);
    return map;
  }

  BudgetGoalAllocationsCompanion toCompanion(bool nullToAbsent) {
    return BudgetGoalAllocationsCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      id: Value(id),
      budgetId: Value(budgetId),
      savingsGoalId: Value(savingsGoalId),
      plannedAmount: Value(plannedAmount),
    );
  }

  factory BudgetAllocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetAllocationRow(
      version: serializer.fromJson<int?>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      budgetId: serializer.fromJson<String>(json['budgetId']),
      savingsGoalId: serializer.fromJson<String>(json['savingsGoalId']),
      plannedAmount: serializer.fromJson<int>(json['plannedAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int?>(version),
      'id': serializer.toJson<String>(id),
      'budgetId': serializer.toJson<String>(budgetId),
      'savingsGoalId': serializer.toJson<String>(savingsGoalId),
      'plannedAmount': serializer.toJson<int>(plannedAmount),
    };
  }

  BudgetAllocationRow copyWith({
    Value<int?> version = const Value.absent(),
    String? id,
    String? budgetId,
    String? savingsGoalId,
    int? plannedAmount,
  }) => BudgetAllocationRow(
    version: version.present ? version.value : this.version,
    id: id ?? this.id,
    budgetId: budgetId ?? this.budgetId,
    savingsGoalId: savingsGoalId ?? this.savingsGoalId,
    plannedAmount: plannedAmount ?? this.plannedAmount,
  );
  BudgetAllocationRow copyWithCompanion(BudgetGoalAllocationsCompanion data) {
    return BudgetAllocationRow(
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      savingsGoalId: data.savingsGoalId.present
          ? data.savingsGoalId.value
          : this.savingsGoalId,
      plannedAmount: data.plannedAmount.present
          ? data.plannedAmount.value
          : this.plannedAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetAllocationRow(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('plannedAmount: $plannedAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(version, id, budgetId, savingsGoalId, plannedAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetAllocationRow &&
          other.version == this.version &&
          other.id == this.id &&
          other.budgetId == this.budgetId &&
          other.savingsGoalId == this.savingsGoalId &&
          other.plannedAmount == this.plannedAmount);
}

class BudgetGoalAllocationsCompanion
    extends UpdateCompanion<BudgetAllocationRow> {
  final Value<int?> version;
  final Value<String> id;
  final Value<String> budgetId;
  final Value<String> savingsGoalId;
  final Value<int> plannedAmount;
  final Value<int> rowid;
  const BudgetGoalAllocationsCompanion({
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    this.plannedAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetGoalAllocationsCompanion.insert({
    this.version = const Value.absent(),
    required String id,
    required String budgetId,
    required String savingsGoalId,
    this.plannedAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       budgetId = Value(budgetId),
       savingsGoalId = Value(savingsGoalId);
  static Insertable<BudgetAllocationRow> custom({
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? budgetId,
    Expression<String>? savingsGoalId,
    Expression<int>? plannedAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (budgetId != null) 'budget_id': budgetId,
      if (savingsGoalId != null) 'savings_goal_id': savingsGoalId,
      if (plannedAmount != null) 'planned_amount': plannedAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetGoalAllocationsCompanion copyWith({
    Value<int?>? version,
    Value<String>? id,
    Value<String>? budgetId,
    Value<String>? savingsGoalId,
    Value<int>? plannedAmount,
    Value<int>? rowid,
  }) {
    return BudgetGoalAllocationsCompanion(
      version: version ?? this.version,
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (savingsGoalId.present) {
      map['savings_goal_id'] = Variable<String>(savingsGoalId.value);
    }
    if (plannedAmount.present) {
      map['planned_amount'] = Variable<int>(plannedAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetGoalAllocationsCompanion(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('plannedAmount: $plannedAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, SavingsGoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> targetDate =
      GeneratedColumn<String>(
        'target_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SavingsGoalsTable.$convertertargetDaten);
  static const VerificationMeta _linkedAccountIdMeta = const VerificationMeta(
    'linkedAccountId',
  );
  @override
  late final GeneratedColumn<String> linkedAccountId = GeneratedColumn<String>(
    'linked_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> completedOn =
      GeneratedColumn<String>(
        'completed_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SavingsGoalsTable.$convertercompletedOnn);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    version,
    id,
    name,
    targetAmount,
    currency,
    targetDate,
    linkedAccountId,
    priority,
    isCompleted,
    completedOn,
    color,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('linked_account_id')) {
      context.handle(
        _linkedAccountIdMeta,
        linkedAccountId.isAcceptableOrUnknown(
          data['linked_account_id']!,
          _linkedAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoalRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      targetDate: $SavingsGoalsTable.$convertertargetDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}target_date'],
        ),
      ),
      linkedAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_account_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedOn: $SavingsGoalsTable.$convertercompletedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}completed_on'],
        ),
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertertargetDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $convertertargetDaten =
      NullAwareTypeConverter.wrap($convertertargetDate);
  static TypeConverter<DateTime, String> $convertercompletedOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $convertercompletedOnn =
      NullAwareTypeConverter.wrap($convertercompletedOn);
}

class SavingsGoalRow extends DataClass implements Insertable<SavingsGoalRow> {
  final int? version;
  final String id;
  final String name;
  final int targetAmount;
  final String currency;
  final DateTime? targetDate;
  final String? linkedAccountId;
  final int priority;
  final bool isCompleted;
  final DateTime? completedOn;
  final String? color;
  final String? icon;
  const SavingsGoalRow({
    this.version,
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currency,
    this.targetDate,
    this.linkedAccountId,
    required this.priority,
    required this.isCompleted,
    this.completedOn,
    this.color,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<int>(targetAmount);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(
        $SavingsGoalsTable.$convertertargetDaten.toSql(targetDate),
      );
    }
    if (!nullToAbsent || linkedAccountId != null) {
      map['linked_account_id'] = Variable<String>(linkedAccountId);
    }
    map['priority'] = Variable<int>(priority);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedOn != null) {
      map['completed_on'] = Variable<String>(
        $SavingsGoalsTable.$convertercompletedOnn.toSql(completedOn),
      );
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      id: Value(id),
      name: Value(name),
      targetAmount: Value(targetAmount),
      currency: Value(currency),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      linkedAccountId: linkedAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAccountId),
      priority: Value(priority),
      isCompleted: Value(isCompleted),
      completedOn: completedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(completedOn),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory SavingsGoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoalRow(
      version: serializer.fromJson<int?>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      currency: serializer.fromJson<String>(json['currency']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      linkedAccountId: serializer.fromJson<String?>(json['linkedAccountId']),
      priority: serializer.fromJson<int>(json['priority']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedOn: serializer.fromJson<DateTime?>(json['completedOn']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int?>(version),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'currency': serializer.toJson<String>(currency),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'linkedAccountId': serializer.toJson<String?>(linkedAccountId),
      'priority': serializer.toJson<int>(priority),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedOn': serializer.toJson<DateTime?>(completedOn),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  SavingsGoalRow copyWith({
    Value<int?> version = const Value.absent(),
    String? id,
    String? name,
    int? targetAmount,
    String? currency,
    Value<DateTime?> targetDate = const Value.absent(),
    Value<String?> linkedAccountId = const Value.absent(),
    int? priority,
    bool? isCompleted,
    Value<DateTime?> completedOn = const Value.absent(),
    Value<String?> color = const Value.absent(),
    Value<String?> icon = const Value.absent(),
  }) => SavingsGoalRow(
    version: version.present ? version.value : this.version,
    id: id ?? this.id,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    currency: currency ?? this.currency,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    linkedAccountId: linkedAccountId.present
        ? linkedAccountId.value
        : this.linkedAccountId,
    priority: priority ?? this.priority,
    isCompleted: isCompleted ?? this.isCompleted,
    completedOn: completedOn.present ? completedOn.value : this.completedOn,
    color: color.present ? color.value : this.color,
    icon: icon.present ? icon.value : this.icon,
  );
  SavingsGoalRow copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoalRow(
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      linkedAccountId: data.linkedAccountId.present
          ? data.linkedAccountId.value
          : this.linkedAccountId,
      priority: data.priority.present ? data.priority.value : this.priority,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedOn: data.completedOn.present
          ? data.completedOn.value
          : this.completedOn,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalRow(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currency: $currency, ')
          ..write('targetDate: $targetDate, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('priority: $priority, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedOn: $completedOn, ')
          ..write('color: $color, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    version,
    id,
    name,
    targetAmount,
    currency,
    targetDate,
    linkedAccountId,
    priority,
    isCompleted,
    completedOn,
    color,
    icon,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoalRow &&
          other.version == this.version &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.currency == this.currency &&
          other.targetDate == this.targetDate &&
          other.linkedAccountId == this.linkedAccountId &&
          other.priority == this.priority &&
          other.isCompleted == this.isCompleted &&
          other.completedOn == this.completedOn &&
          other.color == this.color &&
          other.icon == this.icon);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoalRow> {
  final Value<int?> version;
  final Value<String> id;
  final Value<String> name;
  final Value<int> targetAmount;
  final Value<String> currency;
  final Value<DateTime?> targetDate;
  final Value<String?> linkedAccountId;
  final Value<int> priority;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedOn;
  final Value<String?> color;
  final Value<String?> icon;
  final Value<int> rowid;
  const SavingsGoalsCompanion({
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    this.priority = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedOn = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    this.version = const Value.absent(),
    required String id,
    required String name,
    required int targetAmount,
    required String currency,
    this.targetDate = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    this.priority = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedOn = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       targetAmount = Value(targetAmount),
       currency = Value(currency);
  static Insertable<SavingsGoalRow> custom({
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? targetAmount,
    Expression<String>? currency,
    Expression<String>? targetDate,
    Expression<String>? linkedAccountId,
    Expression<int>? priority,
    Expression<bool>? isCompleted,
    Expression<String>? completedOn,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currency != null) 'currency': currency,
      if (targetDate != null) 'target_date': targetDate,
      if (linkedAccountId != null) 'linked_account_id': linkedAccountId,
      if (priority != null) 'priority': priority,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedOn != null) 'completed_on': completedOn,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsCompanion copyWith({
    Value<int?>? version,
    Value<String>? id,
    Value<String>? name,
    Value<int>? targetAmount,
    Value<String>? currency,
    Value<DateTime?>? targetDate,
    Value<String?>? linkedAccountId,
    Value<int>? priority,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedOn,
    Value<String?>? color,
    Value<String?>? icon,
    Value<int>? rowid,
  }) {
    return SavingsGoalsCompanion(
      version: version ?? this.version,
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedOn: completedOn ?? this.completedOn,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(
        $SavingsGoalsTable.$convertertargetDaten.toSql(targetDate.value),
      );
    }
    if (linkedAccountId.present) {
      map['linked_account_id'] = Variable<String>(linkedAccountId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedOn.present) {
      map['completed_on'] = Variable<String>(
        $SavingsGoalsTable.$convertercompletedOnn.toSql(completedOn.value),
      );
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currency: $currency, ')
          ..write('targetDate: $targetDate, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('priority: $priority, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedOn: $completedOn, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BYN'),
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Europe/Minsk'),
  );
  static const VerificationMeta _firstDayOfMonthMeta = const VerificationMeta(
    'firstDayOfMonth',
  );
  @override
  late final GeneratedColumn<int> firstDayOfMonth = GeneratedColumn<int>(
    'first_day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _defaultSpendingAccountIdMeta =
      const VerificationMeta('defaultSpendingAccountId');
  @override
  late final GeneratedColumn<String> defaultSpendingAccountId =
      GeneratedColumn<String>(
        'default_spending_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lowBalanceThresholdMeta =
      const VerificationMeta('lowBalanceThreshold');
  @override
  late final GeneratedColumn<int> lowBalanceThreshold = GeneratedColumn<int>(
    'low_balance_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    version,
    id,
    email,
    baseCurrency,
    timezone,
    firstDayOfMonth,
    defaultSpendingAccountId,
    lowBalanceThreshold,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('first_day_of_month')) {
      context.handle(
        _firstDayOfMonthMeta,
        firstDayOfMonth.isAcceptableOrUnknown(
          data['first_day_of_month']!,
          _firstDayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('default_spending_account_id')) {
      context.handle(
        _defaultSpendingAccountIdMeta,
        defaultSpendingAccountId.isAcceptableOrUnknown(
          data['default_spending_account_id']!,
          _defaultSpendingAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('low_balance_threshold')) {
      context.handle(
        _lowBalanceThresholdMeta,
        lowBalanceThreshold.isAcceptableOrUnknown(
          data['low_balance_threshold']!,
          _lowBalanceThresholdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      firstDayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_day_of_month'],
      )!,
      defaultSpendingAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_spending_account_id'],
      ),
      lowBalanceThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}low_balance_threshold'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final int? version;
  final String id;
  final String email;
  final String baseCurrency;
  final String timezone;
  final int firstDayOfMonth;
  final String? defaultSpendingAccountId;
  final int lowBalanceThreshold;
  const SettingsRow({
    this.version,
    required this.id,
    required this.email,
    required this.baseCurrency,
    required this.timezone,
    required this.firstDayOfMonth,
    this.defaultSpendingAccountId,
    required this.lowBalanceThreshold,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['base_currency'] = Variable<String>(baseCurrency);
    map['timezone'] = Variable<String>(timezone);
    map['first_day_of_month'] = Variable<int>(firstDayOfMonth);
    if (!nullToAbsent || defaultSpendingAccountId != null) {
      map['default_spending_account_id'] = Variable<String>(
        defaultSpendingAccountId,
      );
    }
    map['low_balance_threshold'] = Variable<int>(lowBalanceThreshold);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      id: Value(id),
      email: Value(email),
      baseCurrency: Value(baseCurrency),
      timezone: Value(timezone),
      firstDayOfMonth: Value(firstDayOfMonth),
      defaultSpendingAccountId: defaultSpendingAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultSpendingAccountId),
      lowBalanceThreshold: Value(lowBalanceThreshold),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      version: serializer.fromJson<int?>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      timezone: serializer.fromJson<String>(json['timezone']),
      firstDayOfMonth: serializer.fromJson<int>(json['firstDayOfMonth']),
      defaultSpendingAccountId: serializer.fromJson<String?>(
        json['defaultSpendingAccountId'],
      ),
      lowBalanceThreshold: serializer.fromJson<int>(
        json['lowBalanceThreshold'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int?>(version),
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'timezone': serializer.toJson<String>(timezone),
      'firstDayOfMonth': serializer.toJson<int>(firstDayOfMonth),
      'defaultSpendingAccountId': serializer.toJson<String?>(
        defaultSpendingAccountId,
      ),
      'lowBalanceThreshold': serializer.toJson<int>(lowBalanceThreshold),
    };
  }

  SettingsRow copyWith({
    Value<int?> version = const Value.absent(),
    String? id,
    String? email,
    String? baseCurrency,
    String? timezone,
    int? firstDayOfMonth,
    Value<String?> defaultSpendingAccountId = const Value.absent(),
    int? lowBalanceThreshold,
  }) => SettingsRow(
    version: version.present ? version.value : this.version,
    id: id ?? this.id,
    email: email ?? this.email,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    timezone: timezone ?? this.timezone,
    firstDayOfMonth: firstDayOfMonth ?? this.firstDayOfMonth,
    defaultSpendingAccountId: defaultSpendingAccountId.present
        ? defaultSpendingAccountId.value
        : this.defaultSpendingAccountId,
    lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
  );
  SettingsRow copyWithCompanion(UserSettingsCompanion data) {
    return SettingsRow(
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      firstDayOfMonth: data.firstDayOfMonth.present
          ? data.firstDayOfMonth.value
          : this.firstDayOfMonth,
      defaultSpendingAccountId: data.defaultSpendingAccountId.present
          ? data.defaultSpendingAccountId.value
          : this.defaultSpendingAccountId,
      lowBalanceThreshold: data.lowBalanceThreshold.present
          ? data.lowBalanceThreshold.value
          : this.lowBalanceThreshold,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('timezone: $timezone, ')
          ..write('firstDayOfMonth: $firstDayOfMonth, ')
          ..write('defaultSpendingAccountId: $defaultSpendingAccountId, ')
          ..write('lowBalanceThreshold: $lowBalanceThreshold')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    version,
    id,
    email,
    baseCurrency,
    timezone,
    firstDayOfMonth,
    defaultSpendingAccountId,
    lowBalanceThreshold,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.version == this.version &&
          other.id == this.id &&
          other.email == this.email &&
          other.baseCurrency == this.baseCurrency &&
          other.timezone == this.timezone &&
          other.firstDayOfMonth == this.firstDayOfMonth &&
          other.defaultSpendingAccountId == this.defaultSpendingAccountId &&
          other.lowBalanceThreshold == this.lowBalanceThreshold);
}

class UserSettingsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int?> version;
  final Value<String> id;
  final Value<String> email;
  final Value<String> baseCurrency;
  final Value<String> timezone;
  final Value<int> firstDayOfMonth;
  final Value<String?> defaultSpendingAccountId;
  final Value<int> lowBalanceThreshold;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.timezone = const Value.absent(),
    this.firstDayOfMonth = const Value.absent(),
    this.defaultSpendingAccountId = const Value.absent(),
    this.lowBalanceThreshold = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.version = const Value.absent(),
    required String id,
    this.email = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.timezone = const Value.absent(),
    this.firstDayOfMonth = const Value.absent(),
    this.defaultSpendingAccountId = const Value.absent(),
    this.lowBalanceThreshold = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<SettingsRow> custom({
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? baseCurrency,
    Expression<String>? timezone,
    Expression<int>? firstDayOfMonth,
    Expression<String>? defaultSpendingAccountId,
    Expression<int>? lowBalanceThreshold,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (timezone != null) 'timezone': timezone,
      if (firstDayOfMonth != null) 'first_day_of_month': firstDayOfMonth,
      if (defaultSpendingAccountId != null)
        'default_spending_account_id': defaultSpendingAccountId,
      if (lowBalanceThreshold != null)
        'low_balance_threshold': lowBalanceThreshold,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<int?>? version,
    Value<String>? id,
    Value<String>? email,
    Value<String>? baseCurrency,
    Value<String>? timezone,
    Value<int>? firstDayOfMonth,
    Value<String?>? defaultSpendingAccountId,
    Value<int>? lowBalanceThreshold,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      version: version ?? this.version,
      id: id ?? this.id,
      email: email ?? this.email,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      timezone: timezone ?? this.timezone,
      firstDayOfMonth: firstDayOfMonth ?? this.firstDayOfMonth,
      defaultSpendingAccountId:
          defaultSpendingAccountId ?? this.defaultSpendingAccountId,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (firstDayOfMonth.present) {
      map['first_day_of_month'] = Variable<int>(firstDayOfMonth.value);
    }
    if (defaultSpendingAccountId.present) {
      map['default_spending_account_id'] = Variable<String>(
        defaultSpendingAccountId.value,
      );
    }
    if (lowBalanceThreshold.present) {
      map['low_balance_threshold'] = Variable<int>(lowBalanceThreshold.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('timezone: $timezone, ')
          ..write('firstDayOfMonth: $firstDayOfMonth, ')
          ..write('defaultSpendingAccountId: $defaultSpendingAccountId, ')
          ..write('lowBalanceThreshold: $lowBalanceThreshold, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RatesTable extends Rates with TableInfo<$RatesTable, RateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<String> rate = GeneratedColumn<String>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RatesTable.$converterdate);
  @override
  List<GeneratedColumn> get $columns => [currency, rate, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<RateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {currency};
  @override
  RateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RateRow(
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate'],
      )!,
      date: $RatesTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
    );
  }

  @override
  $RatesTable createAlias(String alias) {
    return $RatesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const DateOnlyConverter();
}

class RateRow extends DataClass implements Insertable<RateRow> {
  final String currency;

  /// Decimal as text.
  final String rate;
  final DateTime date;
  const RateRow({
    required this.currency,
    required this.rate,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['currency'] = Variable<String>(currency);
    map['rate'] = Variable<String>(rate);
    {
      map['date'] = Variable<String>($RatesTable.$converterdate.toSql(date));
    }
    return map;
  }

  RatesCompanion toCompanion(bool nullToAbsent) {
    return RatesCompanion(
      currency: Value(currency),
      rate: Value(rate),
      date: Value(date),
    );
  }

  factory RateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RateRow(
      currency: serializer.fromJson<String>(json['currency']),
      rate: serializer.fromJson<String>(json['rate']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'currency': serializer.toJson<String>(currency),
      'rate': serializer.toJson<String>(rate),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  RateRow copyWith({String? currency, String? rate, DateTime? date}) => RateRow(
    currency: currency ?? this.currency,
    rate: rate ?? this.rate,
    date: date ?? this.date,
  );
  RateRow copyWithCompanion(RatesCompanion data) {
    return RateRow(
      currency: data.currency.present ? data.currency.value : this.currency,
      rate: data.rate.present ? data.rate.value : this.rate,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RateRow(')
          ..write('currency: $currency, ')
          ..write('rate: $rate, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(currency, rate, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RateRow &&
          other.currency == this.currency &&
          other.rate == this.rate &&
          other.date == this.date);
}

class RatesCompanion extends UpdateCompanion<RateRow> {
  final Value<String> currency;
  final Value<String> rate;
  final Value<DateTime> date;
  final Value<int> rowid;
  const RatesCompanion({
    this.currency = const Value.absent(),
    this.rate = const Value.absent(),
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RatesCompanion.insert({
    required String currency,
    required String rate,
    required DateTime date,
    this.rowid = const Value.absent(),
  }) : currency = Value(currency),
       rate = Value(rate),
       date = Value(date);
  static Insertable<RateRow> custom({
    Expression<String>? currency,
    Expression<String>? rate,
    Expression<String>? date,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (currency != null) 'currency': currency,
      if (rate != null) 'rate': rate,
      if (date != null) 'date': date,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RatesCompanion copyWith({
    Value<String>? currency,
    Value<String>? rate,
    Value<DateTime>? date,
    Value<int>? rowid,
  }) {
    return RatesCompanion(
      currency: currency ?? this.currency,
      rate: rate ?? this.rate,
      date: date ?? this.date,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rate.present) {
      map['rate'] = Variable<String>(rate.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $RatesTable.$converterdate.toSql(date.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RatesCompanion(')
          ..write('currency: $currency, ')
          ..write('rate: $rate, ')
          ..write('date: $date, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientUpdatedAtUsMeta = const VerificationMeta(
    'clientUpdatedAtUs',
  );
  @override
  late final GeneratedColumn<int> clientUpdatedAtUs = GeneratedColumn<int>(
    'client_updated_at_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    entityType,
    entityId,
    operation,
    payload,
    clientUpdatedAtUs,
    attempts,
    errorCode,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('client_updated_at_us')) {
      context.handle(
        _clientUpdatedAtUsMeta,
        clientUpdatedAtUs.isAcceptableOrUnknown(
          data['client_updated_at_us']!,
          _clientUpdatedAtUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientUpdatedAtUsMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      clientUpdatedAtUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_updated_at_us'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int seq;
  final String entityType;
  final String entityId;
  final String operation;

  /// JSON payload in the push shape (null for deletes).
  final String? payload;

  /// UTC microseconds. Exact, because a retry must send the very same value (server idempotency).
  final int clientUpdatedAtUs;
  final int attempts;
  final String? errorCode;
  final String? errorMessage;
  const OutboxRow({
    required this.seq,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.payload,
    required this.clientUpdatedAtUs,
    required this.attempts,
    this.errorCode,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['client_updated_at_us'] = Variable<int>(clientUpdatedAtUs);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      clientUpdatedAtUs: Value(clientUpdatedAtUs),
      attempts: Value(attempts),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      seq: serializer.fromJson<int>(json['seq']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String?>(json['payload']),
      clientUpdatedAtUs: serializer.fromJson<int>(json['clientUpdatedAtUs']),
      attempts: serializer.fromJson<int>(json['attempts']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String?>(payload),
      'clientUpdatedAtUs': serializer.toJson<int>(clientUpdatedAtUs),
      'attempts': serializer.toJson<int>(attempts),
      'errorCode': serializer.toJson<String?>(errorCode),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  OutboxRow copyWith({
    int? seq,
    String? entityType,
    String? entityId,
    String? operation,
    Value<String?> payload = const Value.absent(),
    int? clientUpdatedAtUs,
    int? attempts,
    Value<String?> errorCode = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
  }) => OutboxRow(
    seq: seq ?? this.seq,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload.present ? payload.value : this.payload,
    clientUpdatedAtUs: clientUpdatedAtUs ?? this.clientUpdatedAtUs,
    attempts: attempts ?? this.attempts,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      clientUpdatedAtUs: data.clientUpdatedAtUs.present
          ? data.clientUpdatedAtUs.value
          : this.clientUpdatedAtUs,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('seq: $seq, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('clientUpdatedAtUs: $clientUpdatedAtUs, ')
          ..write('attempts: $attempts, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    entityType,
    entityId,
    operation,
    payload,
    clientUpdatedAtUs,
    attempts,
    errorCode,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.seq == this.seq &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.clientUpdatedAtUs == this.clientUpdatedAtUs &&
          other.attempts == this.attempts &&
          other.errorCode == this.errorCode &&
          other.errorMessage == this.errorMessage);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> seq;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String?> payload;
  final Value<int> clientUpdatedAtUs;
  final Value<int> attempts;
  final Value<String?> errorCode;
  final Value<String?> errorMessage;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.clientUpdatedAtUs = const Value.absent(),
    this.attempts = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    this.payload = const Value.absent(),
    required int clientUpdatedAtUs,
    this.attempts = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       clientUpdatedAtUs = Value(clientUpdatedAtUs);
  static Insertable<OutboxRow> custom({
    Expression<int>? seq,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? clientUpdatedAtUs,
    Expression<int>? attempts,
    Expression<String>? errorCode,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (clientUpdatedAtUs != null) 'client_updated_at_us': clientUpdatedAtUs,
      if (attempts != null) 'attempts': attempts,
      if (errorCode != null) 'error_code': errorCode,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String?>? payload,
    Value<int>? clientUpdatedAtUs,
    Value<int>? attempts,
    Value<String?>? errorCode,
    Value<String?>? errorMessage,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      clientUpdatedAtUs: clientUpdatedAtUs ?? this.clientUpdatedAtUs,
      attempts: attempts ?? this.attempts,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (clientUpdatedAtUs.present) {
      map['client_updated_at_us'] = Variable<int>(clientUpdatedAtUs.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('clientUpdatedAtUs: $clientUpdatedAtUs, ')
          ..write('attempts: $attempts, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues
    with TableInfo<$KeyValuesTable, KeyValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KeyValueRow extends DataClass implements Insertable<KeyValueRow> {
  final String key;
  final String value;
  const KeyValueRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(key: Value(key), value: Value(value));
  }

  factory KeyValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KeyValueRow copyWith({String? key, String? value}) =>
      KeyValueRow(key: key ?? this.key, value: value ?? this.value);
  KeyValueRow copyWithCompanion(KeyValuesCompanion data) {
    return KeyValueRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValueRow &&
          other.key == this.key &&
          other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValueRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KeyValueRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValuesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KeyValuesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $BudgetLinesTable budgetLines = $BudgetLinesTable(this);
  late final $BudgetGoalAllocationsTable budgetGoalAllocations =
      $BudgetGoalAllocationsTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $RatesTable rates = $RatesTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  late final Index ixTransactionsDate = Index(
    'ix_transactions_date',
    'CREATE INDEX ix_transactions_date ON transactions (date)',
  );
  late final Index ixTransactionsAccount = Index(
    'ix_transactions_account',
    'CREATE INDEX ix_transactions_account ON transactions (account_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    transactions,
    recurringRules,
    budgets,
    budgetLines,
    budgetGoalAllocations,
    savingsGoals,
    userSettings,
    rates,
    outbox,
    keyValues,
    ixTransactionsDate,
    ixTransactionsAccount,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int?> version,
  required String id,
  required String name,
  required AccountType type,
  required String currency,
  Value<int> initialBalance,
  Value<bool> includeInTotals,
  Value<bool> isArchived,
  Value<int> sortOrder,
  Value<String?> color,
  Value<String?> icon,
  Value<int?> creditLimit,
  Value<String?> interestRatePercent,
  Value<CapitalizationPeriod?> capitalizationPeriod,
  Value<DateTime?> openDate,
  Value<DateTime?> maturityDate,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int?> version,
  Value<String> id,
  Value<String> name,
  Value<AccountType> type,
  Value<String> currency,
  Value<int> initialBalance,
  Value<bool> includeInTotals,
  Value<bool> isArchived,
  Value<int> sortOrder,
  Value<String?> color,
  Value<String?> icon,
  Value<int?> creditLimit,
  Value<String?> interestRatePercent,
  Value<CapitalizationPeriod?> capitalizationPeriod,
  Value<DateTime?> openDate,
  Value<DateTime?> maturityDate,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountType, AccountType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeInTotals => $composableBuilder(
    column: $table.includeInTotals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestRatePercent => $composableBuilder(
    column: $table.interestRatePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    CapitalizationPeriod?,
    CapitalizationPeriod,
    String
  >
  get capitalizationPeriod => $composableBuilder(
    column: $table.capitalizationPeriod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get openDate =>
      $composableBuilder(
        column: $table.openDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeInTotals => $composableBuilder(
    column: $table.includeInTotals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestRatePercent => $composableBuilder(
    column: $table.interestRatePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capitalizationPeriod => $composableBuilder(
    column: $table.capitalizationPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openDate => $composableBuilder(
    column: $table.openDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeInTotals => $composableBuilder(
    column: $table.includeInTotals,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestRatePercent => $composableBuilder(
    column: $table.interestRatePercent,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CapitalizationPeriod?, String>
  get capitalizationPeriod => $composableBuilder(
    column: $table.capitalizationPeriod,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, String> get openDate =>
      $composableBuilder(column: $table.openDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get maturityDate =>
      $composableBuilder(
        column: $table.maturityDate,
        builder: (column) => column,
      );
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (
            AccountRow,
            BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>,
          ),
          AccountRow,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AccountType> type = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> initialBalance = const Value.absent(),
                Value<bool> includeInTotals = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int?> creditLimit = const Value.absent(),
                Value<String?> interestRatePercent = const Value.absent(),
                Value<CapitalizationPeriod?> capitalizationPeriod =
                    const Value.absent(),
                Value<DateTime?> openDate = const Value.absent(),
                Value<DateTime?> maturityDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                version: version,
                id: id,
                name: name,
                type: type,
                currency: currency,
                initialBalance: initialBalance,
                includeInTotals: includeInTotals,
                isArchived: isArchived,
                sortOrder: sortOrder,
                color: color,
                icon: icon,
                creditLimit: creditLimit,
                interestRatePercent: interestRatePercent,
                capitalizationPeriod: capitalizationPeriod,
                openDate: openDate,
                maturityDate: maturityDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                required String id,
                required String name,
                required AccountType type,
                required String currency,
                Value<int> initialBalance = const Value.absent(),
                Value<bool> includeInTotals = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int?> creditLimit = const Value.absent(),
                Value<String?> interestRatePercent = const Value.absent(),
                Value<CapitalizationPeriod?> capitalizationPeriod =
                    const Value.absent(),
                Value<DateTime?> openDate = const Value.absent(),
                Value<DateTime?> maturityDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                version: version,
                id: id,
                name: name,
                type: type,
                currency: currency,
                initialBalance: initialBalance,
                includeInTotals: includeInTotals,
                isArchived: isArchived,
                sortOrder: sortOrder,
                color: color,
                icon: icon,
                creditLimit: creditLimit,
                interestRatePercent: interestRatePercent,
                capitalizationPeriod: capitalizationPeriod,
                openDate: openDate,
                maturityDate: maturityDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, AccountRow>(table),
                  BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>),
      AccountRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int?> version,
  required String id,
  required String name,
  required CategoryKind kind,
  Value<String?> parentId,
  Value<String?> icon,
  Value<String?> color,
  Value<bool> isArchived,
  Value<String?> systemCode,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int?> version,
  Value<String> id,
  Value<String> name,
  Value<CategoryKind> kind,
  Value<String?> parentId,
  Value<String?> icon,
  Value<String?> color,
  Value<bool> isArchived,
  Value<String?> systemCode,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CategoryKind, CategoryKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemCode => $composableBuilder(
    column: $table.systemCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemCode => $composableBuilder(
    column: $table.systemCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoryKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemCode => $composableBuilder(
    column: $table.systemCode,
    builder: (column) => column,
  );
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<CategoryKind> kind = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> systemCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                version: version,
                id: id,
                name: name,
                kind: kind,
                parentId: parentId,
                icon: icon,
                color: color,
                isArchived: isArchived,
                systemCode: systemCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                required String id,
                required String name,
                required CategoryKind kind,
                Value<String?> parentId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> systemCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                version: version,
                id: id,
                name: name,
                kind: kind,
                parentId: parentId,
                icon: icon,
                color: color,
                isArchived: isArchived,
                systemCode: systemCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int?> version,
      required String id,
      required String accountId,
      required TransactionType type,
      required int amount,
      Value<String?> categoryId,
      required DateTime date,
      Value<String?> note,
      Value<List<String>> tags,
      required TransactionStatus status,
      Value<String?> toAccountId,
      Value<int?> toAmount,
      Value<String?> savingsGoalId,
      Value<String?> recurringRuleId,
      Value<DateTime?> recurrenceDate,
      required int createdAtUs,
      Value<String> searchText,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int?> version,
      Value<String> id,
      Value<String> accountId,
      Value<TransactionType> type,
      Value<int> amount,
      Value<String?> categoryId,
      Value<DateTime> date,
      Value<String?> note,
      Value<List<String>> tags,
      Value<TransactionStatus> status,
      Value<String?> toAccountId,
      Value<int?> toAmount,
      Value<String?> savingsGoalId,
      Value<String?> recurringRuleId,
      Value<DateTime?> recurrenceDate,
      Value<int> createdAtUs,
      Value<String> searchText,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TransactionStatus, TransactionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toAmount => $composableBuilder(
    column: $table.toAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savingsGoalId => $composableBuilder(
    column: $table.savingsGoalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringRuleId => $composableBuilder(
    column: $table.recurringRuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get recurrenceDate => $composableBuilder(
    column: $table.recurrenceDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toAmount => $composableBuilder(
    column: $table.toAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savingsGoalId => $composableBuilder(
    column: $table.savingsGoalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringRuleId => $composableBuilder(
    column: $table.recurringRuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceDate => $composableBuilder(
    column: $table.recurrenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toAmount =>
      $composableBuilder(column: $table.toAmount, builder: (column) => column);

  GeneratedColumn<String> get savingsGoalId => $composableBuilder(
    column: $table.savingsGoalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringRuleId => $composableBuilder(
    column: $table.recurringRuleId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, String> get recurrenceDate =>
      $composableBuilder(
        column: $table.recurrenceDate,
        builder: (column) => column,
      );

  GeneratedColumn<int> get createdAtUs => $composableBuilder(
    column: $table.createdAtUs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<TransactionType> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<TransactionStatus> status = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                Value<int?> toAmount = const Value.absent(),
                Value<String?> savingsGoalId = const Value.absent(),
                Value<String?> recurringRuleId = const Value.absent(),
                Value<DateTime?> recurrenceDate = const Value.absent(),
                Value<int> createdAtUs = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                version: version,
                id: id,
                accountId: accountId,
                type: type,
                amount: amount,
                categoryId: categoryId,
                date: date,
                note: note,
                tags: tags,
                status: status,
                toAccountId: toAccountId,
                toAmount: toAmount,
                savingsGoalId: savingsGoalId,
                recurringRuleId: recurringRuleId,
                recurrenceDate: recurrenceDate,
                createdAtUs: createdAtUs,
                searchText: searchText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                required String id,
                required String accountId,
                required TransactionType type,
                required int amount,
                Value<String?> categoryId = const Value.absent(),
                required DateTime date,
                Value<String?> note = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                required TransactionStatus status,
                Value<String?> toAccountId = const Value.absent(),
                Value<int?> toAmount = const Value.absent(),
                Value<String?> savingsGoalId = const Value.absent(),
                Value<String?> recurringRuleId = const Value.absent(),
                Value<DateTime?> recurrenceDate = const Value.absent(),
                required int createdAtUs,
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                version: version,
                id: id,
                accountId: accountId,
                type: type,
                amount: amount,
                categoryId: categoryId,
                date: date,
                note: note,
                tags: tags,
                status: status,
                toAccountId: toAccountId,
                toAmount: toAmount,
                savingsGoalId: savingsGoalId,
                recurringRuleId: recurringRuleId,
                recurrenceDate: recurrenceDate,
                createdAtUs: createdAtUs,
                searchText: searchText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, TransactionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TransactionsTable,
                    TransactionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<int?> version,
      required String id,
      required String name,
      required String accountId,
      required TransactionType type,
      required int amount,
      Value<String?> categoryId,
      Value<String?> note,
      Value<List<String>> tags,
      Value<String?> toAccountId,
      Value<int?> toAmount,
      Value<String?> savingsGoalId,
      required Frequency frequency,
      Value<int> interval,
      Value<int?> dayOfMonth,
      Value<String?> dayOfWeek,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<int?> version,
      Value<String> id,
      Value<String> name,
      Value<String> accountId,
      Value<TransactionType> type,
      Value<int> amount,
      Value<String?> categoryId,
      Value<String?> note,
      Value<List<String>> tags,
      Value<String?> toAccountId,
      Value<int?> toAmount,
      Value<String?> savingsGoalId,
      Value<Frequency> frequency,
      Value<int> interval,
      Value<int?> dayOfMonth,
      Value<String?> dayOfWeek,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toAmount => $composableBuilder(
    column: $table.toAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savingsGoalId => $composableBuilder(
    column: $table.savingsGoalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Frequency, Frequency, String> get frequency =>
      $composableBuilder(
        column: $table.frequency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get startDate =>
      $composableBuilder(
        column: $table.startDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get endDate =>
      $composableBuilder(
        column: $table.endDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toAmount => $composableBuilder(
    column: $table.toAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savingsGoalId => $composableBuilder(
    column: $table.savingsGoalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toAmount =>
      $composableBuilder(column: $table.toAmount, builder: (column) => column);

  GeneratedColumn<String> get savingsGoalId => $composableBuilder(
    column: $table.savingsGoalId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Frequency, String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringRulesTable,
          RecurringRuleRow,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (
            RecurringRuleRow,
            BaseReferences<
              _$AppDatabase,
              $RecurringRulesTable,
              RecurringRuleRow
            >,
          ),
          RecurringRuleRow,
          PrefetchHooks Function()
        > {
  $$RecurringRulesTableTableManager(
    _$AppDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<TransactionType> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                Value<int?> toAmount = const Value.absent(),
                Value<String?> savingsGoalId = const Value.absent(),
                Value<Frequency> frequency = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int?> dayOfMonth = const Value.absent(),
                Value<String?> dayOfWeek = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion(
                version: version,
                id: id,
                name: name,
                accountId: accountId,
                type: type,
                amount: amount,
                categoryId: categoryId,
                note: note,
                tags: tags,
                toAccountId: toAccountId,
                toAmount: toAmount,
                savingsGoalId: savingsGoalId,
                frequency: frequency,
                interval: interval,
                dayOfMonth: dayOfMonth,
                dayOfWeek: dayOfWeek,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                required String id,
                required String name,
                required String accountId,
                required TransactionType type,
                required int amount,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                Value<int?> toAmount = const Value.absent(),
                Value<String?> savingsGoalId = const Value.absent(),
                required Frequency frequency,
                Value<int> interval = const Value.absent(),
                Value<int?> dayOfMonth = const Value.absent(),
                Value<String?> dayOfWeek = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion.insert(
                version: version,
                id: id,
                name: name,
                accountId: accountId,
                type: type,
                amount: amount,
                categoryId: categoryId,
                note: note,
                tags: tags,
                toAccountId: toAccountId,
                toAmount: toAmount,
                savingsGoalId: savingsGoalId,
                frequency: frequency,
                interval: interval,
                dayOfMonth: dayOfMonth,
                dayOfWeek: dayOfWeek,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringRulesTable, RecurringRuleRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecurringRulesTable,
                    RecurringRuleRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringRulesTable,
      RecurringRuleRow,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (
        RecurringRuleRow,
        BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRuleRow>,
      ),
      RecurringRuleRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  Value<int?> version,
  required String id,
  required String month,
  required String currency,
  Value<int> expectedIncome,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<int?> version,
  Value<String> id,
  Value<String> month,
  Value<String> currency,
  Value<int> expectedIncome,
  Value<int> rowid,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedIncome => $composableBuilder(
    column: $table.expectedIncome,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedIncome => $composableBuilder(
    column: $table.expectedIncome,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get expectedIncome => $composableBuilder(
    column: $table.expectedIncome,
    builder: (column) => column,
  );
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          BudgetRow,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (BudgetRow, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>),
          BudgetRow,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> expectedIncome = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                version: version,
                id: id,
                month: month,
                currency: currency,
                expectedIncome: expectedIncome,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                required String id,
                required String month,
                required String currency,
                Value<int> expectedIncome = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                version: version,
                id: id,
                month: month,
                currency: currency,
                expectedIncome: expectedIncome,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetsTable, BudgetRow>(table),
                  BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      BudgetRow,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (BudgetRow, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>),
      BudgetRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetLinesTableCreateCompanionBuilder =
    BudgetLinesCompanion Function({
      Value<int?> version,
      required String id,
      required String budgetId,
      required String categoryId,
      Value<int> plannedAmount,
      Value<bool> rollover,
      Value<int> rowid,
    });
typedef $$BudgetLinesTableUpdateCompanionBuilder =
    BudgetLinesCompanion Function({
      Value<int?> version,
      Value<String> id,
      Value<String> budgetId,
      Value<String> categoryId,
      Value<int> plannedAmount,
      Value<bool> rollover,
      Value<int> rowid,
    });

class $$BudgetLinesTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetLinesTable> {
  $$BudgetLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rollover => $composableBuilder(
    column: $table.rollover,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetLinesTable> {
  $$BudgetLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rollover => $composableBuilder(
    column: $table.rollover,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetLinesTable> {
  $$BudgetLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rollover =>
      $composableBuilder(column: $table.rollover, builder: (column) => column);
}

class $$BudgetLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetLinesTable,
          BudgetLineRow,
          $$BudgetLinesTableFilterComposer,
          $$BudgetLinesTableOrderingComposer,
          $$BudgetLinesTableAnnotationComposer,
          $$BudgetLinesTableCreateCompanionBuilder,
          $$BudgetLinesTableUpdateCompanionBuilder,
          (
            BudgetLineRow,
            BaseReferences<_$AppDatabase, $BudgetLinesTable, BudgetLineRow>,
          ),
          BudgetLineRow,
          PrefetchHooks Function()
        > {
  $$BudgetLinesTableTableManager(_$AppDatabase db, $BudgetLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> budgetId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> plannedAmount = const Value.absent(),
                Value<bool> rollover = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetLinesCompanion(
                version: version,
                id: id,
                budgetId: budgetId,
                categoryId: categoryId,
                plannedAmount: plannedAmount,
                rollover: rollover,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                required String id,
                required String budgetId,
                required String categoryId,
                Value<int> plannedAmount = const Value.absent(),
                Value<bool> rollover = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetLinesCompanion.insert(
                version: version,
                id: id,
                budgetId: budgetId,
                categoryId: categoryId,
                plannedAmount: plannedAmount,
                rollover: rollover,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetLinesTable, BudgetLineRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BudgetLinesTable,
                    BudgetLineRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetLinesTable,
      BudgetLineRow,
      $$BudgetLinesTableFilterComposer,
      $$BudgetLinesTableOrderingComposer,
      $$BudgetLinesTableAnnotationComposer,
      $$BudgetLinesTableCreateCompanionBuilder,
      $$BudgetLinesTableUpdateCompanionBuilder,
      (
        BudgetLineRow,
        BaseReferences<_$AppDatabase, $BudgetLinesTable, BudgetLineRow>,
      ),
      BudgetLineRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetGoalAllocationsTableCreateCompanionBuilder =
    BudgetGoalAllocationsCompanion Function({
      Value<int?> version,
      required String id,
      required String budgetId,
      required String savingsGoalId,
      Value<int> plannedAmount,
      Value<int> rowid,
    });
typedef $$BudgetGoalAllocationsTableUpdateCompanionBuilder =
    BudgetGoalAllocationsCompanion Function({
      Value<int?> version,
      Value<String> id,
      Value<String> budgetId,
      Value<String> savingsGoalId,
      Value<int> plannedAmount,
      Value<int> rowid,
    });

class $$BudgetGoalAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetGoalAllocationsTable> {
  $$BudgetGoalAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savingsGoalId => $composableBuilder(
    column: $table.savingsGoalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetGoalAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetGoalAllocationsTable> {
  $$BudgetGoalAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savingsGoalId => $composableBuilder(
    column: $table.savingsGoalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetGoalAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetGoalAllocationsTable> {
  $$BudgetGoalAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get savingsGoalId => $composableBuilder(
    column: $table.savingsGoalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => column,
  );
}

class $$BudgetGoalAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetGoalAllocationsTable,
          BudgetAllocationRow,
          $$BudgetGoalAllocationsTableFilterComposer,
          $$BudgetGoalAllocationsTableOrderingComposer,
          $$BudgetGoalAllocationsTableAnnotationComposer,
          $$BudgetGoalAllocationsTableCreateCompanionBuilder,
          $$BudgetGoalAllocationsTableUpdateCompanionBuilder,
          (
            BudgetAllocationRow,
            BaseReferences<
              _$AppDatabase,
              $BudgetGoalAllocationsTable,
              BudgetAllocationRow
            >,
          ),
          BudgetAllocationRow,
          PrefetchHooks Function()
        > {
  $$BudgetGoalAllocationsTableTableManager(
    _$AppDatabase db,
    $BudgetGoalAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetGoalAllocationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BudgetGoalAllocationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BudgetGoalAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> budgetId = const Value.absent(),
                Value<String> savingsGoalId = const Value.absent(),
                Value<int> plannedAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetGoalAllocationsCompanion(
                version: version,
                id: id,
                budgetId: budgetId,
                savingsGoalId: savingsGoalId,
                plannedAmount: plannedAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                required String id,
                required String budgetId,
                required String savingsGoalId,
                Value<int> plannedAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetGoalAllocationsCompanion.insert(
                version: version,
                id: id,
                budgetId: budgetId,
                savingsGoalId: savingsGoalId,
                plannedAmount: plannedAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetGoalAllocationsTable, BudgetAllocationRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $BudgetGoalAllocationsTable,
                    BudgetAllocationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetGoalAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetGoalAllocationsTable,
      BudgetAllocationRow,
      $$BudgetGoalAllocationsTableFilterComposer,
      $$BudgetGoalAllocationsTableOrderingComposer,
      $$BudgetGoalAllocationsTableAnnotationComposer,
      $$BudgetGoalAllocationsTableCreateCompanionBuilder,
      $$BudgetGoalAllocationsTableUpdateCompanionBuilder,
      (
        BudgetAllocationRow,
        BaseReferences<
          _$AppDatabase,
          $BudgetGoalAllocationsTable,
          BudgetAllocationRow
        >,
      ),
      BudgetAllocationRow,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalsTableCreateCompanionBuilder =
    SavingsGoalsCompanion Function({
      Value<int?> version,
      required String id,
      required String name,
      required int targetAmount,
      required String currency,
      Value<DateTime?> targetDate,
      Value<String?> linkedAccountId,
      Value<int> priority,
      Value<bool> isCompleted,
      Value<DateTime?> completedOn,
      Value<String?> color,
      Value<String?> icon,
      Value<int> rowid,
    });
typedef $$SavingsGoalsTableUpdateCompanionBuilder =
    SavingsGoalsCompanion Function({
      Value<int?> version,
      Value<String> id,
      Value<String> name,
      Value<int> targetAmount,
      Value<String> currency,
      Value<DateTime?> targetDate,
      Value<String?> linkedAccountId,
      Value<int> priority,
      Value<bool> isCompleted,
      Value<DateTime?> completedOn,
      Value<String?> color,
      Value<String?> icon,
      Value<int> rowid,
    });

class $$SavingsGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get targetDate =>
      $composableBuilder(
        column: $table.targetDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get completedOn =>
      $composableBuilder(
        column: $table.completedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get targetDate =>
      $composableBuilder(
        column: $table.targetDate,
        builder: (column) => column,
      );

  GeneratedColumn<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, String> get completedOn =>
      $composableBuilder(
        column: $table.completedOn,
        builder: (column) => column,
      );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$SavingsGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalsTable,
          SavingsGoalRow,
          $$SavingsGoalsTableFilterComposer,
          $$SavingsGoalsTableOrderingComposer,
          $$SavingsGoalsTableAnnotationComposer,
          $$SavingsGoalsTableCreateCompanionBuilder,
          $$SavingsGoalsTableUpdateCompanionBuilder,
          (
            SavingsGoalRow,
            BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoalRow>,
          ),
          SavingsGoalRow,
          PrefetchHooks Function()
        > {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetAmount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedOn = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion(
                version: version,
                id: id,
                name: name,
                targetAmount: targetAmount,
                currency: currency,
                targetDate: targetDate,
                linkedAccountId: linkedAccountId,
                priority: priority,
                isCompleted: isCompleted,
                completedOn: completedOn,
                color: color,
                icon: icon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                required String id,
                required String name,
                required int targetAmount,
                required String currency,
                Value<DateTime?> targetDate = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedOn = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion.insert(
                version: version,
                id: id,
                name: name,
                targetAmount: targetAmount,
                currency: currency,
                targetDate: targetDate,
                linkedAccountId: linkedAccountId,
                priority: priority,
                isCompleted: isCompleted,
                completedOn: completedOn,
                color: color,
                icon: icon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavingsGoalsTable, SavingsGoalRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SavingsGoalsTable,
                    SavingsGoalRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalsTable,
      SavingsGoalRow,
      $$SavingsGoalsTableFilterComposer,
      $$SavingsGoalsTableOrderingComposer,
      $$SavingsGoalsTableAnnotationComposer,
      $$SavingsGoalsTableCreateCompanionBuilder,
      $$SavingsGoalsTableUpdateCompanionBuilder,
      (
        SavingsGoalRow,
        BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoalRow>,
      ),
      SavingsGoalRow,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int?> version,
      required String id,
      Value<String> email,
      Value<String> baseCurrency,
      Value<String> timezone,
      Value<int> firstDayOfMonth,
      Value<String?> defaultSpendingAccountId,
      Value<int> lowBalanceThreshold,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int?> version,
      Value<String> id,
      Value<String> email,
      Value<String> baseCurrency,
      Value<String> timezone,
      Value<int> firstDayOfMonth,
      Value<String?> defaultSpendingAccountId,
      Value<int> lowBalanceThreshold,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstDayOfMonth => $composableBuilder(
    column: $table.firstDayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultSpendingAccountId => $composableBuilder(
    column: $table.defaultSpendingAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lowBalanceThreshold => $composableBuilder(
    column: $table.lowBalanceThreshold,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstDayOfMonth => $composableBuilder(
    column: $table.firstDayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultSpendingAccountId => $composableBuilder(
    column: $table.defaultSpendingAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lowBalanceThreshold => $composableBuilder(
    column: $table.lowBalanceThreshold,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get firstDayOfMonth => $composableBuilder(
    column: $table.firstDayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultSpendingAccountId => $composableBuilder(
    column: $table.defaultSpendingAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lowBalanceThreshold => $composableBuilder(
    column: $table.lowBalanceThreshold,
    builder: (column) => column,
  );
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          SettingsRow,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $UserSettingsTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> firstDayOfMonth = const Value.absent(),
                Value<String?> defaultSpendingAccountId = const Value.absent(),
                Value<int> lowBalanceThreshold = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(
                version: version,
                id: id,
                email: email,
                baseCurrency: baseCurrency,
                timezone: timezone,
                firstDayOfMonth: firstDayOfMonth,
                defaultSpendingAccountId: defaultSpendingAccountId,
                lowBalanceThreshold: lowBalanceThreshold,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> version = const Value.absent(),
                required String id,
                Value<String> email = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> firstDayOfMonth = const Value.absent(),
                Value<String?> defaultSpendingAccountId = const Value.absent(),
                Value<int> lowBalanceThreshold = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                version: version,
                id: id,
                email: email,
                baseCurrency: baseCurrency,
                timezone: timezone,
                firstDayOfMonth: firstDayOfMonth,
                defaultSpendingAccountId: defaultSpendingAccountId,
                lowBalanceThreshold: lowBalanceThreshold,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserSettingsTable, SettingsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserSettingsTable,
                    SettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      SettingsRow,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        SettingsRow,
        BaseReferences<_$AppDatabase, $UserSettingsTable, SettingsRow>,
      ),
      SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$RatesTableCreateCompanionBuilder = RatesCompanion Function({
  required String currency,
  required String rate,
  required DateTime date,
  Value<int> rowid,
});
typedef $$RatesTableUpdateCompanionBuilder = RatesCompanion Function({
  Value<String> currency,
  Value<String> rate,
  Value<DateTime> date,
  Value<int> rowid,
});

class $$RatesTableFilterComposer extends Composer<_$AppDatabase, $RatesTable> {
  $$RatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$RatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RatesTable> {
  $$RatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RatesTable> {
  $$RatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$RatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RatesTable,
          RateRow,
          $$RatesTableFilterComposer,
          $$RatesTableOrderingComposer,
          $$RatesTableAnnotationComposer,
          $$RatesTableCreateCompanionBuilder,
          $$RatesTableUpdateCompanionBuilder,
          (RateRow, BaseReferences<_$AppDatabase, $RatesTable, RateRow>),
          RateRow,
          PrefetchHooks Function()
        > {
  $$RatesTableTableManager(_$AppDatabase db, $RatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> currency = const Value.absent(),
                Value<String> rate = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RatesCompanion(
                currency: currency,
                rate: rate,
                date: date,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String currency,
                required String rate,
                required DateTime date,
                Value<int> rowid = const Value.absent(),
              }) => RatesCompanion.insert(
                currency: currency,
                rate: rate,
                date: date,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RatesTable, RateRow>(table),
                  BaseReferences<_$AppDatabase, $RatesTable, RateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RatesTable,
      RateRow,
      $$RatesTableFilterComposer,
      $$RatesTableOrderingComposer,
      $$RatesTableAnnotationComposer,
      $$RatesTableCreateCompanionBuilder,
      $$RatesTableUpdateCompanionBuilder,
      (RateRow, BaseReferences<_$AppDatabase, $RatesTable, RateRow>),
      RateRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  required String entityType,
  required String entityId,
  required String operation,
  Value<String?> payload,
  required int clientUpdatedAtUs,
  Value<int> attempts,
  Value<String?> errorCode,
  Value<String?> errorMessage,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String?> payload,
  Value<int> clientUpdatedAtUs,
  Value<int> attempts,
  Value<String?> errorCode,
  Value<String?> errorMessage,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientUpdatedAtUs => $composableBuilder(
    column: $table.clientUpdatedAtUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientUpdatedAtUs => $composableBuilder(
    column: $table.clientUpdatedAtUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get clientUpdatedAtUs => $composableBuilder(
    column: $table.clientUpdatedAtUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxRow,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<int> clientUpdatedAtUs = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                clientUpdatedAtUs: clientUpdatedAtUs,
                attempts: attempts,
                errorCode: errorCode,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String entityType,
                required String entityId,
                required String operation,
                Value<String?> payload = const Value.absent(),
                required int clientUpdatedAtUs,
                Value<int> attempts = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => OutboxCompanion.insert(
                seq: seq,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                clientUpdatedAtUs: clientUpdatedAtUs,
                attempts: attempts,
                errorCode: errorCode,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxRow>(table),
                  BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxRow,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$KeyValuesTableCreateCompanionBuilder = KeyValuesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$KeyValuesTableUpdateCompanionBuilder = KeyValuesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$KeyValuesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeyValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeyValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValuesTable,
          KeyValueRow,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (
            KeyValueRow,
            BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>,
          ),
          KeyValueRow,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$AppDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => KeyValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => KeyValuesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KeyValuesTable, KeyValueRow>(table),
                  BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValuesTable,
      KeyValueRow,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (
        KeyValueRow,
        BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>,
      ),
      KeyValueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$BudgetLinesTableTableManager get budgetLines =>
      $$BudgetLinesTableTableManager(_db, _db.budgetLines);
  $$BudgetGoalAllocationsTableTableManager get budgetGoalAllocations =>
      $$BudgetGoalAllocationsTableTableManager(_db, _db.budgetGoalAllocations);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$RatesTableTableManager get rates =>
      $$RatesTableTableManager(_db, _db.rates);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$KeyValuesTableTableManager get keyValues =>
      $$KeyValuesTableTableManager(_db, _db.keyValues);
}
