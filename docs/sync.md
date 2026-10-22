# Протокол синхронизации

Клиент работает с локальной БД (offline-first) и обменивается с сервером изменениями через два эндпоинта:
`POST /api/v1/sync/push` и `GET /api/v1/sync/pull`. Обоснование решений — в [`decisions.md`](decisions.md), пункты D57–D62.

## Сущности

| `entityType` | Что это | Поля `payload` / `data` |
|---|---|---|
| `settings` | настройки пользователя, `id` = id пользователя | `baseCurrency`, `timezone`, `firstDayOfMonth`, `defaultSpendingAccountId?`, `lowBalanceThreshold`; в pull также `email` (только чтение). Удалять нельзя |
| `account` | счёт | `name`, `type`, `currency`, `initialBalance`, `includeInTotals`, `isArchived`, `sortOrder`, `color?`, `icon?`, `creditLimit?`, `interestRatePercent?`, `capitalizationPeriod?`, `openDate?`, `maturityDate?` |
| `category` | категория | `name`, `kind`, `parentId?`, `icon?`, `color?`, `isArchived`; в pull также `systemCode?` (только чтение) |
| `savingsGoal` | цель | `name`, `targetAmount`, `currency`, `targetDate?`, `linkedAccountId?`, `priority`, `isCompleted`, `completedOn?`, `color?`, `icon?` |
| `recurringRule` | регулярный платёж | `name`, поля шаблона транзакции (`accountId`, `type`, `amount`, `categoryId?`, `note?`, `tags`, `toAccountId?`, `toAmount?`, `savingsGoalId?`), `frequency`, `interval`, `dayOfMonth?`, `dayOfWeek?`, `startDate`, `endDate?`, `isActive` |
| `budget` | бюджет месяца | `month` (yyyy-MM), `currency`, `expectedIncome` |
| `budgetLine` | линия бюджета | `budgetId`, `categoryId`, `plannedAmount`, `rollover` |
| `budgetGoalAllocation` | взнос в цель в бюджете | `budgetId`, `savingsGoalId`, `plannedAmount` |
| `transaction` | операция | `accountId`, `type`, `amount`, `categoryId?`, `date`, `note?`, `tags`, `status`, `toAccountId?`, `toAmount?`, `savingsGoalId?`, `recurringRuleId?`, `recurrenceDate?` |

Деньги — целые minor units. Даты — `yyyy-MM-dd`, таймстемпы — ISO 8601 UTC. Enum'ы передаются строками
(`"DebitCard"`, регистр при чтении не важен). Id — UUID v7, их генерирует клиент.
Правила валидации те же, что у REST API.

## Push

```http
POST /api/v1/sync/push
{
  "changes": [
    { "entityType": "account", "id": "…", "operation": "upsert",
      "payload": { "name": "Карта", "type": "DebitCard", "currency": "BYN", "initialBalance": 10000 },
      "clientUpdatedAt": "2026-10-22T10:15:30.123Z" },
    { "entityType": "transaction", "id": "…", "operation": "delete", "clientUpdatedAt": "2026-10-22T10:16:00Z" }
  ]
}
```

- В одном запросе от 1 до 500 изменений. Порядок внутри батча не важен: сервер сам применяет upsert'ы от родителей
  к детям (`account → settings → category (сначала корневые) → savingsGoal → recurringRule → budget → budgetLine →
  budgetGoalAllocation → transaction`), а удаления — в обратном порядке.
- Каждое изменение применяется и сохраняется отдельно: отклонение одного не мешает остальным.
- Повтор с теми же `(id, clientUpdatedAt)` не применяется второй раз, а возвращает исходный результат со статусом
  `Duplicate`. После сетевой ошибки отправляйте те же изменения с теми же `clientUpdatedAt`.
- Конфликты решает принцип «последняя запись побеждает» в порядке прихода на сервер. Удалённую сущность изменить нельзя
  (`entity_deleted`), удаление побеждает.

Ответ:

```json
{
  "accepted": [ { "entityType": "account", "id": "…", "operation": "Upsert", "version": 1042, "status": "Applied" } ],
  "rejected": [ { "entityType": "transaction", "id": "…", "operation": "Upsert",
                  "code": "category_kind_mismatch", "message": "…", "errors": null } ]
}
```

Статусы `accepted`: `Applied` (новая версия), `Unchanged` (данные совпали, версия прежняя), `Duplicate`,
`AlreadyDeleted`, `Ignored` (удаление сущности, которой на сервере нет).

Частые коды `rejected`: `validation_failed` (подробности в `errors`), `entity_deleted`, `id_conflict` (id занят чужой
сущностью), `account_not_found`, `category_not_found`, `category_kind_mismatch`, `account_has_transactions`,
`category_has_children`, `duplicate_category`, `budget_exists`, `invalid_payload`, `unknown_entity_type`.

## Pull

```http
GET /api/v1/sync/pull?since=1041&limit=500
```

```json
{
  "changes": [
    { "entityType": "transaction", "id": "…", "version": 1042, "deleted": false, "deletedAt": null,
      "updatedAt": "2026-10-22T10:15:31.002Z", "data": { "accountId": "…", "amount": 2450, "…": "…" } },
    { "entityType": "category", "id": "…", "version": 1043, "deleted": true, "deletedAt": "…", "updatedAt": "…", "data": null }
  ],
  "nextCursor": 1043,
  "hasMore": false
}
```

- Возвращаются все изменения с `version > since` по возрастанию версии, удалённые сущности тоже (`deleted: true`, `data: null`).
- `nextCursor` передаётся как `since` в следующий запрос. Если `hasMore = true`, сразу запрашивайте следующую страницу.
- Пропусков нет: версии одного пользователя коммитятся строго по порядку, а страница читается из одного снимка БД.
- В pull приходят и изменения, сделанные самим клиентом, уже нормализованные сервером. Также приходят данные, созданные
  сервером: категории по умолчанию, запланированные транзакции из регулярных правил, изменения через REST.

## Рекомендуемый алгоритм клиента

1. Любое изменение сначала пишется в локальную БД и в outbox: `entityType`, `id`, `operation`, `payload`, `clientUpdatedAt`.
   Повторное изменение той же сущности до отправки заменяет запись outbox (отправляется последнее состояние).
2. Синхронизация: push всего outbox пачками до 500. Принятые записи удаляются из outbox.
   - Если пришёл отказ `entity_deleted`, сущность удаляется локально.
   - При остальных отказах запись outbox помечается ошибкой и показывается пользователю.
   - Затем pull от сохранённого курсора, пока `hasMore`. Каждое изменение применяется к локальной БД, если для этой
     сущности нет неотправленной записи в outbox: локальная правка новее. Курсор сохраняется после каждой страницы.
3. Синхронизация запускается при старте, при появлении сети, по pull-to-refresh и периодически, пока приложение открыто.
   При ошибках — экспоненциальный backoff.

### Id вхождений регулярных правил

Если пользователь офлайн подтверждает вхождение регулярного платежа, у транзакции должен быть тот же id, что
сгенерировал бы сервер. Тогда push подтверждения сливается с серверной Planned-транзакцией, а не создаёт дубль.
Алгоритм — в `decisions.md`, пункт D28.
