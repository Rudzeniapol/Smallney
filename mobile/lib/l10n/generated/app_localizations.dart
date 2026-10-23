import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Smallney'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Дальше'**
  String get next;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get yesterday;

  /// No description provided for @tabHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get tabHome;

  /// No description provided for @tabTransactions.
  ///
  /// In ru, this message translates to:
  /// **'Операции'**
  String get tabTransactions;

  /// No description provided for @tabBudget.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет'**
  String get tabBudget;

  /// No description provided for @tabAnalytics.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get tabAnalytics;

  /// No description provided for @addTransaction.
  ///
  /// In ru, this message translates to:
  /// **'Добавить операцию'**
  String get addTransaction;

  /// No description provided for @welcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Деньги под контролем — даже без сети'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Счета, бюджет и прогноз в одном месте. Всё работает офлайн и синхронизируется само.'**
  String get welcomeSubtitle;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In ru, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In ru, this message translates to:
  /// **'Не меньше 8 символов'**
  String get passwordHint;

  /// No description provided for @createAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signIn;

  /// No description provided for @haveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? Войти'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? Создать'**
  String get noAccount;

  /// No description provided for @server.
  ///
  /// In ru, this message translates to:
  /// **'Сервер'**
  String get server;

  /// No description provided for @serverHint.
  ///
  /// In ru, this message translates to:
  /// **'Адрес API, например https://finance.example.com'**
  String get serverHint;

  /// No description provided for @invalidEmail.
  ///
  /// In ru, this message translates to:
  /// **'Введите email'**
  String get invalidEmail;

  /// No description provided for @shortPassword.
  ///
  /// In ru, this message translates to:
  /// **'Не меньше 8 символов'**
  String get shortPassword;

  /// No description provided for @wrongCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль'**
  String get wrongCredentials;

  /// No description provided for @emailTaken.
  ///
  /// In ru, this message translates to:
  /// **'Этот email уже зарегистрирован'**
  String get emailTaken;

  /// No description provided for @networkError.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером'**
  String get networkError;

  /// No description provided for @somethingWrong.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так: {message}'**
  String somethingWrong(String message);

  /// No description provided for @setupTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настроим под вас'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Итоги и бюджет считаются в базовой валюте.'**
  String get setupSubtitle;

  /// No description provided for @monthStarts.
  ///
  /// In ru, this message translates to:
  /// **'Финансовый месяц начинается'**
  String get monthStarts;

  /// No description provided for @calendarMonth.
  ///
  /// In ru, this message translates to:
  /// **'Обычный календарный месяц'**
  String get calendarMonth;

  /// No description provided for @monthFromDay.
  ///
  /// In ru, this message translates to:
  /// **'Месяц будет считаться с {day}-го по {prev}-е — удобно привязать к дню зарплаты'**
  String monthFromDay(int day, int prev);

  /// No description provided for @firstAccountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Первый счёт'**
  String get firstAccountTitle;

  /// No description provided for @firstAccountSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Остальные можно добавить позже.'**
  String get firstAccountSubtitle;

  /// No description provided for @accountName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get accountName;

  /// No description provided for @currentBalance.
  ///
  /// In ru, this message translates to:
  /// **'Текущий остаток, {currency}'**
  String currentBalance(String currency);

  /// No description provided for @finish.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get finish;

  /// No description provided for @stepOf.
  ///
  /// In ru, this message translates to:
  /// **'Шаг {step} из {total}'**
  String stepOf(int step, int total);

  /// No description provided for @defaultAccountName.
  ///
  /// In ru, this message translates to:
  /// **'Зарплатная карта'**
  String get defaultAccountName;

  /// No description provided for @accountTypeCash.
  ///
  /// In ru, this message translates to:
  /// **'Наличные'**
  String get accountTypeCash;

  /// No description provided for @accountTypeDebitCard.
  ///
  /// In ru, this message translates to:
  /// **'Дебетовая карта'**
  String get accountTypeDebitCard;

  /// No description provided for @accountTypeCreditCard.
  ///
  /// In ru, this message translates to:
  /// **'Кредитная карта'**
  String get accountTypeCreditCard;

  /// No description provided for @accountTypeSavings.
  ///
  /// In ru, this message translates to:
  /// **'Накопительный'**
  String get accountTypeSavings;

  /// No description provided for @accountTypeDeposit.
  ///
  /// In ru, this message translates to:
  /// **'Вклад'**
  String get accountTypeDeposit;

  /// No description provided for @accountTypeInvestment.
  ///
  /// In ru, this message translates to:
  /// **'Инвестиции'**
  String get accountTypeInvestment;

  /// No description provided for @financialMonth.
  ///
  /// In ru, this message translates to:
  /// **'Финансовый месяц'**
  String get financialMonth;

  /// No description provided for @totalCapital.
  ///
  /// In ru, this message translates to:
  /// **'Общий капитал'**
  String get totalCapital;

  /// No description provided for @accounts.
  ///
  /// In ru, this message translates to:
  /// **'Счета'**
  String get accounts;

  /// No description provided for @allCount.
  ///
  /// In ru, this message translates to:
  /// **'Все {count}'**
  String allCount(int count);

  /// No description provided for @addAccount.
  ///
  /// In ru, this message translates to:
  /// **'Добавить счёт'**
  String get addAccount;

  /// No description provided for @recentTransactions.
  ///
  /// In ru, this message translates to:
  /// **'Последние операции'**
  String get recentTransactions;

  /// No description provided for @noTransactionsYet.
  ///
  /// In ru, this message translates to:
  /// **'Операций пока нет'**
  String get noTransactionsYet;

  /// No description provided for @noTransactionsHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите «+», чтобы добавить первую'**
  String get noTransactionsHint;

  /// No description provided for @justNow.
  ///
  /// In ru, this message translates to:
  /// **'только что'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'{n} мин назад'**
  String minutesAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'{n} ч назад'**
  String hoursAgo(int n);

  /// No description provided for @daysAgo.
  ///
  /// In ru, this message translates to:
  /// **'{n} дн назад'**
  String daysAgo(int n);

  /// No description provided for @notSyncedYet.
  ///
  /// In ru, this message translates to:
  /// **'ещё не синхронизировано'**
  String get notSyncedYet;

  /// No description provided for @offline.
  ///
  /// In ru, this message translates to:
  /// **'офлайн'**
  String get offline;

  /// No description provided for @syncing.
  ///
  /// In ru, this message translates to:
  /// **'синхронизация…'**
  String get syncing;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @approximately.
  ///
  /// In ru, this message translates to:
  /// **'≈ {amount}'**
  String approximately(String amount);

  /// No description provided for @noRateFor.
  ///
  /// In ru, this message translates to:
  /// **'нет курса для {currency}'**
  String noRateFor(String currency);

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по заметке и тегам'**
  String get searchHint;

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @incomeTotal.
  ///
  /// In ru, this message translates to:
  /// **'Доходы · {period}'**
  String incomeTotal(String period);

  /// No description provided for @expenseTotal.
  ///
  /// In ru, this message translates to:
  /// **'Расходы · {period}'**
  String expenseTotal(String period);

  /// No description provided for @allAccounts.
  ///
  /// In ru, this message translates to:
  /// **'Все счета'**
  String get allAccounts;

  /// No description provided for @allTime.
  ///
  /// In ru, this message translates to:
  /// **'Всё время'**
  String get allTime;

  /// No description provided for @expenses.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get expenses;

  /// No description provided for @incomes.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get incomes;

  /// No description provided for @transfers.
  ///
  /// In ru, this message translates to:
  /// **'Переводы'**
  String get transfers;

  /// No description provided for @duplicate.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get duplicate;

  /// No description provided for @transactionDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Операция удалена'**
  String get transactionDeleted;

  /// No description provided for @transactionDuplicated.
  ///
  /// In ru, this message translates to:
  /// **'Операция повторена сегодня'**
  String get transactionDuplicated;

  /// No description provided for @planned.
  ///
  /// In ru, this message translates to:
  /// **'Запланировано · подтвердите'**
  String get planned;

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get nothingFound;

  /// No description provided for @transfer.
  ///
  /// In ru, this message translates to:
  /// **'Перевод'**
  String get transfer;

  /// No description provided for @expense.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get income;

  /// No description provided for @recentFirst.
  ///
  /// In ru, this message translates to:
  /// **'Недавние первыми'**
  String get recentFirst;

  /// No description provided for @allCategories.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get allCategories;

  /// No description provided for @categories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get categories;

  /// No description provided for @note.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, «Евроопт»'**
  String get noteHint;

  /// No description provided for @from.
  ///
  /// In ru, this message translates to:
  /// **'Откуда'**
  String get from;

  /// No description provided for @to.
  ///
  /// In ru, this message translates to:
  /// **'Куда'**
  String get to;

  /// No description provided for @creditedAmount.
  ///
  /// In ru, this message translates to:
  /// **'Зачислится, {currency}'**
  String creditedAmount(String currency);

  /// No description provided for @byTodayRate.
  ///
  /// In ru, this message translates to:
  /// **'По курсу НБРБ на сегодня ≈ {amount}'**
  String byTodayRate(String amount);

  /// No description provided for @saveWithAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить · {amount}'**
  String saveWithAmount(String amount);

  /// No description provided for @savedOffline.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено · отправится при синхронизации'**
  String get savedOffline;

  /// No description provided for @chooseAccount.
  ///
  /// In ru, this message translates to:
  /// **'Выберите счёт'**
  String get chooseAccount;

  /// No description provided for @noAccountsYet.
  ///
  /// In ru, this message translates to:
  /// **'Сначала добавьте счёт'**
  String get noAccountsYet;

  /// No description provided for @editTransaction.
  ///
  /// In ru, this message translates to:
  /// **'Операция'**
  String get editTransaction;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить эту операцию?'**
  String get deleteTransactionConfirm;

  /// No description provided for @tags.
  ///
  /// In ru, this message translates to:
  /// **'Теги'**
  String get tags;

  /// No description provided for @tagsHint.
  ///
  /// In ru, this message translates to:
  /// **'через запятую'**
  String get tagsHint;

  /// No description provided for @date.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get date;

  /// No description provided for @sameAccount.
  ///
  /// In ru, this message translates to:
  /// **'Выберите другой счёт'**
  String get sameAccount;

  /// No description provided for @accountsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Счета'**
  String get accountsTitle;

  /// No description provided for @newAccount.
  ///
  /// In ru, this message translates to:
  /// **'Новый счёт'**
  String get newAccount;

  /// No description provided for @editAccount.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get editAccount;

  /// No description provided for @accountType.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get accountType;

  /// No description provided for @currency.
  ///
  /// In ru, this message translates to:
  /// **'Валюта'**
  String get currency;

  /// No description provided for @initialBalance.
  ///
  /// In ru, this message translates to:
  /// **'Начальный остаток'**
  String get initialBalance;

  /// No description provided for @includeInTotals.
  ///
  /// In ru, this message translates to:
  /// **'Учитывать в общем капитале'**
  String get includeInTotals;

  /// No description provided for @archived.
  ///
  /// In ru, this message translates to:
  /// **'В архиве'**
  String get archived;

  /// No description provided for @showArchived.
  ///
  /// In ru, this message translates to:
  /// **'Показать архив'**
  String get showArchived;

  /// No description provided for @creditLimit.
  ///
  /// In ru, this message translates to:
  /// **'Кредитный лимит'**
  String get creditLimit;

  /// No description provided for @interestRate.
  ///
  /// In ru, this message translates to:
  /// **'Ставка, % годовых'**
  String get interestRate;

  /// No description provided for @capitalization.
  ///
  /// In ru, this message translates to:
  /// **'Капитализация'**
  String get capitalization;

  /// No description provided for @capNone.
  ///
  /// In ru, this message translates to:
  /// **'Без капитализации'**
  String get capNone;

  /// No description provided for @capMonthly.
  ///
  /// In ru, this message translates to:
  /// **'Ежемесячно'**
  String get capMonthly;

  /// No description provided for @capQuarterly.
  ///
  /// In ru, this message translates to:
  /// **'Ежеквартально'**
  String get capQuarterly;

  /// No description provided for @capAtEnd.
  ///
  /// In ru, this message translates to:
  /// **'В конце срока'**
  String get capAtEnd;

  /// No description provided for @openDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата открытия'**
  String get openDate;

  /// No description provided for @maturityDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания'**
  String get maturityDate;

  /// No description provided for @notSet.
  ///
  /// In ru, this message translates to:
  /// **'не задана'**
  String get notSet;

  /// No description provided for @archive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть из архива'**
  String get unarchive;

  /// No description provided for @deleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить счёт'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить счёт «{name}»?'**
  String deleteAccountConfirm(String name);

  /// No description provided for @accountHasTransactions.
  ///
  /// In ru, this message translates to:
  /// **'У счёта есть операции — его можно только убрать в архив'**
  String get accountHasTransactions;

  /// No description provided for @nameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите название'**
  String get nameRequired;

  /// No description provided for @invalidAmount.
  ///
  /// In ru, this message translates to:
  /// **'Неверная сумма'**
  String get invalidAmount;

  /// No description provided for @creditLimitShort.
  ///
  /// In ru, this message translates to:
  /// **'лимит {amount}'**
  String creditLimitShort(String amount);

  /// No description provided for @interestShort.
  ///
  /// In ru, this message translates to:
  /// **'{rate}%'**
  String interestShort(String rate);

  /// No description provided for @noAccountsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Счетов пока нет'**
  String get noAccountsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @sync.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация'**
  String get sync;

  /// No description provided for @syncNow.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировать'**
  String get syncNow;

  /// No description provided for @lastSync.
  ///
  /// In ru, this message translates to:
  /// **'Последняя синхронизация: {time}'**
  String lastSync(String time);

  /// No description provided for @neverSynced.
  ///
  /// In ru, this message translates to:
  /// **'Ещё не синхронизировалось'**
  String get neverSynced;

  /// No description provided for @pendingChanges.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} изменение ждёт отправки} few{{count} изменения ждут отправки} other{{count} изменений ждут отправки}}'**
  String pendingChanges(int count);

  /// No description provided for @allSynced.
  ///
  /// In ru, this message translates to:
  /// **'Всё синхронизировано'**
  String get allSynced;

  /// No description provided for @failedChanges.
  ///
  /// In ru, this message translates to:
  /// **'Сервер не принял изменения'**
  String get failedChanges;

  /// No description provided for @discardChange.
  ///
  /// In ru, this message translates to:
  /// **'Отменить изменение'**
  String get discardChange;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта? Данные на этом устройстве будут удалены, на сервере всё сохранится.'**
  String get logoutConfirm;

  /// No description provided for @baseCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Базовая валюта'**
  String get baseCurrency;

  /// No description provided for @firstDayOfMonth.
  ///
  /// In ru, this message translates to:
  /// **'Начало месяца'**
  String get firstDayOfMonth;

  /// No description provided for @dayN.
  ///
  /// In ru, this message translates to:
  /// **'{day}-е число'**
  String dayN(int day);

  /// No description provided for @comingSoonTitle.
  ///
  /// In ru, this message translates to:
  /// **'Скоро здесь'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBudget.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет месяца появится в следующем обновлении.'**
  String get comingSoonBudget;

  /// No description provided for @comingSoonAnalytics.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика появится в одном из следующих обновлений.'**
  String get comingSoonAnalytics;

  /// No description provided for @dayToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня, {date}'**
  String dayToday(String date);

  /// No description provided for @dayYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера, {date}'**
  String dayYesterday(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
