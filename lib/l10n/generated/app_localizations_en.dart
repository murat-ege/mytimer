// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabata => 'TABATA';

  @override
  String get rounds => 'ROUNDS';

  @override
  String get stopwatch => 'STOPWATCH';

  @override
  String get countdown => 'COUNTDOWN';

  @override
  String get custom => 'CUSTOM & WODS';

  @override
  String get settings => 'SETTINGS';

  @override
  String get work => 'WORK';

  @override
  String get rest => 'REST';

  @override
  String get prep => 'PREP';

  @override
  String get cooldown => 'COOLDOWN';

  @override
  String get round => 'ROUND';

  @override
  String get completed => 'TIME!';

  @override
  String get finished => 'WORKOUT COMPLETE!';

  @override
  String get start => 'START';

  @override
  String get pause => 'PAUSE';

  @override
  String get resume => 'RESUME';

  @override
  String get reset => 'RESET';

  @override
  String get skip => 'SKIP';

  @override
  String get lap => 'SPLIT';

  @override
  String get totalRounds => 'TOTAL ROUNDS';

  @override
  String get restBetweenSets => 'REST BETWEEN ROUNDS';

  @override
  String get sound => 'Audio';

  @override
  String get vibration => 'Haptic Feedback';

  @override
  String get keepScreenOn => 'Keep Screen Awake';

  @override
  String get language => 'LANGUAGE';

  @override
  String get emomTitle => 'EMOM';

  @override
  String get amrapTitle => 'AMRAP';

  @override
  String get forTimeTitle => 'FOR TIME';

  @override
  String get routineName => 'WOD / Timer Name';

  @override
  String get routineNameHint => 'e.g., Fran, Cindy, Murph, 21-15-9';

  @override
  String get addInterval => 'Add Interval';

  @override
  String get save => 'SAVE';

  @override
  String get cancel => 'CANCEL';

  @override
  String get delete => 'DELETE';

  @override
  String get edit => 'EDIT';

  @override
  String get cloudSyncNotice =>
      'Your timers and workout logs are stored locally on your device.';

  @override
  String get totalTime => 'TOTAL TIME';

  @override
  String get roundTime => 'Split Time';

  @override
  String get general => 'GENERAL';

  @override
  String get soundSubtitle => 'Countdown beeps and interval transition cues';

  @override
  String get vibrationSubtitle => 'Haptic pulses on interval transitions';

  @override
  String get keepScreenOnSubtitle => 'Screen stays awake during workouts';

  @override
  String get appLanguage => 'App Language';

  @override
  String get aboutTitle => 'ABOUT';

  @override
  String get aboutDesc =>
      'Engineered for CrossFit, HIIT, functional fitness, and WOD competitions.';

  @override
  String get seconds => 's';

  @override
  String get minutes => 'min';

  @override
  String get hours => 'Hours';

  @override
  String get searchWods => 'Search WOD or Exercise...';

  @override
  String get allCategories => 'ALL';

  @override
  String get next => 'Next';

  @override
  String get exitWorkoutTitle => 'Exit Workout?';

  @override
  String get exitWorkoutMessage =>
      'The workout will be stopped. Are you sure you want to quit?';

  @override
  String get continueWorkout => 'RESUME';

  @override
  String get quit => 'QUIT';

  @override
  String get createRoutine => 'CREATE TIMER';

  @override
  String get editTimer => 'Edit Timer';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get deleteTimerTitle => 'Delete Timer?';

  @override
  String get deleteTimerConfirm =>
      'Are you sure you want to delete this timer? It will also be removed from the home screen.';

  @override
  String get durationSec => 'Duration (s):';

  @override
  String get add => 'ADD';

  @override
  String get categoryCustom => 'Custom';

  @override
  String get tabataAcronym => '20s Work / 10s Rest';

  @override
  String get roundsAcronym => 'Interval Training';

  @override
  String get emomAcronym => 'Every Minute On the Minute';

  @override
  String get forTimeAcronym => 'Race Against The Clock';

  @override
  String get stopwatchAcronym => 'Count-Up Timer';

  @override
  String get countdownAcronym => 'Countdown Timer';

  @override
  String get customSubtitle => 'Hero WODs & Custom Routines';

  @override
  String get workoutLogs => 'Workout Log';

  @override
  String get noLogsYet =>
      'No workout logs recorded yet.\nComplete any timer workout to see your history here!';

  @override
  String get exportAllCsv => 'Export All (CSV)';

  @override
  String get clearAllLogs => 'Clear All Logs';

  @override
  String get clearLogsConfirm =>
      'Are you sure you want to permanently delete all workout logs? This action cannot be undone.';

  @override
  String get attachPhoto => 'Attach Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get workoutNote => 'Workout Notes';

  @override
  String get workoutNoteHint =>
      'Score, weights, reps, scaling, or how you felt...';

  @override
  String get presets => 'Timers & Routines';

  @override
  String get defaultPreset => 'Standard (Default)';

  @override
  String get timerSaved => 'Timer saved successfully';

  @override
  String get voiceCoach => 'Voice';

  @override
  String get voiceCoachSubtitle =>
      'Spoken voice cues for countdown, intervals, and finish';

  @override
  String get testVoice => 'Test Voice Cue';

  @override
  String get done => 'Done';

  @override
  String get addTimer => 'Add Timer';

  @override
  String get allTimersAdded => 'All timers are on the home screen';

  @override
  String get resetLayout => 'Reset Layout';

  @override
  String get editHomeScreen => 'Edit Home Screen';

  @override
  String get hyrox => 'HYROX';

  @override
  String get hyroxSubtitle => 'Timer Suit';

  @override
  String get hyroxRaceSimulator => 'Race Simulator';

  @override
  String get hyroxRaceSimulatorDesc =>
      'Full & Half HYROX race split timer with Roxzone tracking and target pace delta.';

  @override
  String get hyroxCompromisedRun => 'Compromised Running';

  @override
  String get hyroxStationIntervals => 'Station P-EMOM & Intervals';

  @override
  String get hyroxDoublesTimer => 'Doubles & Relay (IGYG)';

  @override
  String get hyroxBenchmarkTests => 'Station Benchmark Tests';

  @override
  String get hyroxStandardsGuide => 'Division Weights & Standards';

  @override
  String get roxzone => 'ROXZONE';

  @override
  String get roxzoneTracking => 'Roxzone Transition Splits';

  @override
  String get targetFinishTime => 'Target Finish Time';

  @override
  String get division => 'Division';

  @override
  String get nextSplit => 'NEXT SPLIT';

  @override
  String get startRace => 'START RACE';

  @override
  String get ahead => 'Ahead';

  @override
  String get behind => 'Behind';

  @override
  String get onPace => 'On Pace';

  @override
  String get partnerA => 'PARTNER A';

  @override
  String get partnerB => 'PARTNER B';

  @override
  String get switchPartner => 'SWITCH PARTNER!';

  @override
  String get switchInterval => 'Switch Interval';

  @override
  String get off => 'OFF';

  @override
  String get savedTimers => 'Saved Timers';

  @override
  String get pinToHome => 'Pin to Home';

  @override
  String get unpinFromHome => 'Unpin from Home';

  @override
  String get pinnedToHome => 'Added to Home Screen';

  @override
  String get unpinnedFromHome => 'Removed from Home Screen';

  @override
  String get noTimersAvailable => 'No saved timers found yet.';

  @override
  String get standardTimers => 'Timers';

  @override
  String get timerBadge => 'TIMER';

  @override
  String get pinned => 'Added';

  @override
  String get timerManager => 'Timer Manager';

  @override
  String get timerManagerDesc =>
      'Manage, edit and organize your workouts and timers';

  @override
  String get timerUpdated => 'Timer updated successfully';

  @override
  String get openInTimer => 'Open in Timer';

  @override
  String get confirmExitTitle => 'Confirm on Exit';

  @override
  String get confirmExitSubtitle =>
      'Ask for confirmation before leaving workout (default: off)';

  @override
  String get autoStartTitle => 'Auto-Start Timer';

  @override
  String get autoStartSubtitle =>
      'Automatically start timer when opened (default: off)';

  @override
  String get stopPreview => 'Stop Preview';

  @override
  String get listenPreview => 'Listen 3-2-1 & GO';

  @override
  String get editFolder => 'Edit Folder';

  @override
  String itemsCount(int count) {
    return '$count Items';
  }

  @override
  String get timerParameters => 'TIMER PARAMETERS';

  @override
  String get prepDuration => 'Prep Duration';

  @override
  String get roundsCount => 'Rounds';

  @override
  String get workDuration => 'Work Duration';

  @override
  String get durationOrCap => 'Duration / Cap';

  @override
  String get restDuration => 'Rest Duration';

  @override
  String get cooldownDuration => 'Cooldown';

  @override
  String get selectTimerType => 'Select Timer Type';

  @override
  String get roundsTypeOption => 'Rounds';

  @override
  String get countdownTypeOption => 'Countdown';

  @override
  String customCopySaved(String name) {
    return '$name saved as custom timer';
  }

  @override
  String get willBeSavedAsCustomCopy => 'Will be saved as a custom copy';

  @override
  String get customTimerWillBeUpdated => 'Custom timer will be updated';

  @override
  String get builtInPresetsProtected =>
      'Built-in standard timers are protected and cannot be deleted. You can unpin them from the home screen.';

  @override
  String get timerCannotBeDeleted => 'Built-in timer (Cannot be deleted)';

  @override
  String get searchTimersHint => 'Search timers...';

  @override
  String get newTimer => 'New Timer';

  @override
  String addCategoryTimer(String category) {
    return 'Add $category';
  }

  @override
  String get addTimerOrCustom => 'Add Timer';

  @override
  String get addTimerOrCustomTooltip => 'Add Timer';

  @override
  String get audioCapsule => 'AUDIO';

  @override
  String get coachCapsule => 'COACH';

  @override
  String get roundsShort => 'Rnds';

  @override
  String get allTimersAndWod => 'All Timers & WOD';
}
