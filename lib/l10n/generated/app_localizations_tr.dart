// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'MyTimer';

  @override
  String get tabata => 'TABATA';

  @override
  String get rounds => 'TUR (ROUNDS)';

  @override
  String get stopwatch => 'KRONOMETRE';

  @override
  String get custom => 'ÖZEL TİMER';

  @override
  String get settings => 'AYARLAR';

  @override
  String get work => 'ÇALIŞMA';

  @override
  String get rest => 'DİNLENME';

  @override
  String get prep => 'HAZIRLIK';

  @override
  String get cooldown => 'SOĞUMA';

  @override
  String get round => 'TUR';

  @override
  String get set => 'SET';

  @override
  String get completed => 'TAMAMLANDI!';

  @override
  String get paused => 'DURAKLATILDI';

  @override
  String get ready => 'HAZIR OL';

  @override
  String get finished => 'TEBRİKLER! ANTRENMAN BİTTİ';

  @override
  String get start => 'BAŞLAT';

  @override
  String get pause => 'DURAKLAT';

  @override
  String get resume => 'DEVAM ET';

  @override
  String get reset => 'SIFIRLA';

  @override
  String get skip => 'İLERİ ATLA';

  @override
  String get lap => 'TUR AT';

  @override
  String get workTime => 'Çalışma Süresi';

  @override
  String get restTime => 'Dinlenme Süresi';

  @override
  String get prepTime => 'Hazırlık Süresi';

  @override
  String get totalRounds => 'Toplam Tur';

  @override
  String get totalSets => 'Toplam Set';

  @override
  String get restBetweenSets => 'Setler Arası Dinlenme';

  @override
  String get timeCap => 'Zaman Sınırı (Time Cap)';

  @override
  String get sound => 'Ses Efektleri';

  @override
  String get vibration => 'Titreşim';

  @override
  String get keepScreenOn => 'Ekranı Açık Tut';

  @override
  String get language => 'Dil / Language';

  @override
  String get emomTitle => 'EMOM';

  @override
  String get amrapTitle => 'AMRAP';

  @override
  String get forTimeTitle => 'FOR TIME';

  @override
  String get customRoutines => 'Kayıtlı Özel Timerlar';

  @override
  String get createNewRoutine => 'Yeni Özel Timer Oluştur';

  @override
  String get routineName => 'Timer Adı';

  @override
  String get routineNameHint => 'Örn: Fran, Murph, 5x5 Interval';

  @override
  String get addInterval => 'Aralık Ekle';

  @override
  String get intervalName => 'Aralık Adı';

  @override
  String get intervalDuration => 'Süre (sn)';

  @override
  String get intervalType => 'Aralık Tipi';

  @override
  String get save => 'KAYDET';

  @override
  String get cancel => 'İPTAL';

  @override
  String get delete => 'SİL';

  @override
  String get edit => 'DÜZENLE';

  @override
  String get noCustomRoutines =>
      'Henüz özel bir timer oluşturmadınız. Hemen ekleyin!';

  @override
  String get confirmDelete => 'Bu timer\'ı silmek istediğinize emin misiniz?';

  @override
  String get cloudSyncNotice =>
      'Timerlarınız lokalde saklanır. Backend bağlantısı eklendiğinde bulutla senkronize edilecektir.';

  @override
  String get lapTimes => 'Tur Zamanları';

  @override
  String get fastestLap => 'En Hızlı Tur';

  @override
  String get slowestLap => 'En Yavaş Tur';

  @override
  String get totalTime => 'Toplam Süre';

  @override
  String get roundTime => 'Tur Süresi';
}
