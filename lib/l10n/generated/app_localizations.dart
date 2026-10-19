import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'MyTimer'**
  String get appTitle;

  /// No description provided for @tabata.
  ///
  /// In tr, this message translates to:
  /// **'TABATA'**
  String get tabata;

  /// No description provided for @rounds.
  ///
  /// In tr, this message translates to:
  /// **'TUR & WOD'**
  String get rounds;

  /// No description provided for @stopwatch.
  ///
  /// In tr, this message translates to:
  /// **'KRONOMETRE'**
  String get stopwatch;

  /// No description provided for @custom.
  ///
  /// In tr, this message translates to:
  /// **'ÖZEL TİMER'**
  String get custom;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'AYARLAR'**
  String get settings;

  /// No description provided for @work.
  ///
  /// In tr, this message translates to:
  /// **'ÇALIŞMA'**
  String get work;

  /// No description provided for @rest.
  ///
  /// In tr, this message translates to:
  /// **'DİNLENME'**
  String get rest;

  /// No description provided for @prep.
  ///
  /// In tr, this message translates to:
  /// **'HAZIRLIK'**
  String get prep;

  /// No description provided for @cooldown.
  ///
  /// In tr, this message translates to:
  /// **'SOĞUMA'**
  String get cooldown;

  /// No description provided for @round.
  ///
  /// In tr, this message translates to:
  /// **'TUR'**
  String get round;

  /// No description provided for @set.
  ///
  /// In tr, this message translates to:
  /// **'SET'**
  String get set;

  /// No description provided for @completed.
  ///
  /// In tr, this message translates to:
  /// **'TAMAMLANDI!'**
  String get completed;

  /// No description provided for @paused.
  ///
  /// In tr, this message translates to:
  /// **'DURAKLATILDI'**
  String get paused;

  /// No description provided for @ready.
  ///
  /// In tr, this message translates to:
  /// **'HAZIR OL'**
  String get ready;

  /// No description provided for @finished.
  ///
  /// In tr, this message translates to:
  /// **'TEBRİKLER! ANTRENMAN BİTTİ'**
  String get finished;

  /// No description provided for @start.
  ///
  /// In tr, this message translates to:
  /// **'BAŞLAT'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In tr, this message translates to:
  /// **'DURAKLAT'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In tr, this message translates to:
  /// **'DEVAM ET'**
  String get resume;

  /// No description provided for @reset.
  ///
  /// In tr, this message translates to:
  /// **'SIFIRLA'**
  String get reset;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'İLERİ ATLA'**
  String get skip;

  /// No description provided for @lap.
  ///
  /// In tr, this message translates to:
  /// **'TUR AT'**
  String get lap;

  /// No description provided for @workTime.
  ///
  /// In tr, this message translates to:
  /// **'ÇALIŞMA SÜRESİ'**
  String get workTime;

  /// No description provided for @restTime.
  ///
  /// In tr, this message translates to:
  /// **'DİNLENME SÜRESİ'**
  String get restTime;

  /// No description provided for @prepTime.
  ///
  /// In tr, this message translates to:
  /// **'HAZIRLANMA SÜRESİ'**
  String get prepTime;

  /// No description provided for @totalRounds.
  ///
  /// In tr, this message translates to:
  /// **'TOPLAM TUR'**
  String get totalRounds;

  /// No description provided for @totalSets.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Set'**
  String get totalSets;

  /// No description provided for @restBetweenSets.
  ///
  /// In tr, this message translates to:
  /// **'Setler Arası Dinlenme'**
  String get restBetweenSets;

  /// No description provided for @timeCap.
  ///
  /// In tr, this message translates to:
  /// **'ZAMAN SINIRI (TIME CAP)'**
  String get timeCap;

  /// No description provided for @sound.
  ///
  /// In tr, this message translates to:
  /// **'Ses Efektleri'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim'**
  String get vibration;

  /// No description provided for @keepScreenOn.
  ///
  /// In tr, this message translates to:
  /// **'Ekranı Açık Tut'**
  String get keepScreenOn;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'DİL / LANGUAGE'**
  String get language;

  /// No description provided for @emomTitle.
  ///
  /// In tr, this message translates to:
  /// **'EMOM'**
  String get emomTitle;

  /// No description provided for @amrapTitle.
  ///
  /// In tr, this message translates to:
  /// **'AMRAP'**
  String get amrapTitle;

  /// No description provided for @forTimeTitle.
  ///
  /// In tr, this message translates to:
  /// **'FOR TIME'**
  String get forTimeTitle;

  /// No description provided for @customRoutines.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı Özel Timerlar'**
  String get customRoutines;

  /// No description provided for @createNewRoutine.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Özel Timer Oluştur'**
  String get createNewRoutine;

  /// No description provided for @routineName.
  ///
  /// In tr, this message translates to:
  /// **'Timer Adı'**
  String get routineName;

  /// No description provided for @routineNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Fran, Murph, 5x5 Interval'**
  String get routineNameHint;

  /// No description provided for @addInterval.
  ///
  /// In tr, this message translates to:
  /// **'Aralık Ekle'**
  String get addInterval;

  /// No description provided for @intervalName.
  ///
  /// In tr, this message translates to:
  /// **'Aralık Adı'**
  String get intervalName;

  /// No description provided for @intervalDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süre (sn)'**
  String get intervalDuration;

  /// No description provided for @intervalType.
  ///
  /// In tr, this message translates to:
  /// **'Aralık Tipi'**
  String get intervalType;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'KAYDET'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İPTAL'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'SİL'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'DÜZENLE'**
  String get edit;

  /// No description provided for @noCustomRoutines.
  ///
  /// In tr, this message translates to:
  /// **'Henüz özel bir timer oluşturmadınız. Hemen ekleyin!'**
  String get noCustomRoutines;

  /// No description provided for @confirmDelete.
  ///
  /// In tr, this message translates to:
  /// **'Bu timer\'\'ı silmek istediğinize emin misiniz?'**
  String get confirmDelete;

  /// No description provided for @cloudSyncNotice.
  ///
  /// In tr, this message translates to:
  /// **'Timerlarınız cihazınızda saklanır. Backend bağlantısı eklendiğinde bulutla senkronize edilecektir.'**
  String get cloudSyncNotice;

  /// No description provided for @lapTimes.
  ///
  /// In tr, this message translates to:
  /// **'Tur Zamanları'**
  String get lapTimes;

  /// No description provided for @fastestLap.
  ///
  /// In tr, this message translates to:
  /// **'En Hızlı Tur'**
  String get fastestLap;

  /// No description provided for @slowestLap.
  ///
  /// In tr, this message translates to:
  /// **'En Yavaş Tur'**
  String get slowestLap;

  /// No description provided for @totalTime.
  ///
  /// In tr, this message translates to:
  /// **'TOPLAM SÜRE'**
  String get totalTime;

  /// No description provided for @roundTime.
  ///
  /// In tr, this message translates to:
  /// **'Tur Süresi'**
  String get roundTime;

  /// No description provided for @general.
  ///
  /// In tr, this message translates to:
  /// **'GENEL'**
  String get general;

  /// No description provided for @soundSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Geri sayım ve aralık geçiş sinyalleri'**
  String get soundSubtitle;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aralık geçişlerinde haptik geri bildirim'**
  String get vibrationSubtitle;

  /// No description provided for @keepScreenOnSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Antrenman sırasında telefon ekranı kapanmaz'**
  String get keepScreenOnSubtitle;

  /// No description provided for @soundTest.
  ///
  /// In tr, this message translates to:
  /// **'SES TESTİ'**
  String get soundTest;

  /// No description provided for @countdown.
  ///
  /// In tr, this message translates to:
  /// **'Geri Sayım'**
  String get countdown;

  /// No description provided for @appLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get appLanguage;

  /// No description provided for @aboutTitle.
  ///
  /// In tr, this message translates to:
  /// **'HAKKINDA'**
  String get aboutTitle;

  /// No description provided for @aboutDesc.
  ///
  /// In tr, this message translates to:
  /// **'CrossFit ve fonksiyonel fitness antrenmanları için tasarlandı.'**
  String get aboutDesc;

  /// No description provided for @seconds.
  ///
  /// In tr, this message translates to:
  /// **'sn'**
  String get seconds;

  /// No description provided for @minutes.
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get minutes;

  /// No description provided for @totalRoundsStat.
  ///
  /// In tr, this message translates to:
  /// **'TUR SAYISI'**
  String get totalRoundsStat;

  /// No description provided for @workRestStat.
  ///
  /// In tr, this message translates to:
  /// **'ÇALIŞMA/DİNLENME'**
  String get workRestStat;

  /// No description provided for @startWorkout.
  ///
  /// In tr, this message translates to:
  /// **'ANTRENMANI BAŞLAT'**
  String get startWorkout;

  /// No description provided for @searchWods.
  ///
  /// In tr, this message translates to:
  /// **'WOD veya Egzersiz Ara...'**
  String get searchWods;

  /// No description provided for @allCategories.
  ///
  /// In tr, this message translates to:
  /// **'TÜMÜ'**
  String get allCategories;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
