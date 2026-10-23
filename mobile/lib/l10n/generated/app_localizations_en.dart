// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smallney';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTransactions => 'Activity';

  @override
  String get tabBudget => 'Budget';

  @override
  String get tabAnalytics => 'Insights';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get welcomeTitle => 'Your money in check — even offline';

  @override
  String get welcomeSubtitle =>
      'Accounts, budget and forecast in one place. Works offline and syncs by itself.';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get createAccount => 'Create account';

  @override
  String get signIn => 'Sign in';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get noAccount => 'No account yet? Create one';

  @override
  String get server => 'Server';

  @override
  String get serverHint => 'API address, e.g. https://finance.example.com';

  @override
  String get invalidEmail => 'Enter your email';

  @override
  String get shortPassword => 'At least 8 characters';

  @override
  String get wrongCredentials => 'Wrong email or password';

  @override
  String get emailTaken => 'This email is already registered';

  @override
  String get networkError => 'Can\'t reach the server';

  @override
  String somethingWrong(String message) {
    return 'Something went wrong: $message';
  }

  @override
  String get setupTitle => 'Make it yours';

  @override
  String get setupSubtitle => 'Totals and budgets use the base currency.';

  @override
  String get monthStarts => 'Your financial month starts on';

  @override
  String get calendarMonth => 'A regular calendar month';

  @override
  String monthFromDay(int day, int prev) {
    return 'Months run from day $day to day $prev — handy for your payday';
  }

  @override
  String get firstAccountTitle => 'Your first account';

  @override
  String get firstAccountSubtitle => 'You can add more later.';

  @override
  String get accountName => 'Name';

  @override
  String currentBalance(String currency) {
    return 'Current balance, $currency';
  }

  @override
  String get finish => 'Get started';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get defaultAccountName => 'Main card';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeDebitCard => 'Debit card';

  @override
  String get accountTypeCreditCard => 'Credit card';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountTypeDeposit => 'Deposit';

  @override
  String get accountTypeInvestment => 'Investments';

  @override
  String get financialMonth => 'Financial month';

  @override
  String get totalCapital => 'Net worth';

  @override
  String get accounts => 'Accounts';

  @override
  String allCount(int count) {
    return 'All $count';
  }

  @override
  String get addAccount => 'Add account';

  @override
  String get recentTransactions => 'Recent activity';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get noTransactionsHint => 'Tap “+” to add the first one';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String hoursAgo(int n) {
    return '$n h ago';
  }

  @override
  String daysAgo(int n) {
    return '$n d ago';
  }

  @override
  String get notSyncedYet => 'not synced yet';

  @override
  String get offline => 'offline';

  @override
  String get syncing => 'syncing…';

  @override
  String get settings => 'Settings';

  @override
  String approximately(String amount) {
    return '≈ $amount';
  }

  @override
  String noRateFor(String currency) {
    return 'no rate for $currency';
  }

  @override
  String get searchHint => 'Search notes and tags';

  @override
  String get filters => 'Filters';

  @override
  String incomeTotal(String period) {
    return 'Income · $period';
  }

  @override
  String expenseTotal(String period) {
    return 'Spending · $period';
  }

  @override
  String get allAccounts => 'All accounts';

  @override
  String get allTime => 'All time';

  @override
  String get expenses => 'Spending';

  @override
  String get incomes => 'Income';

  @override
  String get transfers => 'Transfers';

  @override
  String get duplicate => 'Repeat';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transactionDuplicated => 'Repeated for today';

  @override
  String get planned => 'Planned · confirm';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get transfer => 'Transfer';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get recentFirst => 'Recent first';

  @override
  String get allCategories => 'All';

  @override
  String get categories => 'Categories';

  @override
  String get note => 'Note';

  @override
  String get noteHint => 'E.g. “Groceries”';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String creditedAmount(String currency) {
    return 'Credited, $currency';
  }

  @override
  String byTodayRate(String amount) {
    return 'At today\'s rate ≈ $amount';
  }

  @override
  String saveWithAmount(String amount) {
    return 'Save · $amount';
  }

  @override
  String get savedOffline => 'Saved · will sync automatically';

  @override
  String get chooseAccount => 'Choose an account';

  @override
  String get noAccountsYet => 'Add an account first';

  @override
  String get editTransaction => 'Transaction';

  @override
  String get deleteTransactionConfirm => 'Delete this transaction?';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHint => 'comma separated';

  @override
  String get date => 'Date';

  @override
  String get sameAccount => 'Choose another account';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get newAccount => 'New account';

  @override
  String get editAccount => 'Account';

  @override
  String get accountType => 'Type';

  @override
  String get currency => 'Currency';

  @override
  String get initialBalance => 'Starting balance';

  @override
  String get includeInTotals => 'Include in net worth';

  @override
  String get archived => 'Archived';

  @override
  String get showArchived => 'Show archived';

  @override
  String get creditLimit => 'Credit limit';

  @override
  String get interestRate => 'Interest, % a year';

  @override
  String get capitalization => 'Compounding';

  @override
  String get capNone => 'None';

  @override
  String get capMonthly => 'Monthly';

  @override
  String get capQuarterly => 'Quarterly';

  @override
  String get capAtEnd => 'At maturity';

  @override
  String get openDate => 'Opened';

  @override
  String get maturityDate => 'Matures';

  @override
  String get notSet => 'not set';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String deleteAccountConfirm(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get accountHasTransactions =>
      'This account has transactions — you can only archive it';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String creditLimitShort(String amount) {
    return 'limit $amount';
  }

  @override
  String interestShort(String rate) {
    return '$rate%';
  }

  @override
  String get noAccountsTitle => 'No accounts yet';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sync => 'Sync';

  @override
  String get syncNow => 'Sync now';

  @override
  String lastSync(String time) {
    return 'Last synced $time';
  }

  @override
  String get neverSynced => 'Not synced yet';

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting',
      one: '$count change waiting',
    );
    return '$_temp0';
  }

  @override
  String get allSynced => 'Everything is synced';

  @override
  String get failedChanges => 'The server rejected changes';

  @override
  String get discardChange => 'Discard change';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirm =>
      'Sign out? Data on this device will be removed; everything stays on the server.';

  @override
  String get baseCurrency => 'Base currency';

  @override
  String get firstDayOfMonth => 'Month starts';

  @override
  String dayN(int day) {
    return 'day $day';
  }

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBudget =>
      'The monthly budget arrives in the next update.';

  @override
  String get comingSoonAnalytics => 'Insights arrive in an upcoming update.';

  @override
  String dayToday(String date) {
    return 'Today, $date';
  }

  @override
  String dayYesterday(String date) {
    return 'Yesterday, $date';
  }
}
