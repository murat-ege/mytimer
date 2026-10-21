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
  String get countdown => 'GERİ SAYIM';

  @override
  String get custom => 'WOD & ÖZEL';

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
  String get sound => 'Ses';

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
  String get customRoutines => 'Hero WOD Kütüphanesi & Özel Timerlar';

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
  String get cloudSyncNotice =>
      'Timerlarınız ve antrenman loglarınız cihazınızda saklanır.';

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
  String get appLanguage => 'Uygulama Dili';

  @override
  String get aboutTitle => 'HAKKINDA';

  @override
  String get aboutDesc =>
      'CrossFit, HIIT, fonksiyonel fitness ve WOD müsabakaları için tasarlandı.';

  @override
  String get seconds => 'sn';

  @override
  String get minutes => 'dk';

  @override
  String get hours => 'Saat';

  @override
  String get hoursShort => 'sa';

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

  @override
  String get tabataAcronym => '20sn Çalışma / 10sn Dinlenme';

  @override
  String get tabataDesc =>
      'Yüksek Yoğunluklu Aralıklı Antrenman: 20 saniye maksimum efor, ardından 10 saniye dinlenme. Dr. Izumi Tabata protokolü.';

  @override
  String get roundsAcronym => 'İnterval Antrenmanı';

  @override
  String get roundsDesc =>
      'Güç ve kondisyon için belirlenen tur sayısı boyunca çalışma ve dinlenme aralıkları.';

  @override
  String get emomAcronym => 'Her Dakika Başında';

  @override
  String get emomDesc =>
      'Her dakikanın başında belirlenen tekrarları yapın; arta kalan sürede bir sonraki dakikaya kadar dinlenin.';

  @override
  String get amrapAcronym => 'Maksimum Tur / Tekrar';

  @override
  String get amrapDesc =>
      'Süre dolana kadar verilen egzersizleri mümkün olan en fazla tur veya tekrarla tamamlayın.';

  @override
  String get forTimeAcronym => 'Zamana Karşı Yarış';

  @override
  String get forTimeDesc =>
      'Verilen işi ve tekrarları Time Cap (Maksimum Süre) dolmadan en hızlı sürede tamamlayın.';

  @override
  String get stopwatchAcronym => 'İleri Sayım';

  @override
  String get stopwatchDesc =>
      'Split ve tur zamanı kayıtlı, en hızlı ve en yavaş split analizi sunan hassas sayaç.';

  @override
  String get countdownAcronym => 'Evrensel Sayaç';

  @override
  String get countdownDesc =>
      'İstenen saat, dakika ve saniyeye göre sıfıra doğru geriye sayan evrensel sayaç.';

  @override
  String get customSubtitle => 'Hero WOD & Özel Rutinler';

  @override
  String get workoutLogSubtitle => 'Geçmiş, Whiteboard & CSV';

  @override
  String get workoutLogs => 'Workout Log';

  @override
  String get noLogsYet =>
      'Henüz kayıtlı antrenman yok.\nHerhangi bir timer antrenmanını tamamladığınızda loglarınız burada listelenir!';

  @override
  String get exportAllCsv => 'Tümünü Export Al (CSV)';

  @override
  String get clearAllLogs => 'Tüm Logları Temizle';

  @override
  String get clearLogsConfirm =>
      'Tüm antrenman geçmişini kalıcı olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get attachPhoto => 'Görsel Yükle';

  @override
  String get changePhoto => 'Görseli Değiştir';

  @override
  String get removePhoto => 'Görseli Kaldır';

  @override
  String get workoutNote => 'Antrenman Notu';

  @override
  String get workoutNoteHint =>
      'Skor, ağırlıklar, tekrar sayıları veya antrenman notu...';

  @override
  String get presets => 'Kayıtlı Timerlar & Favoriler';

  @override
  String get savePreset => 'Özelleştirilmiş Olarak Kaydet';

  @override
  String get presetNameHint => 'Örn: Ağır Tabata, 12dk EMOM, Murph Temposu';

  @override
  String get defaultPreset => 'Standart (Varsayılan)';

  @override
  String get restoreDefault => 'Varsayılana Sıfırla';

  @override
  String get presetSaved => 'Özelleştirilmiş timer kaydedildi';

  @override
  String get voiceCoach => 'Seslendirme';

  @override
  String get voiceCoachSubtitle =>
      'Geri sayım, aralık geçişleri ve bitiş için sesli yönlendirmeler';

  @override
  String get voiceCoachSelector => 'Antrenman Koçu Sesi (2 Erkek, 2 Kadın)';

  @override
  String get testVoice => 'Seslendirmeyi Test Et';

  @override
  String get audioTheme => 'Antrenman Ses Teması (10 Farklı Audio)';

  @override
  String get audioThemeSubtitle =>
      'Tercih ettiğiniz atletik ses temasını seçin:';

  @override
  String get done => 'Bitti';

  @override
  String get addTimer => 'Zamanlayıcı Ekle';

  @override
  String get allTimersAdded => 'Tüm zamanlayıcılar ana ekranda';

  @override
  String get resetLayout => 'Varsayılan Dizilime Dön';

  @override
  String get editHomeScreen => 'Ana Ekranı Düzenle';

  @override
  String get hyrox => 'HYROX';

  @override
  String get hyroxSubtitle => 'Yarış Simülatörü & Testler';

  @override
  String get hyroxRaceSimulator => 'Yarış Simülatörü';

  @override
  String get hyroxRaceSimulatorDesc =>
      'Roxzone geçiş takipli ve hedef tempo analizi sunan Tam ve Yarı HYROX yarış sayacı.';

  @override
  String get hyroxCompromisedRun => 'Compromised Running (Koşu + İstasyon)';

  @override
  String get hyroxCompromisedRunDesc =>
      'Yorgun bacaklarla koşu ve fonksiyonel istasyon blokları arasında dönüşümlü antrenman.';

  @override
  String get hyroxStationIntervals => 'İstasyon P-EMOM & İntervalleri';

  @override
  String get hyroxStationIntervalsDesc =>
      '8 HYROX istasyonu arasında tur atan devre ve süre aralıklı interval sayacı.';

  @override
  String get hyroxDoublesTimer => 'Doubles & Bayrak (IGYG Değişim)';

  @override
  String get hyroxDoublesTimerDesc =>
      'Çiftler (Doubles) ve bayrak takımları için partner değişim uyarıcısı (30sn, 45sn, 60sn).';

  @override
  String get hyroxBenchmarkTests => 'İstasyon Benchmark Testleri';

  @override
  String get hyroxBenchmarkTestsDesc =>
      'Kategori ağırlıkları ve elit süre hedefleriyle tekil istasyon zaman denemeleri.';

  @override
  String get hyroxStandardsGuide => 'Kategori Ağırlıkları & Standartlar';

  @override
  String get hyroxStandardsGuideDesc =>
      'Open, Pro ve Doubles kategorileri için resmi ağırlıklar, hedef yükseklikleri ve kurallar.';

  @override
  String get roxzone => 'ROXZONE';

  @override
  String get roxzoneTracking => 'Roxzone Geçiş Turları';

  @override
  String get targetFinishTime => 'Hedef Bitiş Süresi';

  @override
  String get division => 'Kategori';

  @override
  String get nextSplit => 'SONRAKİ TUR / İSTASYON';

  @override
  String get startRace => 'YARIŞI BAŞLAT';

  @override
  String get ahead => 'Önde';

  @override
  String get behind => 'Geride';

  @override
  String get onPace => 'Hedefte';

  @override
  String get partnerA => 'PARTNER A';

  @override
  String get partnerB => 'PARTNER B';

  @override
  String get switchPartner => 'PARTNER DEĞİŞ!';

  @override
  String get switchInterval => 'Değişim Aralığı';

  @override
  String get cooldownTime => 'SOĞUMA SÜRESİ';

  @override
  String get intervalSignal => 'ARALIK SİNYALİ';

  @override
  String get off => 'KAPALI';

  @override
  String everyMinute(Object count) {
    return '$count dakikada bir';
  }
}
