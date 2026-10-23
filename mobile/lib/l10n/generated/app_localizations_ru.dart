// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Smallney';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get done => 'Готово';

  @override
  String get next => 'Дальше';

  @override
  String get back => 'Назад';

  @override
  String get close => 'Закрыть';

  @override
  String get retry => 'Повторить';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabTransactions => 'Операции';

  @override
  String get tabBudget => 'Бюджет';

  @override
  String get tabAnalytics => 'Аналитика';

  @override
  String get addTransaction => 'Добавить операцию';

  @override
  String get welcomeTitle => 'Деньги под контролем — даже без сети';

  @override
  String get welcomeSubtitle =>
      'Счета, бюджет и прогноз в одном месте. Всё работает офлайн и синхронизируется само.';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Пароль';

  @override
  String get passwordHint => 'Не меньше 8 символов';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get signIn => 'Войти';

  @override
  String get haveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get noAccount => 'Нет аккаунта? Создать';

  @override
  String get server => 'Сервер';

  @override
  String get serverHint => 'Адрес API, например https://finance.example.com';

  @override
  String get invalidEmail => 'Введите email';

  @override
  String get shortPassword => 'Не меньше 8 символов';

  @override
  String get wrongCredentials => 'Неверный email или пароль';

  @override
  String get emailTaken => 'Этот email уже зарегистрирован';

  @override
  String get networkError => 'Нет связи с сервером';

  @override
  String somethingWrong(String message) {
    return 'Что-то пошло не так: $message';
  }

  @override
  String get setupTitle => 'Настроим под вас';

  @override
  String get setupSubtitle => 'Итоги и бюджет считаются в базовой валюте.';

  @override
  String get monthStarts => 'Финансовый месяц начинается';

  @override
  String get calendarMonth => 'Обычный календарный месяц';

  @override
  String monthFromDay(int day, int prev) {
    return 'Месяц будет считаться с $day-го по $prev-е — удобно привязать к дню зарплаты';
  }

  @override
  String get firstAccountTitle => 'Первый счёт';

  @override
  String get firstAccountSubtitle => 'Остальные можно добавить позже.';

  @override
  String get accountName => 'Название';

  @override
  String currentBalance(String currency) {
    return 'Текущий остаток, $currency';
  }

  @override
  String get finish => 'Начать';

  @override
  String stepOf(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get defaultAccountName => 'Зарплатная карта';

  @override
  String get accountTypeCash => 'Наличные';

  @override
  String get accountTypeDebitCard => 'Дебетовая карта';

  @override
  String get accountTypeCreditCard => 'Кредитная карта';

  @override
  String get accountTypeSavings => 'Накопительный';

  @override
  String get accountTypeDeposit => 'Вклад';

  @override
  String get accountTypeInvestment => 'Инвестиции';

  @override
  String get financialMonth => 'Финансовый месяц';

  @override
  String get totalCapital => 'Общий капитал';

  @override
  String get accounts => 'Счета';

  @override
  String allCount(int count) {
    return 'Все $count';
  }

  @override
  String get addAccount => 'Добавить счёт';

  @override
  String get recentTransactions => 'Последние операции';

  @override
  String get noTransactionsYet => 'Операций пока нет';

  @override
  String get noTransactionsHint => 'Нажмите «+», чтобы добавить первую';

  @override
  String get justNow => 'только что';

  @override
  String minutesAgo(int n) {
    return '$n мин назад';
  }

  @override
  String hoursAgo(int n) {
    return '$n ч назад';
  }

  @override
  String daysAgo(int n) {
    return '$n дн назад';
  }

  @override
  String get notSyncedYet => 'ещё не синхронизировано';

  @override
  String get offline => 'офлайн';

  @override
  String get syncing => 'синхронизация…';

  @override
  String get settings => 'Настройки';

  @override
  String approximately(String amount) {
    return '≈ $amount';
  }

  @override
  String noRateFor(String currency) {
    return 'нет курса для $currency';
  }

  @override
  String get searchHint => 'Поиск по заметке и тегам';

  @override
  String get filters => 'Фильтры';

  @override
  String incomeTotal(String period) {
    return 'Доходы · $period';
  }

  @override
  String expenseTotal(String period) {
    return 'Расходы · $period';
  }

  @override
  String get allAccounts => 'Все счета';

  @override
  String get allTime => 'Всё время';

  @override
  String get expenses => 'Расходы';

  @override
  String get incomes => 'Доходы';

  @override
  String get transfers => 'Переводы';

  @override
  String get duplicate => 'Повторить';

  @override
  String get transactionDeleted => 'Операция удалена';

  @override
  String get transactionDuplicated => 'Операция повторена сегодня';

  @override
  String get planned => 'Запланировано · подтвердите';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get transfer => 'Перевод';

  @override
  String get expense => 'Расход';

  @override
  String get income => 'Доход';

  @override
  String get recentFirst => 'Недавние первыми';

  @override
  String get allCategories => 'Все';

  @override
  String get categories => 'Категории';

  @override
  String get note => 'Заметка';

  @override
  String get noteHint => 'Например, «Евроопт»';

  @override
  String get from => 'Откуда';

  @override
  String get to => 'Куда';

  @override
  String creditedAmount(String currency) {
    return 'Зачислится, $currency';
  }

  @override
  String byTodayRate(String amount) {
    return 'По курсу НБРБ на сегодня ≈ $amount';
  }

  @override
  String saveWithAmount(String amount) {
    return 'Сохранить · $amount';
  }

  @override
  String get savedOffline => 'Сохранено · отправится при синхронизации';

  @override
  String get chooseAccount => 'Выберите счёт';

  @override
  String get noAccountsYet => 'Сначала добавьте счёт';

  @override
  String get editTransaction => 'Операция';

  @override
  String get deleteTransactionConfirm => 'Удалить эту операцию?';

  @override
  String get tags => 'Теги';

  @override
  String get tagsHint => 'через запятую';

  @override
  String get date => 'Дата';

  @override
  String get sameAccount => 'Выберите другой счёт';

  @override
  String get accountsTitle => 'Счета';

  @override
  String get newAccount => 'Новый счёт';

  @override
  String get editAccount => 'Счёт';

  @override
  String get accountType => 'Тип';

  @override
  String get currency => 'Валюта';

  @override
  String get initialBalance => 'Начальный остаток';

  @override
  String get includeInTotals => 'Учитывать в общем капитале';

  @override
  String get archived => 'В архиве';

  @override
  String get showArchived => 'Показать архив';

  @override
  String get creditLimit => 'Кредитный лимит';

  @override
  String get interestRate => 'Ставка, % годовых';

  @override
  String get capitalization => 'Капитализация';

  @override
  String get capNone => 'Без капитализации';

  @override
  String get capMonthly => 'Ежемесячно';

  @override
  String get capQuarterly => 'Ежеквартально';

  @override
  String get capAtEnd => 'В конце срока';

  @override
  String get openDate => 'Дата открытия';

  @override
  String get maturityDate => 'Дата окончания';

  @override
  String get notSet => 'не задана';

  @override
  String get archive => 'В архив';

  @override
  String get unarchive => 'Вернуть из архива';

  @override
  String get deleteAccount => 'Удалить счёт';

  @override
  String deleteAccountConfirm(String name) {
    return 'Удалить счёт «$name»?';
  }

  @override
  String get accountHasTransactions =>
      'У счёта есть операции — его можно только убрать в архив';

  @override
  String get nameRequired => 'Введите название';

  @override
  String get invalidAmount => 'Неверная сумма';

  @override
  String creditLimitShort(String amount) {
    return 'лимит $amount';
  }

  @override
  String interestShort(String rate) {
    return '$rate%';
  }

  @override
  String get noAccountsTitle => 'Счетов пока нет';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get sync => 'Синхронизация';

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String lastSync(String time) {
    return 'Последняя синхронизация: $time';
  }

  @override
  String get neverSynced => 'Ещё не синхронизировалось';

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count изменений ждут отправки',
      few: '$count изменения ждут отправки',
      one: '$count изменение ждёт отправки',
    );
    return '$_temp0';
  }

  @override
  String get allSynced => 'Всё синхронизировано';

  @override
  String get failedChanges => 'Сервер не принял изменения';

  @override
  String get discardChange => 'Отменить изменение';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm =>
      'Выйти из аккаунта? Данные на этом устройстве будут удалены, на сервере всё сохранится.';

  @override
  String get baseCurrency => 'Базовая валюта';

  @override
  String get firstDayOfMonth => 'Начало месяца';

  @override
  String dayN(int day) {
    return '$day-е число';
  }

  @override
  String get comingSoonTitle => 'Скоро здесь';

  @override
  String get comingSoonBudget =>
      'Бюджет месяца появится в следующем обновлении.';

  @override
  String get comingSoonAnalytics =>
      'Аналитика появится в одном из следующих обновлений.';

  @override
  String dayToday(String date) {
    return 'Сегодня, $date';
  }

  @override
  String dayYesterday(String date) {
    return 'Вчера, $date';
  }
}
