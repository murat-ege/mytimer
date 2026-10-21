import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/timer_settings.dart';
import '../../repositories/local_timer_repository.dart';
import '../../services/audio_theme_generator.dart';
import '../../services/sound_service.dart';
import '../../services/voice_coach_service.dart';
import '../../services/wakelock_service.dart';
import 'widgets/settings_section_header.dart';
import 'widgets/settings_switch_tile.dart';

class SettingsScreen extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const SettingsScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();
  final SoundService _soundService = SoundService();
  final VoiceCoachService _voiceCoach = VoiceCoachService();
  final WakelockService _wakelockService = WakelockService();

  TimerSettings _settings = const TimerSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await _repository.getSettings();
    if (mounted) {
      setState(() {
        _settings = s;
        _isLoading = false;
      });
      _soundService.soundEnabled = s.soundEnabled;
      _soundService.vibrationEnabled = s.vibrationEnabled;
      _soundService.currentThemeId = s.audioThemeId;
      _wakelockService.wakelockEnabled = s.wakelockEnabled;
      _voiceCoach.voiceEnabled = s.voiceCoachEnabled;
      _voiceCoach.currentVoiceId = s.voiceCoachId;
      _voiceCoach.languageCode = s.languageCode;
    }
  }

  Future<void> _updateSettings(TimerSettings newSettings) async {
    setState(() => _settings = newSettings);
    await _repository.saveSettings(newSettings);

    _soundService.soundEnabled = newSettings.soundEnabled;
    _soundService.vibrationEnabled = newSettings.vibrationEnabled;
    _soundService.currentThemeId = newSettings.audioThemeId;
    _wakelockService.wakelockEnabled = newSettings.wakelockEnabled;

    await _voiceCoach.updateConfig(
      enabled: newSettings.voiceCoachEnabled,
      voiceId: newSettings.voiceCoachId,
      lang: newSettings.languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLang = widget.currentLocale.languageCode;
    final isTr = currentLang == 'tr';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.settings ?? 'SETTINGS',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // GENERAL SETTINGS
                SettingsSectionHeader(title: l10n?.general ?? 'GENERAL'),

                // 1. SES ANAHTARI (Audio Switch)
                SettingsSwitchTile(
                  title: l10n?.sound ?? (isTr ? 'Ses' : 'Audio'),
                  subtitle: l10n?.soundSubtitle ?? 'Countdown beeps and interval transition signals',
                  value: _settings.soundEnabled,
                  icon: Icons.volume_up,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(soundEnabled: val));
                  },
                ),

                // 2. SES KOMBOSU (Audio Theme Combo)
                if (_settings.soundEnabled)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _settings.audioThemeId,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF262626),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF161616),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            items: AudioThemeGenerator.allThemes.map((theme) {
                              return DropdownMenuItem<String>(
                                value: theme.id,
                                child: Row(
                                  children: [
                                    const Icon(Icons.music_note, color: Color(0xFF00E676), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        isTr ? theme.nameTr : theme.nameEn,
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _updateSettings(_settings.copyWith(audioThemeId: val));
                                _soundService.previewTheme(val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => _soundService.previewTheme(_settings.audioThemeId),
                          icon: const Icon(Icons.play_circle_fill, color: Color(0xFF00E676), size: 28),
                          tooltip: 'Listen Preview',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 3. SESLENDİRME ANAHTARI (Voice Switch)
                SettingsSwitchTile(
                  title: l10n?.voiceCoach ?? (isTr ? 'Seslendirme' : 'Voice'),
                  subtitle: l10n?.voiceCoachSubtitle ?? 'Spoken voice cues for countdown, intervals, and finish',
                  value: _settings.voiceCoachEnabled,
                  icon: Icons.record_voice_over_rounded,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(voiceCoachEnabled: val));
                  },
                ),

                // 4. SESLENDİRME KOMBOSU (Voice Coach Combo)
                if (_settings.voiceCoachEnabled)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _settings.voiceCoachId,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF262626),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF161616),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            items: VoiceCoachService.availableProfiles.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.id,
                                child: Row(
                                  children: [
                                    Icon(p.isMale ? Icons.face : Icons.face_3, color: const Color(0xFF00E676), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        isTr ? p.nameTr : p.nameEn,
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _updateSettings(_settings.copyWith(voiceCoachId: val));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => _voiceCoach.testVoice(),
                          icon: const Icon(Icons.volume_up, color: Color(0xFF00E676), size: 26),
                          tooltip: l10n?.testVoice ?? 'Test Voice Announcement',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 5. OTHER GENERAL SWITCHES
                SettingsSwitchTile(
                  title: l10n?.vibration ?? 'Haptic Feedback',
                  subtitle: l10n?.vibrationSubtitle ?? 'Haptic pulses on interval transitions',
                  value: _settings.vibrationEnabled,
                  icon: Icons.vibration,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(vibrationEnabled: val));
                  },
                ),
                SettingsSwitchTile(
                  title: l10n?.keepScreenOn ?? 'Keep Screen Awake',
                  subtitle: l10n?.keepScreenOnSubtitle ?? 'Screen stays on during workouts',
                  value: _settings.wakelockEnabled,
                  icon: Icons.stay_current_portrait,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(wakelockEnabled: val));
                  },
                ),

                const SizedBox(height: 20),

                // 4. LANGUAGE (Item 0: English default)
                SettingsSectionHeader(title: l10n?.language ?? 'LANGUAGE'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n?.appLanguage ?? 'App Language',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: currentLang,
                        dropdownColor: const Color(0xFF262626),
                        underline: const SizedBox(),
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English (EN)')),
                          DropdownMenuItem(value: 'tr', child: Text('Türkçe (TR)')),
                        ],
                        onChanged: (lang) {
                          if (lang != null) {
                            widget.onLocaleChanged(Locale(lang));
                            _updateSettings(_settings.copyWith(languageCode: lang));
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. ABOUT
                SettingsSectionHeader(title: l10n?.aboutTitle ?? 'ABOUT'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified, color: Color(0xFF00E676), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'MyTimer Pro • WOD Edition v1.0.0',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.aboutDesc ?? 'Engineered for CrossFit, HIIT, functional fitness, and WOD competitions.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.lock_outline, color: Color(0xFF00E5FF), size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n?.cloudSyncNotice ?? 'All timers and workout logs are stored locally on your device.',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }
}
