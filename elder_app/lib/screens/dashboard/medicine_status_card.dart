import 'package:flutter/material.dart';
import '../../services/medicine_service.dart';

class MedicineStatusCard extends StatefulWidget {
  final String elderId;

  const MedicineStatusCard({Key? key, required this.elderId}) : super(key: key);

  @override
  State<MedicineStatusCard> createState() => _MedicineStatusCardState();
}

class _MedicineStatusCardState extends State<MedicineStatusCard> {
  final _medicineService = MedicineService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _medicineService.getMedicineStatusStream(widget.elderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final status = snapshot.data;
        final isMedicineDone = status?['medicine_status'] == 'done';
        final lastMedicineTime = status?['last_medicine_time'] != null
            ? DateTime.parse(status!['last_medicine_time'] as String)
            : null;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isMedicineDone ? Colors.green[50] : Colors.red[50],
              border: Border.all(
                color: isMedicineDone ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isMedicineDone ? Icons.check_circle : Icons.medication,
                      color: isMedicineDone ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Uống Thuốc',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isMedicineDone && lastMedicineTime != null)
                            Text(
                              'Đã uống lúc ${lastMedicineTime.hour.toString().padLeft(2, '0')}:${lastMedicineTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green[700],
                              ),
                            )
                          else
                            const Text(
                              'Chưa uống thuốc hôm nay',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 211, 48, 48),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
