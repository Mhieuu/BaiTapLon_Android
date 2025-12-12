import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _medicationReminders = true;
  bool _alertNotifications = true;
  bool _sosNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _medicationReminders = prefs.getBool('notification_medication') ?? true;
      _alertNotifications = prefs.getBool('notification_alert') ?? true;
      _sosNotifications = prefs.getBool('notification_sos') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Cài đặt thông báo',
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
                'Nhắc uống thuốc',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              subtitle: Text(
                'Nhận thông báo khi đến giờ uống thuốc',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.none,
                ),
              ),
              value: _medicationReminders,
              onChanged: (value) {
                setState(() => _medicationReminders = value);
                _saveSetting('notification_medication', value);
              },
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
            child: SwitchListTile(
              title: Text(
                'Cảnh báo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              subtitle: Text(
                'Nhận thông báo cảnh báo khẩn cấp',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.none,
                ),
              ),
              value: _alertNotifications,
              onChanged: (value) {
                setState(() => _alertNotifications = value);
                _saveSetting('notification_alert', value);
              },
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
            child: SwitchListTile(
              title: Text(
                'SOS Khẩn cấp',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              subtitle: Text(
                'Nhận thông báo khi có tín hiệu SOS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.none,
                ),
              ),
              value: _sosNotifications,
              onChanged: (value) {
                setState(() => _sosNotifications = value);
                _saveSetting('notification_sos', value);
              },
            ),
          ),
        ],
      ),
    );
  }
}


