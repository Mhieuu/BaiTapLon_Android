import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/medication_schedule.dart';
import '../../viewmodels/medication_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/notification_service.dart';

class ScheduleScreen extends StatefulWidget {
  final MedicationSchedule? schedule;
  const ScheduleScreen({super.key, this.schedule});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  // Sử dụng 0 = CN, 1 = T2, ..., 6 = T7
  List<int> _selectedDays = [];
  List<DateTime> _selectedSpecificDates = [];
  bool _useSpecificDates = false; // true = chọn ngày cụ thể, false = chọn ngày trong tuần

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      final s = widget.schedule!;
      _medicationNameController.text = s.medicationName;
      _dosageController.text = s.dosage;
      _selectedDays = List<int>.from(s.daysOfWeek);
      _selectedTime = TimeOfDay(hour: s.time.hour, minute: s.time.minute);
      
      // Load specific dates nếu có
      if (s.specificDates != null && s.specificDates!.isNotEmpty) {
        _useSpecificDates = true;
        _selectedSpecificDates = s.specificDates!.map((dateStr) {
          try {
            return DateTime.parse(dateStr);
          } catch (e) {
            return DateTime.now();
          }
        }).toList();
      }
    }
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _selectSpecificDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      // Chỉ thêm nếu chưa có
      final dateStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      final exists = _selectedSpecificDates.any((d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}' == dateStr);
      
      if (!exists) {
        setState(() {
          _selectedSpecificDates.add(picked);
          _selectedSpecificDates.sort((a, b) => a.compareTo(b));
        });
      }
    }
  }

  Future<void> _saveSchedule() async {
    if (_medicationNameController.text.isEmpty || 
        _dosageController.text.isEmpty) {
      _showError('Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (!_useSpecificDates && _selectedDays.isEmpty) {
      _showError('Vui lòng chọn ít nhất một ngày trong tuần');
      return;
    }

    if (_useSpecificDates && _selectedSpecificDates.isEmpty) {
      _showError('Vui lòng chọn ít nhất một ngày cụ thể');
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final medicationViewModel = context.read<MedicationViewModel>();
    
    final carer = authViewModel.currentUser;
    if (carer == null || carer.parentId == null) {
      _showError('Vui lòng liên kết với tài khoản cha mẹ trước');
      return;
    }

    // Chuyển đổi specificDates sang format yyyy-MM-dd
    final specificDatesStr = _useSpecificDates
        ? _selectedSpecificDates.map((date) {
            return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          }).toList()
        : null;

    final schedule = MedicationSchedule(
      id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      carerId: carer.id,
      elderId: carer.parentId!,
      medicationName: _medicationNameController.text,
      dosage: _dosageController.text,
      time: MedicationTime(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      ),
      daysOfWeek: _useSpecificDates ? [] : _selectedDays,
      specificDates: specificDatesStr,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final bool success;
    if (widget.schedule == null) {
      success = await medicationViewModel.createSchedule(schedule);
    } else {
      success = await medicationViewModel.updateSchedule(schedule.id, schedule);
    }
    
    if (!success) {
      _showError(medicationViewModel.errorMessage ?? 'Lỗi tạo lịch');
      return;
    }

    // Đặt thông báo local, nếu thiết bị không cho phép exact alarm thì báo nhưng vẫn lưu DB
    try {
      if (_useSpecificDates) {
        // Đặt notification cho các ngày cụ thể
        for (final date in _selectedSpecificDates) {
          final scheduledDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedTime.hour,
            _selectedTime.minute,
          );
          
          // Chỉ đặt notification nếu ngày chưa qua
          if (scheduledDateTime.isAfter(DateTime.now())) {
            await NotificationService().scheduleMedicationReminder(
              id: schedule.id.hashCode + date.millisecondsSinceEpoch,
              title: 'Nhắc uống thuốc',
              body: 'Đã đến giờ uống ${_medicationNameController.text}',
              scheduledTime: scheduledDateTime,
            );
          }
        }
      } else {
        // Đặt notification cho ngày trong tuần
        for (final day in _selectedDays) {
          final nextDate = _getNextDateForDay(day);
          if (nextDate != null) {
            final scheduledDateTime = DateTime(
              nextDate.year,
              nextDate.month,
              nextDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );
            
            await NotificationService().scheduleMedicationReminder(
              id: schedule.id.hashCode + day,
              title: 'Nhắc uống thuốc',
              body: 'Đã đến giờ uống ${_medicationNameController.text}',
              scheduledTime: scheduledDateTime,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lưu lịch thành công nhưng chưa cấp quyền báo thức chính xác: $e'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đã lưu lịch (${_selectedTime.format(context)} giờ, múi giờ thiết bị VN)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  DateTime? _getNextDateForDay(int dayOfWeek) {
    final now = DateTime.now();
    final currentDay = now.weekday % 7;
    int daysToAdd = (dayOfWeek - currentDay) % 7;
    if (daysToAdd == 0) {
      final scheduledTime = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
      if (now.isAfter(scheduledTime)) {
        daysToAdd = 7;
      }
    }
    return now.add(Duration(days: daysToAdd));
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Lỗi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Tạo lịch uống thuốc',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication Name
              _buildSectionTitle(
                icon: Icons.medication_liquid_rounded,
                title: 'Tên thuốc',
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _medicationNameController,
                placeholder: 'Ví dụ: Thuốc Huyết áp',
                icon: Icons.medication_liquid_rounded,
              )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
              
              SizedBox(height: 24.h),
              
              // Dosage
              _buildSectionTitle(
                icon: Icons.numbers_rounded,
                title: 'Liều lượng',
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _dosageController,
                placeholder: 'Ví dụ: 1 viên, 2 viên',
                icon: Icons.numbers_rounded,
              )
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),
              
              SizedBox(height: 24.h),
              
              // Time
              _buildSectionTitle(
                icon: Icons.access_time_rounded,
                title: 'Giờ uống thuốc',
              ),
              SizedBox(height: 12.h),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _selectTime,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          _selectedTime.format(context),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),
              
              SizedBox(height: 24.h),
              
              // Chọn loại lịch: Ngày trong tuần hoặc Ngày cụ thể
              _buildSectionTitle(
                icon: Icons.calendar_month_rounded,
                title: 'Loại lịch',
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildScheduleTypeChip(
                      'Ngày trong tuần',
                      !_useSpecificDates,
                      () => setState(() => _useSpecificDates = false),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildScheduleTypeChip(
                      'Ngày cụ thể',
                      _useSpecificDates,
                      () => setState(() => _useSpecificDates = true),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Days of Week hoặc Specific Dates
              if (!_useSpecificDates) ...[
                _buildSectionTitle(
                  icon: Icons.calendar_month_rounded,
                  title: 'Chọn ngày trong tuần',
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildDayChip('CN', 0, Icons.wb_sunny_rounded),
                    _buildDayChip('T2', 1, Icons.calendar_today_rounded),
                    _buildDayChip('T3', 2, Icons.calendar_today_rounded),
                    _buildDayChip('T4', 3, Icons.calendar_today_rounded),
                    _buildDayChip('T5', 4, Icons.calendar_today_rounded),
                    _buildDayChip('T6', 5, Icons.calendar_today_rounded),
                    _buildDayChip('T7', 6, Icons.calendar_today_rounded),
                  ],
                )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),
              ] else ...[
                _buildSectionTitle(
                  icon: Icons.event_rounded,
                  title: 'Chọn ngày cụ thể',
                ),
                SizedBox(height: 12.h),
                // Hiển thị danh sách ngày đã chọn
                if (_selectedSpecificDates.isNotEmpty)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _selectedSpecificDates.map((date) {
                      return Chip(
                        label: Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.none,
                          ),
                        ),
                        deleteIcon: Icon(Icons.close, size: 18.sp),
                        onDeleted: () {
                          setState(() {
                            _selectedSpecificDates.remove(date);
                          });
                        },
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        deleteIconColor: Theme.of(context).colorScheme.primary,
                      );
                    }).toList(),
                  ),
                SizedBox(height: 12.h),
                // Nút thêm ngày
                OutlinedButton.icon(
                  onPressed: _selectSpecificDate,
                  icon: Icon(Icons.add_circle_outline_rounded),
                  label: Text('Thêm ngày'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ],
              
              SizedBox(height: 40.h),
              
              // Save Button
              Consumer<MedicationViewModel>(
                builder: (context, medicationViewModel, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: medicationViewModel.isLoading ? null : _saveSchedule,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: medicationViewModel.isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 20.sp,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Lưu lịch',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 400.ms)
                    .slideY(begin: 0.1, end: 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        decoration: TextDecoration.none,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
          decoration: TextDecoration.none,
        ),
        prefixIcon: Container(
          margin: EdgeInsets.all(8.w),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20.sp,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleTypeChip(String label, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(String label, int day, IconData icon) {
    final isSelected = _selectedDays.contains(day);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleDay(day),
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isSelected
                ? null
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

