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
  String get custom => 'CUSTOM TIMER';

  @override
  String get settings => 'SETTINGS';

  @override
  String get work => 'WORK';

  @override
  String get rest => 'REST';

  @override
  String get prep => 'PREPARE';

  @override
  String get cooldown => 'COOLDOWN';

  @override
  String get round => 'ROUND';

  @override
  String get set => 'SET';

  @override
  String get completed => 'COMPLETED!';

  @override
  String get paused => 'PAUSED';

  @override
  String get ready => 'GET READY';

  @override
  String get finished => 'CONGRATS! WORKOUT FINISHED';

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
  String get lap => 'LAP';

  @override
  String get workTime => 'Work Duration';

  @override
  String get restTime => 'Rest Duration';

  @override
  String get prepTime => 'Prep Duration';

  @override
  String get totalRounds => 'Total Rounds';

  @override
  String get totalSets => 'Total Sets';

  @override
  String get restBetweenSets => 'Rest Between Sets';

  @override
  String get timeCap => 'Time Cap';

  @override
  String get sound => 'Sound Effects';

  @override
  String get vibration => 'Vibration';

  @override
  String get keepScreenOn => 'Keep Screen Awake';

  @override
  String get language => 'Language';

  @override
  String get emomTitle => 'EMOM';

  @override
  String get amrapTitle => 'AMRAP';

  @override
  String get forTimeTitle => 'FOR TIME';

  @override
  String get customRoutines => 'Custom Timers';

  @override
  String get createNewRoutine => 'Create New Custom Timer';

  @override
  String get routineName => 'Timer Name';

  @override
  String get routineNameHint => 'e.g., Fran, Murph, 5x5 Interval';

  @override
  String get addInterval => 'Add Interval';

  @override
  String get intervalName => 'Interval Name';

  @override
  String get intervalDuration => 'Duration (sec)';

  @override
  String get intervalType => 'Interval Type';

  @override
  String get save => 'SAVE';

  @override
  String get cancel => 'CANCEL';

  @override
  String get delete => 'DELETE';

  @override
  String get edit => 'EDIT';

  @override
  String get noCustomRoutines => 'No custom timers yet. Create one now!';

  @override
  String get confirmDelete => 'Are you sure you want to delete this timer?';

  @override
  String get cloudSyncNotice =>
      'Your timers are stored locally. They will sync with the cloud once backend is connected.';

  @override
  String get lapTimes => 'Lap Times';

  @override
  String get fastestLap => 'Fastest Lap';

  @override
  String get slowestLap => 'Slowest Lap';

  @override
  String get totalTime => 'Total Time';

  @override
  String get roundTime => 'Round Time';
}
