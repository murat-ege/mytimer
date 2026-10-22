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

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'COUNTDOWN'**
  String get countdown;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM & WODS'**
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

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'TIME!'**
  String get completed;

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

  /// No description provided for @totalRounds.
  ///
  /// In en, this message translates to:
  /// **'TOTAL ROUNDS'**
  String get totalRounds;

  /// No description provided for @restBetweenSets.
  ///
  /// In en, this message translates to:
  /// **'REST BETWEEN ROUNDS'**
  String get restBetweenSets;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
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

  /// No description provided for @cloudSyncNotice.
  ///
  /// In en, this message translates to:
  /// **'Your timers and workout logs are stored locally on your device.'**
  String get cloudSyncNotice;

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
  /// **'Engineered for CrossFit, HIIT, functional fitness, and WOD competitions.'**
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

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

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

  /// No description provided for @editTimer.
  ///
  /// In en, this message translates to:
  /// **'Edit Timer'**
  String get editTimer;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @deleteTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Timer?'**
  String get deleteTimerTitle;

  /// No description provided for @deleteTimerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this timer? It will also be removed from the home screen.'**
  String get deleteTimerConfirm;

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

  /// No description provided for @categoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get categoryCustom;

  /// No description provided for @tabataAcronym.
  ///
  /// In en, this message translates to:
  /// **'20s Work / 10s Rest'**
  String get tabataAcronym;

  /// No description provided for @roundsAcronym.
  ///
  /// In en, this message translates to:
  /// **'Interval Training'**
  String get roundsAcronym;

  /// No description provided for @emomAcronym.
  ///
  /// In en, this message translates to:
  /// **'Every Minute On the Minute'**
  String get emomAcronym;

  /// No description provided for @forTimeAcronym.
  ///
  /// In en, this message translates to:
  /// **'Race Against The Clock'**
  String get forTimeAcronym;

  /// No description provided for @stopwatchAcronym.
  ///
  /// In en, this message translates to:
  /// **'Count-Up Timer'**
  String get stopwatchAcronym;

  /// No description provided for @countdownAcronym.
  ///
  /// In en, this message translates to:
  /// **'Countdown Timer'**
  String get countdownAcronym;

  /// No description provided for @customSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hero WODs & Custom Routines'**
  String get customSubtitle;

  /// No description provided for @workoutLogs.
  ///
  /// In en, this message translates to:
  /// **'Workout Log'**
  String get workoutLogs;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No workout logs recorded yet.\nComplete any timer workout to see your history here!'**
  String get noLogsYet;

  /// No description provided for @exportAllCsv.
  ///
  /// In en, this message translates to:
  /// **'Export All (CSV)'**
  String get exportAllCsv;

  /// No description provided for @clearAllLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear All Logs'**
  String get clearAllLogs;

  /// No description provided for @clearLogsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete all workout logs? This action cannot be undone.'**
  String get clearLogsConfirm;

  /// No description provided for @attachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach Photo'**
  String get attachPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @workoutNote.
  ///
  /// In en, this message translates to:
  /// **'Workout Notes'**
  String get workoutNote;

  /// No description provided for @workoutNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Score, weights, reps, scaling, or how you felt...'**
  String get workoutNoteHint;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Timers & Routines'**
  String get presets;

  /// No description provided for @defaultPreset.
  ///
  /// In en, this message translates to:
  /// **'Standard (Default)'**
  String get defaultPreset;

  /// No description provided for @timerSaved.
  ///
  /// In en, this message translates to:
  /// **'Timer saved successfully'**
  String get timerSaved;

  /// No description provided for @voiceCoach.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceCoach;

  /// No description provided for @voiceCoachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spoken voice cues for countdown, intervals, and finish'**
  String get voiceCoachSubtitle;

  /// No description provided for @testVoice.
  ///
  /// In en, this message translates to:
  /// **'Test Voice Cue'**
  String get testVoice;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @addTimer.
  ///
  /// In en, this message translates to:
  /// **'Add Timer'**
  String get addTimer;

  /// No description provided for @allTimersAdded.
  ///
  /// In en, this message translates to:
  /// **'All timers are on the home screen'**
  String get allTimersAdded;

  /// No description provided for @resetLayout.
  ///
  /// In en, this message translates to:
  /// **'Reset Layout'**
  String get resetLayout;

  /// No description provided for @editHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Edit Home Screen'**
  String get editHomeScreen;

  /// No description provided for @hyrox.
  ///
  /// In en, this message translates to:
  /// **'HYROX'**
  String get hyrox;

  /// No description provided for @hyroxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Timer Suit'**
  String get hyroxSubtitle;

  /// No description provided for @hyroxRaceSimulator.
  ///
  /// In en, this message translates to:
  /// **'Race Simulator'**
  String get hyroxRaceSimulator;

  /// No description provided for @hyroxRaceSimulatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Full & Half HYROX race split timer with Roxzone tracking and target pace delta.'**
  String get hyroxRaceSimulatorDesc;

  /// No description provided for @hyroxCompromisedRun.
  ///
  /// In en, this message translates to:
  /// **'Compromised Running'**
  String get hyroxCompromisedRun;

  /// No description provided for @hyroxStationIntervals.
  ///
  /// In en, this message translates to:
  /// **'Station P-EMOM & Intervals'**
  String get hyroxStationIntervals;

  /// No description provided for @hyroxDoublesTimer.
  ///
  /// In en, this message translates to:
  /// **'Doubles & Relay (IGYG)'**
  String get hyroxDoublesTimer;

  /// No description provided for @hyroxBenchmarkTests.
  ///
  /// In en, this message translates to:
  /// **'Station Benchmark Tests'**
  String get hyroxBenchmarkTests;

  /// No description provided for @hyroxStandardsGuide.
  ///
  /// In en, this message translates to:
  /// **'Division Weights & Standards'**
  String get hyroxStandardsGuide;

  /// No description provided for @roxzone.
  ///
  /// In en, this message translates to:
  /// **'ROXZONE'**
  String get roxzone;

  /// No description provided for @roxzoneTracking.
  ///
  /// In en, this message translates to:
  /// **'Roxzone Transition Splits'**
  String get roxzoneTracking;

  /// No description provided for @targetFinishTime.
  ///
  /// In en, this message translates to:
  /// **'Target Finish Time'**
  String get targetFinishTime;

  /// No description provided for @division.
  ///
  /// In en, this message translates to:
  /// **'Division'**
  String get division;

  /// No description provided for @nextSplit.
  ///
  /// In en, this message translates to:
  /// **'NEXT SPLIT'**
  String get nextSplit;

  /// No description provided for @startRace.
  ///
  /// In en, this message translates to:
  /// **'START RACE'**
  String get startRace;

  /// No description provided for @ahead.
  ///
  /// In en, this message translates to:
  /// **'Ahead'**
  String get ahead;

  /// No description provided for @behind.
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get behind;

  /// No description provided for @onPace.
  ///
  /// In en, this message translates to:
  /// **'On Pace'**
  String get onPace;

  /// No description provided for @partnerA.
  ///
  /// In en, this message translates to:
  /// **'PARTNER A'**
  String get partnerA;

  /// No description provided for @partnerB.
  ///
  /// In en, this message translates to:
  /// **'PARTNER B'**
  String get partnerB;

  /// No description provided for @switchPartner.
  ///
  /// In en, this message translates to:
  /// **'SWITCH PARTNER!'**
  String get switchPartner;

  /// No description provided for @switchInterval.
  ///
  /// In en, this message translates to:
  /// **'Switch Interval'**
  String get switchInterval;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @savedTimers.
  ///
  /// In en, this message translates to:
  /// **'Saved Timers'**
  String get savedTimers;

  /// No description provided for @pinToHome.
  ///
  /// In en, this message translates to:
  /// **'Pin to Home'**
  String get pinToHome;

  /// No description provided for @unpinFromHome.
  ///
  /// In en, this message translates to:
  /// **'Unpin from Home'**
  String get unpinFromHome;

  /// No description provided for @pinnedToHome.
  ///
  /// In en, this message translates to:
  /// **'Added to Home Screen'**
  String get pinnedToHome;

  /// No description provided for @unpinnedFromHome.
  ///
  /// In en, this message translates to:
  /// **'Removed from Home Screen'**
  String get unpinnedFromHome;

  /// No description provided for @noTimersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No saved timers found yet.'**
  String get noTimersAvailable;

  /// No description provided for @standardTimers.
  ///
  /// In en, this message translates to:
  /// **'Timers'**
  String get standardTimers;

  /// No description provided for @timerBadge.
  ///
  /// In en, this message translates to:
  /// **'TIMER'**
  String get timerBadge;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get pinned;

  /// No description provided for @timerManager.
  ///
  /// In en, this message translates to:
  /// **'Timer Manager'**
  String get timerManager;

  /// No description provided for @timerManagerDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage, edit and organize your workouts and timers'**
  String get timerManagerDesc;

  /// No description provided for @timerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Timer updated successfully'**
  String get timerUpdated;

  /// No description provided for @openInTimer.
  ///
  /// In en, this message translates to:
  /// **'Open in Timer'**
  String get openInTimer;

  /// No description provided for @confirmExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm on Exit'**
  String get confirmExitTitle;

  /// No description provided for @confirmExitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask for confirmation before leaving workout (default: off)'**
  String get confirmExitSubtitle;

  /// No description provided for @autoStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-Start Timer'**
  String get autoStartTitle;

  /// No description provided for @autoStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically start timer when opened (default: off)'**
  String get autoStartSubtitle;

  /// No description provided for @stopPreview.
  ///
  /// In en, this message translates to:
  /// **'Stop Preview'**
  String get stopPreview;

  /// No description provided for @listenPreview.
  ///
  /// In en, this message translates to:
  /// **'Listen 3-2-1 & GO'**
  String get listenPreview;

  /// No description provided for @editFolder.
  ///
  /// In en, this message translates to:
  /// **'Edit Folder'**
  String get editFolder;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String itemsCount(int count);

  /// No description provided for @timerParameters.
  ///
  /// In en, this message translates to:
  /// **'TIMER PARAMETERS'**
  String get timerParameters;

  /// No description provided for @prepDuration.
  ///
  /// In en, this message translates to:
  /// **'Prep Duration'**
  String get prepDuration;

  /// No description provided for @roundsCount.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get roundsCount;

  /// No description provided for @workDuration.
  ///
  /// In en, this message translates to:
  /// **'Work Duration'**
  String get workDuration;

  /// No description provided for @durationOrCap.
  ///
  /// In en, this message translates to:
  /// **'Duration / Cap'**
  String get durationOrCap;

  /// No description provided for @restDuration.
  ///
  /// In en, this message translates to:
  /// **'Rest Duration'**
  String get restDuration;

  /// No description provided for @cooldownDuration.
  ///
  /// In en, this message translates to:
  /// **'Cooldown'**
  String get cooldownDuration;

  /// No description provided for @selectTimerType.
  ///
  /// In en, this message translates to:
  /// **'Select Timer Type'**
  String get selectTimerType;

  /// No description provided for @roundsTypeOption.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get roundsTypeOption;

  /// No description provided for @countdownTypeOption.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdownTypeOption;

  /// No description provided for @customCopySaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved as custom timer'**
  String customCopySaved(String name);

  /// No description provided for @willBeSavedAsCustomCopy.
  ///
  /// In en, this message translates to:
  /// **'Will be saved as a custom copy'**
  String get willBeSavedAsCustomCopy;

  /// No description provided for @customTimerWillBeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Custom timer will be updated'**
  String get customTimerWillBeUpdated;

  /// No description provided for @builtInPresetsProtected.
  ///
  /// In en, this message translates to:
  /// **'Built-in standard timers are protected and cannot be deleted. You can unpin them from the home screen.'**
  String get builtInPresetsProtected;

  /// No description provided for @timerCannotBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Built-in timer (Cannot be deleted)'**
  String get timerCannotBeDeleted;

  /// No description provided for @searchTimersHint.
  ///
  /// In en, this message translates to:
  /// **'Search timers...'**
  String get searchTimersHint;

  /// No description provided for @newTimer.
  ///
  /// In en, this message translates to:
  /// **'New Timer'**
  String get newTimer;

  /// No description provided for @addCategoryTimer.
  ///
  /// In en, this message translates to:
  /// **'Add {category}'**
  String addCategoryTimer(String category);

  /// No description provided for @addTimerOrCustom.
  ///
  /// In en, this message translates to:
  /// **'Add Timer'**
  String get addTimerOrCustom;

  /// No description provided for @addTimerOrCustomTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Timer'**
  String get addTimerOrCustomTooltip;

  /// No description provided for @audioCapsule.
  ///
  /// In en, this message translates to:
  /// **'AUDIO'**
  String get audioCapsule;

  /// No description provided for @coachCapsule.
  ///
  /// In en, this message translates to:
  /// **'COACH'**
  String get coachCapsule;

  /// No description provided for @roundsShort.
  ///
  /// In en, this message translates to:
  /// **'Rnds'**
  String get roundsShort;

  /// No description provided for @allTimersAndWod.
  ///
  /// In en, this message translates to:
  /// **'All Timers & WOD'**
  String get allTimersAndWod;
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
