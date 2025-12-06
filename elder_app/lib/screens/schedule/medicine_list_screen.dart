import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/medicine_model.dart';
import '../../services/medicine_service.dart';
import 'create_schedule_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({Key? key}) : super(key: key);

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final _medicineService = MedicineService();
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final elderId = _firebaseAuth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Uống Thuốc'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<List<MedicineSchedule>>(
        stream: _medicineService.getSchedulesStream(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

          final medicines = snapshot.data ?? [];

          if (medicines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có lịch uống thuốc nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateScheduleScreen(),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm Lịch Uống Thuốc'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort by scheduled time
          medicines.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length + 1, // +1 for FAB
            itemBuilder: (context, index) {
              if (index == medicines.length) {
                return const SizedBox(height: 80); // Space for FAB
              }

              final medicine = medicines[index];
              final isTaken = medicine.status == 'done';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isTaken ? Colors.green[100] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: isTaken ? Colors.green : Colors.blue,
                    ),
                  ),
                  title: Text(
                    medicine.medicineName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isTaken
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '⏰ ${medicine.scheduledTime}  |  💊 ${medicine.quantity} viên',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (medicine.notes != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Ghi chú: ${medicine.notes}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: isTaken
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: isTaken
                      ? null
                      : () {
                          // Mark as taken
                          _markAsTaken(medicine.id);
                        },
                );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateScheduleScreen(),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _markAsTaken(String medicineId) async {
    final success = await _medicineService.markMedicineAsTaken(medicineId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã ghi nhận uống thuốc!'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi ghi nhận')),
      );
    }
  }
}
