import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeSettingsScreen extends StatefulWidget {
  const FontSizeSettingsScreen({super.key});

  @override
  State<FontSizeSettingsScreen> createState() => _FontSizeSettingsScreenState();
}

class _FontSizeSettingsScreenState extends State<FontSizeSettingsScreen> {
  double _fontSizeMultiplier = 1.0; // 1.0 = 24sp, 1.5 = 36sp, etc.

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSizeMultiplier = prefs.getDouble('font_size_multiplier') ?? 1.0;
    });
  }

  Future<void> _saveSetting(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size_multiplier', value);
  }

  String _getFontSizeLabel() {
    if (_fontSizeMultiplier <= 1.0) return 'Nhỏ';
    if (_fontSizeMultiplier <= 1.3) return 'Vừa';
    if (_fontSizeMultiplier <= 1.6) return 'Lớn';
    return 'Rất lớn';
  }

  @override
  Widget build(BuildContext context) {
    final baseFontSize = 24.0 * _fontSizeMultiplier;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Cài đặt cỡ chữ',
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
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cỡ chữ',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        _getFontSizeLabel(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Slider(
                    value: _fontSizeMultiplier,
                    min: 0.8,
                    max: 2.0,
                    divisions: 12,
                    label: '${baseFontSize.toStringAsFixed(0)}sp',
                    onChanged: (value) {
                      setState(() => _fontSizeMultiplier = value);
                      _saveSetting(value);
                    },
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Đây là ví dụ cỡ chữ hiện tại',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: baseFontSize,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
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
                    'Cỡ chữ mặc định',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Cỡ chữ tối thiểu: 24sp (đảm bảo dễ đọc)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.none,
                    ),
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


