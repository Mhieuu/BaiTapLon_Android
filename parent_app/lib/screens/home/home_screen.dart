import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/medicine_service.dart';
import '../../services/checkin_service.dart';
import '../../services/alert_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = ParentAuthService();
  final _medicineService = MedicineService();
  String? _elderId;
  bool _isLoading = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _loadParentInfo();
  }

  Future<void> _loadParentInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final parent = await _authService.getParentUser(uid);
      if (mounted && parent != null) {
        setState(() {
          _elderId = parent.elderId;
        });
      }
    }
  }

  Future<void> _handleMedicineTaken() async {
    if (_elderId == null) return;

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    try {
      final success = await _medicineService.logMedicineTaken(
        elderId: _elderId!,
        scheduleId: 'today',
        medicineName: 'Thuốc hôm nay',
        quantity: 1,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _feedback = success ? 'Đã ghi nhận thuốc' : 'Lỗi, thử lại';
        });

        if (success) {
          // Hiển thị feedback screen tạm thời
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            setState(() {
              _feedback = null;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _feedback = 'Lỗi: $e';
        });
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (_elderId == null) return;

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    try {
      final checkinService = CheckinService();
      final success = await checkinService.logCheckin(_elderId!);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _feedback = success ? 'Check-in thành công' : 'Lỗi, thử lại';
        });

        if (success) {
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            setState(() {
              _feedback = null;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _feedback = 'Lỗi: $e';
        });
      }
    }
  }

  Future<void> _handleSOS() async {
    if (_elderId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final alertService = AlertService();
      final success = await alertService.createSOSAlert(_elderId!);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('SOS Gửi Thành Công'),
              content: const Text('Người nhà đã nhận được cảnh báo'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _feedback != null ? _buildFeedbackScreen() : _buildMainScreen(),
    );
  }

  Widget _buildFeedbackScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          Text(
            _feedback!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Con đã nhận được xác nhận',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Button 1: Đã Uống Thuốc
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 100,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleMedicineTaken,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Đã Uống Thuốc',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          // Button 2: Check-in
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 100,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Check-in',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          // Button 3: SOS
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 100,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
