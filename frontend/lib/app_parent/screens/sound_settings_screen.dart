import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundSettingsScreen extends StatefulWidget {
  const SoundSettingsScreen({super.key});

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  double _ttsVolume = 1.0;
  double _ttsRate = 0.5;
  double _ttsPitch = 1.0;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ttsVolume = prefs.getDouble('tts_volume') ?? 1.0;
      _ttsRate = prefs.getDouble('tts_rate') ?? 0.5;
      _ttsPitch = prefs.getDouble('tts_pitch') ?? 1.0;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Cài đặt âm thanh',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: SwitchListTile(
              title: Text(
                'Bật âm thanh',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              subtitle: Text(
                'Bật/tắt tất cả âm thanh trong app',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.none,
                ),
              ),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
                _saveSetting('sound_enabled', value);
              },
            ),
          ),
          SizedBox(height: 24.h),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Âm lượng Text-to-Speech',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Slider(
                    value: _ttsVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_ttsVolume * 100).toInt()}%',
                    onChanged: (value) {
                      setState(() => _ttsVolume = value);
                      _saveSetting('tts_volume', value);
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tốc độ đọc',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Slider(
                    value: _ttsRate,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_ttsRate * 100).toInt()}%',
                    onChanged: (value) {
                      setState(() => _ttsRate = value);
                      _saveSetting('tts_rate', value);
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cao độ giọng nói',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Slider(
                    value: _ttsPitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: _ttsPitch.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() => _ttsPitch = value);
                      _saveSetting('tts_pitch', value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


