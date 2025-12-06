import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medicine_status_card.dart';
import 'checkin_status_card.dart';
import 'alert_status_card.dart';
import '../schedule/medicine_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late String _elderId;

  @override
  void initState() {
    super.initState();
    _elderId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Người Cao Tuổi'),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                currentUser?.email ?? 'User',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information),
            label: 'Lịch thuốc',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Ảnh'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Cảnh báo'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildScheduleScreen();
      case 2:
        return _buildPhotoScreen();
      case 3:
        return _buildAlertScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          MedicineStatusCard(elderId: _elderId),
          const SizedBox(height: 16),
          CheckinStatusCard(elderId: _elderId),
          const SizedBox(height: 16),
          AlertStatusCard(elderId: _elderId),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildScheduleScreen() {
    return const MedicineListScreen();
  }

  Widget _buildPhotoScreen() {
    return const Center(child: Text('Màn hình Ảnh (Coming soon)'));
  }

  Widget _buildAlertScreen() {
    return const Center(child: Text('Màn hình Cảnh báo (Coming soon)'));
  }
}
