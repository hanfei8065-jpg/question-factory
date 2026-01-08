import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LEARNEST'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get homeTab;

  /// No description provided for @startAction.
  ///
  /// In en, this message translates to:
  /// **'INITIATE SESSION'**
  String get startAction;

  /// No description provided for @languageSelect.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE / 语言'**
  String get languageSelect;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'SCAN'**
  String get navScan;

  /// No description provided for @navBank.
  ///
  /// In en, this message translates to:
  /// **'BANK'**
  String get navBank;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get navProfile;

  /// No description provided for @catMath.
  ///
  /// In en, this message translates to:
  /// **'MATH'**
  String get catMath;

  /// No description provided for @catPhysics.
  ///
  /// In en, this message translates to:
  /// **'PHYS'**
  String get catPhysics;

  /// No description provided for @catChem.
  ///
  /// In en, this message translates to:
  /// **'CHEM'**
  String get catChem;

  /// No description provided for @catOly.
  ///
  /// In en, this message translates to:
  /// **'OLYM'**
  String get catOly;

  /// No description provided for @dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'SELECT SOURCE'**
  String get dialogTitle;

  /// No description provided for @dialogImage.
  ///
  /// In en, this message translates to:
  /// **'PHOTO LIBRARY'**
  String get dialogImage;

  /// No description provided for @dialogPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF DOCUMENT'**
  String get dialogPdf;

  /// No description provided for @devProgress.
  ///
  /// In en, this message translates to:
  /// **'WORK IN PROGRESS...'**
  String get devProgress;

  /// No description provided for @langCN.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get langCN;

  /// No description provided for @langEN.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEN;

  /// No description provided for @langJA.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get langJA;

  /// No description provided for @langES.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langES;

  /// No description provided for @promoCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promoCodeTitle;

  /// No description provided for @promoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get promoCodeHint;

  /// No description provided for @promoCodeApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get promoCodeApply;
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
      <String>['en', 'es', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
