import 'package:flutter/material.dart';
import '../models/timer_settings.dart';
import '../repositories/local_timer_repository.dart';
import '../services/sound_service.dart';
import '../services/wakelock_service.dart';

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
      _wakelockService.wakelockEnabled = s.wakelockEnabled;
    }
  }

  Future<void> _updateSettings(TimerSettings newSettings) async {
    setState(() => _settings = newSettings);
    await _repository.saveSettings(newSettings);
    _soundService.soundEnabled = newSettings.soundEnabled;
    _soundService.vibrationEnabled = newSettings.vibrationEnabled;
    _wakelockService.wakelockEnabled = newSettings.wakelockEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AYARLAR',
          style: TextStyle(
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
                _buildSectionHeader('GENEL'),
                _buildSwitchTile(
                  title: 'Ses Efektleri',
                  subtitle: 'Geri sayım ve aralık geçiş sinyalleri',
                  value: _settings.soundEnabled,
                  icon: Icons.volume_up,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(soundEnabled: val));
                  },
                ),
                _buildSwitchTile(
                  title: 'Titreşim',
                  subtitle: 'Aralık geçişlerinde haptik geri bildirim',
                  value: _settings.vibrationEnabled,
                  icon: Icons.vibration,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(vibrationEnabled: val));
                  },
                ),
                _buildSwitchTile(
                  title: 'Ekranı Açık Tut',
                  subtitle: 'Antrenman sırasında telefon ekranı kapanmaz',
                  value: _settings.wakelockEnabled,
                  icon: Icons.stay_current_portrait,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(wakelockEnabled: val));
                  },
                ),

                const SizedBox(height: 20),
                _buildSectionHeader('SES TESTİ'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _soundService.playCountdownBeep(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFB300)),
                          ),
                          child: const Text('Geri Sayım', style: TextStyle(color: Color(0xFFFFB300))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _soundService.playWorkBeep(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00E676)),
                          ),
                          child: const Text('Başlama', style: TextStyle(color: Color(0xFF00E676))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _soundService.playRestBeep(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFF3D00)),
                          ),
                          child: const Text('Dinlenme', style: TextStyle(color: Color(0xFFFF3D00))),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionHeader('DİL / LANGUAGE'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Uygulama Dili',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      DropdownButton<String>(
                        value: widget.currentLocale.languageCode,
                        dropdownColor: const Color(0xFF262626),
                        underline: const SizedBox(),
                        style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 15),
                        items: const [
                          DropdownMenuItem(value: 'tr', child: Text('Türkçe (TR)')),
                          DropdownMenuItem(value: 'en', child: Text('English (EN)')),
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
                _buildSectionHeader('HAKKINDA & BULUT SENKRONİZASYONU'),
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
                          Text(
                            'MyTimer v1.0.0 (Release Build)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'CrossFit ve fonksiyonel fitness antrenmanları için tasarlandı. Bu sürüm Google Play Store test programı ve hesap aktivasyonu için hazırlandı.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Icon(Icons.lock_outline, color: Color(0xFF00E5FF), size: 16),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Özel timerlar cihazınızda saklanır. Backend bağlantısı kurulduğunda bulut üzerinden otomatik eşitlenecektir.',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        secondary: Icon(icon, color: value ? const Color(0xFF00E676) : Colors.white38),
        activeThumbColor: const Color(0xFF00E676),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
