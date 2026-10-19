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
  String get rounds => 'ROUNDS';

  @override
  String get stopwatch => 'KRONOMETRE';

  @override
  String get custom => 'ÖZEL';

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
  String get round => 'ROUND';

  @override
  String get set => 'SET';

  @override
  String get completed => 'TAMAMLANDI!';

  @override
  String get paused => 'DURAKLATILDI';

  @override
  String get ready => 'HAZIRLAN';

  @override
  String get finished => 'ANTRENMAN TAMAMLANDI!';

  @override
  String get start => 'BAŞLAT';

  @override
  String get pause => 'DURAKLAT';

  @override
  String get resume => 'DEVAM ET';

  @override
  String get reset => 'SIFIRLA';

  @override
  String get skip => 'ATLA';

  @override
  String get lap => 'SPLİT';

  @override
  String get workTime => 'ÇALIŞMA SÜRESİ';

  @override
  String get restTime => 'DİNLENME SÜRESİ';

  @override
  String get prepTime => 'HAZIRLANMA SÜRESİ';

  @override
  String get totalRounds => 'TOPLAM ROUND';

  @override
  String get totalSets => 'TOPLAM SET';

  @override
  String get restBetweenSets => 'ROUND ARASI DİNLENME';

  @override
  String get timeCap => 'TIME CAP';

  @override
  String get sound => 'Ses Sinyalleri';

  @override
  String get vibration => 'Titreşim';

  @override
  String get keepScreenOn => 'Ekranı Açık Tut';

  @override
  String get language => 'DİL / LANGUAGE';

  @override
  String get emomTitle => 'EMOM';

  @override
  String get amrapTitle => 'AMRAP';

  @override
  String get forTimeTitle => 'FOR TIME';

  @override
  String get customRoutines => 'Kayıtlı WOD & Timerlar';

  @override
  String get createNewRoutine => 'Yeni Timer Oluştur';

  @override
  String get routineName => 'WOD / Timer Adı';

  @override
  String get routineNameHint => 'Örn: Fran, Cindy, Murph, 21-15-9';

  @override
  String get addInterval => 'İnterval Ekle';

  @override
  String get intervalName => 'İnterval / Hareket Adı';

  @override
  String get intervalDuration => 'Süre (sn)';

  @override
  String get intervalType => 'İnterval Fazı';

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
      'Henüz kayıtlı timer yok. + butonuna basarak ekleyin!';

  @override
  String get confirmDelete => 'Bu timer\'ı silmek istediğinize emin misiniz?';

  @override
  String get cloudSyncNotice => 'Timerlarınız cihazınızda saklanır.';

  @override
  String get lapTimes => 'Split & Tur Zamanları';

  @override
  String get fastestLap => 'En Hızlı Split';

  @override
  String get slowestLap => 'En Yavaş Split';

  @override
  String get totalTime => 'TOPLAM SÜRE';

  @override
  String get roundTime => 'Split Süresi';

  @override
  String get general => 'GENEL';

  @override
  String get soundSubtitle => 'Geri sayım ve interval geçiş bip sesleri';

  @override
  String get vibrationSubtitle =>
      'Aralık geçişlerinde haptik titreşim bildirimi';

  @override
  String get keepScreenOnSubtitle => 'Antrenman boyunca ekran kapanmaz';

  @override
  String get soundTest => 'SES TESTİ';

  @override
  String get countdown => 'Geri Sayım';

  @override
  String get appLanguage => 'Uygulama Dili';

  @override
  String get aboutTitle => 'HAKKINDA';

  @override
  String get aboutDesc =>
      'CrossFit, HIIT ve fonksiyonel fitness antrenmanları için tasarlandı.';

  @override
  String get seconds => 'sn';

  @override
  String get minutes => 'dk';

  @override
  String get totalRoundsStat => 'ROUND SAYISI';

  @override
  String get workRestStat => 'ÇALIŞMA / DİNLENME';

  @override
  String get startWorkout => 'ANTRENMANI BAŞLAT';

  @override
  String get searchWods => 'WOD veya Egzersiz Ara...';

  @override
  String get allCategories => 'TÜMÜ';

  @override
  String get next => 'Sıradaki';

  @override
  String get exitWorkoutTitle => 'Antrenmandan Çıkılsın mı?';

  @override
  String get exitWorkoutMessage =>
      'Antrenman sonlandırılacak. Çıkmak istediğinize emin misiniz?';

  @override
  String get continueWorkout => 'DEVAM ET';

  @override
  String get quit => 'ÇIK';

  @override
  String get createRoutine => 'YENİ TİMER OLUŞTUR';

  @override
  String get customizeWod => 'WOD\'U ÖZELLEŞTİR';

  @override
  String get editTimer => 'TİMER DÜZENLE';

  @override
  String get customSuffix => ' (Özel)';

  @override
  String workoutsListed(int count) {
    return '$count antrenman listeleniyor';
  }

  @override
  String get clearFilters => 'Filtreleri Temizle';

  @override
  String noWorkoutsFound(String query) {
    return '\"$query\" için antrenman bulunamadı';
  }

  @override
  String get showAllWods => 'Tüm WOD\'ları Göster';

  @override
  String get customizeOrCopy => 'Özelleştir / Yeni İsimle Kaydet';

  @override
  String get deleteTimerTitle => 'Timer Silinsin mi?';

  @override
  String deleteTimerConfirm(String name) {
    return '$name silinecektir. Onaylıyor musunuz?';
  }

  @override
  String get routineNameRequired => 'Lütfen bir ad girin';

  @override
  String get descriptionLabel => 'Açıklama (İsteğe bağlı)';

  @override
  String get descriptionHint => 'Hedeflenen hareketler, ağırlık veya notlar';

  @override
  String get intervalSequence => 'ARALIK SIRALAMASI';

  @override
  String get saveTimer => 'TİMER\'I KAYDET';

  @override
  String get addAtLeastOneInterval => 'Lütfen en az bir aralık ekleyin!';

  @override
  String get addNewInterval => 'Yeni Aralık Ekle';

  @override
  String get intervalPhaseLabel => 'Tip';

  @override
  String get durationSec => 'Süre (sn):';

  @override
  String get add => 'EKLE';

  @override
  String roundsBadge(int count) {
    return '$count Tur';
  }

  @override
  String intervalsBadge(int count) {
    return '$count Aralık';
  }

  @override
  String get categoryCustom => 'Özel';
}
