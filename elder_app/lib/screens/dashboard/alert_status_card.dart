import 'package:flutter/material.dart';

class AlertStatusCard extends StatefulWidget {
  final String elderId;

  const AlertStatusCard({Key? key, required this.elderId}) : super(key: key);

  @override
  State<AlertStatusCard> createState() => _AlertStatusCardState();
}

class _AlertStatusCardState extends State<AlertStatusCard> {
  @override
  Widget build(BuildContext context) {
    // Simplified: Return static "no alerts" state for now
    // TODO: Integrate alert queries once Firestore indexes are created
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.green[50],
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Không có cảnh báo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mọi thứ đều bình thường',
                    style: TextStyle(fontSize: 14, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
