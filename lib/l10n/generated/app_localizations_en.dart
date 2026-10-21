// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyTimer';

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
  String get set => 'SET';

  @override
  String get completed => 'TIME!';

  @override
  String get paused => 'PAUSED';

  @override
  String get ready => 'GET READY';

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
  String get workTime => 'WORK TIME';

  @override
  String get restTime => 'REST TIME';

  @override
  String get prepTime => 'PREP TIME';

  @override
  String get totalRounds => 'TOTAL ROUNDS';

  @override
  String get totalSets => 'TOTAL SETS';

  @override
  String get restBetweenSets => 'REST BETWEEN ROUNDS';

  @override
  String get timeCap => 'TIME CAP';

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
  String get customRoutines => 'Custom';

  @override
  String get createNewRoutine => 'Create New Timer';

  @override
  String get routineName => 'WOD / Timer Name';

  @override
  String get routineNameHint => 'e.g., Fran, Cindy, Murph, 21-15-9';

  @override
  String get addInterval => 'Add Interval';

  @override
  String get intervalName => 'Interval / Movement Name';

  @override
  String get intervalDuration => 'Duration (sec)';

  @override
  String get intervalType => 'Interval Phase';

  @override
  String get save => 'SAVE';

  @override
  String get cancel => 'CANCEL';

  @override
  String get delete => 'DELETE';

  @override
  String get edit => 'EDIT';

  @override
  String get noCustomRoutines => 'No custom timers yet. Tap + to build one!';

  @override
  String get confirmDelete => 'Are you sure you want to delete this timer?';

  @override
  String get cloudSyncNotice =>
      'Your timers and workout logs are stored locally on your device.';

  @override
  String get lapTimes => 'Splits & Lap Times';

  @override
  String get fastestLap => 'Best Split';

  @override
  String get slowestLap => 'Slowest Split';

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
  String get soundTest => 'AUDIO TEST';

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
  String get hoursShort => 'h';

  @override
  String get totalRoundsStat => 'ROUNDS';

  @override
  String get workRestStat => 'WORK / REST';

  @override
  String get startWorkout => 'START WORKOUT';

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
  String get customizeWod => 'CUSTOMIZE WOD';

  @override
  String get editTimer => 'EDIT TIMER';

  @override
  String get customSuffix => ' (Custom)';

  @override
  String workoutsListed(int count) {
    return '$count workouts listed';
  }

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String noWorkoutsFound(String query) {
    return 'No workouts found for \"$query\"';
  }

  @override
  String get showAllWods => 'Show All WODs';

  @override
  String get customizeOrCopy => 'Customize / Save Copy';

  @override
  String get deleteTimerTitle => 'Delete Timer?';

  @override
  String deleteTimerConfirm(String name) {
    return '$name will be deleted. Are you sure?';
  }

  @override
  String get routineNameRequired => 'Please enter a name';

  @override
  String get descriptionLabel => 'Description (Optional)';

  @override
  String get descriptionHint => 'Target movements, weights or notes';

  @override
  String get intervalSequence => 'INTERVAL SEQUENCE';

  @override
  String get saveTimer => 'SAVE TIMER';

  @override
  String get addAtLeastOneInterval => 'Please add at least one interval!';

  @override
  String get addNewInterval => 'Add New Interval';

  @override
  String get intervalPhaseLabel => 'Phase';

  @override
  String get durationSec => 'Duration (s):';

  @override
  String get add => 'ADD';

  @override
  String roundsBadge(int count) {
    return '$count Rounds';
  }

  @override
  String intervalsBadge(int count) {
    return '$count Intervals';
  }

  @override
  String get categoryCustom => 'Custom';

  @override
  String get tabataAcronym => '20s Work / 10s Rest';

  @override
  String get tabataDesc =>
      'High-Intensity Interval Training: 20 seconds maximum effort followed by 10 seconds rest.';

  @override
  String get roundsAcronym => 'Interval Training';

  @override
  String get roundsDesc =>
      'Structured work and rest interval rounds designed for functional strength and conditioning.';

  @override
  String get emomAcronym => 'Every Minute On the Minute';

  @override
  String get emomDesc =>
      'Perform designated repetitions at the start of each minute. Any remaining time in the minute is your rest.';

  @override
  String get amrapAcronym => 'Max Rounds & Reps';

  @override
  String get amrapDesc =>
      'Complete as many rounds or repetitions of the designated exercises as possible before the clock expires.';

  @override
  String get forTimeAcronym => 'Race Against The Clock';

  @override
  String get forTimeDesc =>
      'Complete the designated work and repetitions as fast as possible before reaching the maximum Time Cap.';

  @override
  String get stopwatchAcronym => 'Count-Up Timer';

  @override
  String get stopwatchDesc =>
      'Precision count-up timer with split tracking and best/slowest split analysis.';

  @override
  String get countdownAcronym => 'Universal Timer';

  @override
  String get countdownDesc =>
      'Universal countdown timer with custom hours, minutes, and seconds for any workout, challenge, or rest interval.';

  @override
  String get customSubtitle => 'Hero WODs & Custom Routines';

  @override
  String get workoutLogSubtitle => 'History, Whiteboard & CSV';

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
  String get presets => 'Presets & Saved Timers';

  @override
  String get savePreset => 'Save As Custom Preset';

  @override
  String get presetNameHint => 'e.g., Heavy Tabata, 12m EMOM, Murph Pace';

  @override
  String get defaultPreset => 'Standard (Default)';

  @override
  String get restoreDefault => 'Restore Defaults';

  @override
  String get presetSaved => 'Preset saved successfully';

  @override
  String get voiceCoach => 'Voice';

  @override
  String get voiceCoachSubtitle =>
      'Spoken voice cues for countdown, intervals, and finish';

  @override
  String get voiceCoachSelector => 'Select Voice Coach (2 Male, 2 Female)';

  @override
  String get testVoice => 'Test Voice Cue';

  @override
  String get audioTheme => 'Workout Audio Theme (10 Sound Packs)';

  @override
  String get audioThemeSubtitle => 'Choose your preferred athletic sound pack:';

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
  String get hyroxCompromisedRunDesc =>
      'Alternating running intervals and functional stations on heavy legs.';

  @override
  String get hyroxStationIntervals => 'Station P-EMOM & Intervals';

  @override
  String get hyroxStationIntervalsDesc =>
      'Circuit interval timers cycling through all 8 HYROX functional stations.';

  @override
  String get hyroxDoublesTimer => 'Doubles & Relay (IGYG)';

  @override
  String get hyroxDoublesTimerDesc =>
      'Partner switch alerts (30s, 45s, 60s, 90s) for Doubles and Relay teams.';

  @override
  String get hyroxBenchmarkTests => 'Station Benchmark Tests';

  @override
  String get hyroxBenchmarkTestsDesc =>
      'Individual station time trials with division weights and pace benchmarks.';

  @override
  String get hyroxStandardsGuide => 'Division Weights & Standards';

  @override
  String get hyroxStandardsGuideDesc =>
      'Official weights, target heights, and movement rules for Open, Pro & Doubles.';

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
  String get cooldownTime => 'COOLDOWN TIME';

  @override
  String get intervalSignal => 'INTERVAL SIGNAL';

  @override
  String get off => 'OFF';

  @override
  String everyMinute(Object count) {
    return 'Every $count min';
  }
}
