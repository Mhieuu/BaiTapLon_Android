import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final carer = _authService.currentUser;
      if (carer != null) {
        final appointments = await _dbService.getAppointmentsByCarerId(carer.id);
        setState(() {
          _appointments = appointments;
          _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddAppointmentDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm lịch hẹn'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    hintText: 'Ví dụ: Tái khám Tim mạch',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Địa điểm',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Ngày'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Giờ'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final carer = _authService.currentUser;
        if (carer != null && carer.parentId != null) {
          final appointment = Appointment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            carerId: carer.id,
            elderId: carer.parentId!,
            title: titleController.text,
            description: descriptionController.text,
            dateTime: DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            ),
            location: locationController.text,
            createdAt: DateTime.now(),
          );

          await _dbService.createAppointment(appointment);
          _loadAppointments();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm lịch hẹn thành công')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có lịch hẹn',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.event,
                          size: 40,
                          color: appointment.isCompleted
                              ? Colors.grey
                              : (appointment.dateTime.isBefore(DateTime.now())
                                  ? Colors.orange
                                  : Colors.blue[700]),
                        ),
                        title: Text(
                          appointment.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: appointment.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime),
                            ),
                            if (appointment.location.isNotEmpty)
                              Text('Địa điểm: ${appointment.location}'),
                            if (appointment.description.isNotEmpty)
                              Text(appointment.description),
                          ],
                        ),
                        trailing: appointment.isCompleted
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () async {
                                  final updated = Appointment(
                                    id: appointment.id,
                                    carerId: appointment.carerId,
                                    elderId: appointment.elderId,
                                    title: appointment.title,
                                    description: appointment.description,
                                    dateTime: appointment.dateTime,
                                    location: appointment.location,
                                    isCompleted: true,
                                    createdAt: appointment.createdAt,
                                  );
                                  await _dbService.updateAppointment(updated);
                                  _loadAppointments();
                                },
                              ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAppointmentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Thêm lịch hẹn'),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}

