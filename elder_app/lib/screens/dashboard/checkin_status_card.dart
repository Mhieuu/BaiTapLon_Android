import 'package:flutter/material.dart';
import '../../services/checkin_service.dart';

class CheckinStatusCard extends StatefulWidget {
  final String elderId;

  const CheckinStatusCard({Key? key, required this.elderId}) : super(key: key);

  @override
  State<CheckinStatusCard> createState() => _CheckinStatusCardState();
}

class _CheckinStatusCardState extends State<CheckinStatusCard> {
  final _checkinService = CheckinService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _checkinService.getCheckinStatusStream(widget.elderId),
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
        final isCheckedIn = status?['checkin_today'] == true;
        final isLate = status?['is_checkin_late'] == true;
        final lastCheckinTime = status?['last_checkin_time'] != null
            ? DateTime.parse(status!['last_checkin_time'] as String)
            : null;

        Color cardColor = Colors.yellow[50]!;
        Color borderColor = Colors.orange;
        String statusText = 'Chưa check-in';

        if (isCheckedIn) {
          if (isLate) {
            cardColor = Colors.orange[50]!;
            borderColor = Colors.orange;
            statusText = 'Check-in trễ';
          } else {
            cardColor = Colors.green[50]!;
            borderColor = Colors.green;
            statusText = 'Check-in đúng giờ';
          }
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: cardColor,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.done_all, color: borderColor, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check-in',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isCheckedIn && lastCheckinTime != null)
                            Text(
                              'Lúc ${lastCheckinTime.hour.toString().padLeft(2, '0')}:${lastCheckinTime.minute.toString().padLeft(2, '0')} - $statusText',
                              style: TextStyle(
                                fontSize: 14,
                                color: borderColor,
                              ),
                            )
                          else
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 14,
                                color: borderColor,
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
