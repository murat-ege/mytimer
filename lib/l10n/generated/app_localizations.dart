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
  /// In en, this message translates to:
  /// **'MyTimer'**
  String get appTitle;

  /// No description provided for @tabata.
  ///
  /// In en, this message translates to:
  /// **'TABATA'**
  String get tabata;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'ROUNDS'**
  String get rounds;

  /// No description provided for @stopwatch.
  ///
  /// In en, this message translates to:
  /// **'STOPWATCH'**
  String get stopwatch;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get custom;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'WORK'**
  String get work;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get rest;

  /// No description provided for @prep.
  ///
  /// In en, this message translates to:
  /// **'PREP'**
  String get prep;

  /// No description provided for @cooldown.
  ///
  /// In en, this message translates to:
  /// **'COOLDOWN'**
  String get cooldown;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'ROUND'**
  String get round;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get set;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'TIME!'**
  String get completed;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'GET READY'**
  String get ready;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT COMPLETE!'**
  String get finished;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'PAUSE'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resume;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get reset;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @lap.
  ///
  /// In en, this message translates to:
  /// **'SPLIT'**
  String get lap;

  /// No description provided for @workTime.
  ///
  /// In en, this message translates to:
  /// **'WORK TIME'**
  String get workTime;

  /// No description provided for @restTime.
  ///
  /// In en, this message translates to:
  /// **'REST TIME'**
  String get restTime;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'PREP TIME'**
  String get prepTime;

  /// No description provided for @totalRounds.
  ///
  /// In en, this message translates to:
  /// **'TOTAL ROUNDS'**
  String get totalRounds;

  /// No description provided for @totalSets.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SETS'**
  String get totalSets;

  /// No description provided for @restBetweenSets.
  ///
  /// In en, this message translates to:
  /// **'REST BETWEEN ROUNDS'**
  String get restBetweenSets;

  /// No description provided for @timeCap.
  ///
  /// In en, this message translates to:
  /// **'TIME CAP'**
  String get timeCap;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Audio Cues'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get vibration;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen Awake'**
  String get keepScreenOn;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get language;

  /// No description provided for @emomTitle.
  ///
  /// In en, this message translates to:
  /// **'EMOM'**
  String get emomTitle;

  /// No description provided for @amrapTitle.
  ///
  /// In en, this message translates to:
  /// **'AMRAP'**
  String get amrapTitle;

  /// No description provided for @forTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'FOR TIME'**
  String get forTimeTitle;

  /// No description provided for @customRoutines.
  ///
  /// In en, this message translates to:
  /// **'Saved WODs & Timers'**
  String get customRoutines;

  /// No description provided for @createNewRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create New Timer'**
  String get createNewRoutine;

  /// No description provided for @routineName.
  ///
  /// In en, this message translates to:
  /// **'WOD / Timer Name'**
  String get routineName;

  /// No description provided for @routineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Fran, Cindy, Murph, 21-15-9'**
  String get routineNameHint;

  /// No description provided for @addInterval.
  ///
  /// In en, this message translates to:
  /// **'Add Interval'**
  String get addInterval;

  /// No description provided for @intervalName.
  ///
  /// In en, this message translates to:
  /// **'Interval / Movement Name'**
  String get intervalName;

  /// No description provided for @intervalDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (sec)'**
  String get intervalDuration;

  /// No description provided for @intervalType.
  ///
  /// In en, this message translates to:
  /// **'Interval Phase'**
  String get intervalType;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get edit;

  /// No description provided for @noCustomRoutines.
  ///
  /// In en, this message translates to:
  /// **'No custom timers yet. Tap + to build one!'**
  String get noCustomRoutines;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this timer?'**
  String get confirmDelete;

  /// No description provided for @cloudSyncNotice.
  ///
  /// In en, this message translates to:
  /// **'Your timers are stored locally on your device.'**
  String get cloudSyncNotice;

  /// No description provided for @lapTimes.
  ///
  /// In en, this message translates to:
  /// **'Splits & Lap Times'**
  String get lapTimes;

  /// No description provided for @fastestLap.
  ///
  /// In en, this message translates to:
  /// **'Best Split'**
  String get fastestLap;

  /// No description provided for @slowestLap.
  ///
  /// In en, this message translates to:
  /// **'Slowest Split'**
  String get slowestLap;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'TOTAL TIME'**
  String get totalTime;

  /// No description provided for @roundTime.
  ///
  /// In en, this message translates to:
  /// **'Split Time'**
  String get roundTime;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @soundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Countdown beeps and interval transition cues'**
  String get soundSubtitle;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Haptic pulses on interval transitions'**
  String get vibrationSubtitle;

  /// No description provided for @keepScreenOnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Screen stays awake during workouts'**
  String get keepScreenOnSubtitle;

  /// No description provided for @soundTest.
  ///
  /// In en, this message translates to:
  /// **'AUDIO TEST'**
  String get soundTest;

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdown;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get aboutTitle;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Engineered for CrossFit, HIIT, and functional fitness workouts.'**
  String get aboutDesc;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get seconds;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @totalRoundsStat.
  ///
  /// In en, this message translates to:
  /// **'ROUNDS'**
  String get totalRoundsStat;

  /// No description provided for @workRestStat.
  ///
  /// In en, this message translates to:
  /// **'WORK / REST'**
  String get workRestStat;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'START WORKOUT'**
  String get startWorkout;

  /// No description provided for @searchWods.
  ///
  /// In en, this message translates to:
  /// **'Search WOD or Exercise...'**
  String get searchWods;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get allCategories;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @exitWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Workout?'**
  String get exitWorkoutTitle;

  /// No description provided for @exitWorkoutMessage.
  ///
  /// In en, this message translates to:
  /// **'The workout will be stopped. Are you sure you want to quit?'**
  String get exitWorkoutMessage;

  /// No description provided for @continueWorkout.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get continueWorkout;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'QUIT'**
  String get quit;

  /// No description provided for @createRoutine.
  ///
  /// In en, this message translates to:
  /// **'CREATE TIMER'**
  String get createRoutine;

  /// No description provided for @customizeWod.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMIZE WOD'**
  String get customizeWod;

  /// No description provided for @editTimer.
  ///
  /// In en, this message translates to:
  /// **'EDIT TIMER'**
  String get editTimer;

  /// No description provided for @customSuffix.
  ///
  /// In en, this message translates to:
  /// **' (Custom)'**
  String get customSuffix;

  /// No description provided for @workoutsListed.
  ///
  /// In en, this message translates to:
  /// **'{count} workouts listed'**
  String workoutsListed(int count);

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @noWorkoutsFound.
  ///
  /// In en, this message translates to:
  /// **'No workouts found for \"{query}\"'**
  String noWorkoutsFound(String query);

  /// No description provided for @showAllWods.
  ///
  /// In en, this message translates to:
  /// **'Show All WODs'**
  String get showAllWods;

  /// No description provided for @customizeOrCopy.
  ///
  /// In en, this message translates to:
  /// **'Customize / Save Copy'**
  String get customizeOrCopy;

  /// No description provided for @deleteTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Timer?'**
  String get deleteTimerTitle;

  /// No description provided for @deleteTimerConfirm.
  ///
  /// In en, this message translates to:
  /// **'{name} will be deleted. Are you sure?'**
  String deleteTimerConfirm(String name);

  /// No description provided for @routineNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get routineNameRequired;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Target movements, weights or notes'**
  String get descriptionHint;

  /// No description provided for @intervalSequence.
  ///
  /// In en, this message translates to:
  /// **'INTERVAL SEQUENCE'**
  String get intervalSequence;

  /// No description provided for @saveTimer.
  ///
  /// In en, this message translates to:
  /// **'SAVE TIMER'**
  String get saveTimer;

  /// No description provided for @addAtLeastOneInterval.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one interval!'**
  String get addAtLeastOneInterval;

  /// No description provided for @addNewInterval.
  ///
  /// In en, this message translates to:
  /// **'Add New Interval'**
  String get addNewInterval;

  /// No description provided for @intervalPhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get intervalPhaseLabel;

  /// No description provided for @durationSec.
  ///
  /// In en, this message translates to:
  /// **'Duration (s):'**
  String get durationSec;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get add;

  /// No description provided for @roundsBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Rounds'**
  String roundsBadge(int count);

  /// No description provided for @intervalsBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Intervals'**
  String intervalsBadge(int count);

  /// No description provided for @categoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get categoryCustom;
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
