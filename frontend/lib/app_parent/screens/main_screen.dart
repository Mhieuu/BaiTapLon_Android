import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'home_tab.dart';
import 'history_tab.dart';
import 'settings_tab.dart';

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({super.key});

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    HistoryTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        height: 70.h,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.home_rounded, size: 24.sp),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.history_rounded, size: 24.sp),
            label: 'Lịch sử',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.settings_rounded, size: 24.sp),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
