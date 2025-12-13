import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/medication_schedule.dart';
import '../../models/check_in.dart';
import '../../viewmodels/medication_viewmodel.dart';
import '../../viewmodels/checkin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../repositories/checkin_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api_service.dart';
import '../../services/alert_service.dart';
import '../../theme/cupertino_theme.dart';
import '../widgets/photo_slideshow.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  bool _isSendingCallRequest = false;
  
  MedicationSchedule? _currentMedication;
  bool _hasCheckedIn = false;
  bool _animationsInitialized = false;
  late AnimationController _pulseController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations FIRST
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut),
    );
    
    _animationsInitialized = true;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTTS();
      _loadCurrentMedication();
      _checkForMedicationTime();
    });
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeTTS() async {
    await _tts.setLanguage("vi-VN");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _loadCurrentMedication() async {
    final authViewModel = context.read<AuthViewModel>();
    final medicationViewModel = context.read<MedicationViewModel>();
    
    if (authViewModel.currentUser != null) {
      final elderId = authViewModel.currentUser!.id;
      print('📅 [HOME_TAB] Đang tải lịch cho elder: $elderId');
      
      // Tải lịch theo chính elder hiện tại để không dính chéo tài khoản
      await medicationViewModel.loadSchedulesByElder(elderId);
      
      print('📅 [HOME_TAB] Đã tải ${medicationViewModel.schedules.length} lịch');
      medicationViewModel.schedules.forEach((s) {
        print('  - Lịch: ${s.medicationName}, daysOfWeek: ${s.daysOfWeek}, specificDates: ${s.specificDates}');
        print('  - isToday(): ${s.isToday()}, isTimeToTake(): ${s.isTimeToTake()}');
      });
      
      _currentMedication = medicationViewModel.getCurrentMedication();
      
      if (_currentMedication != null) {
        print('📅 [HOME_TAB] Lịch hiện tại: ${_currentMedication!.medicationName}');
        final checkIn = await CheckInRepository().getTodayCheckIn(_currentMedication!.id);
        setState(() {
          _hasCheckedIn = checkIn != null;
        });
        
        if (checkIn == null) {
          _speak('Đã đến giờ uống thuốc ${_currentMedication!.medicationName}. Vui lòng bấm nút để xác nhận.');
        }
      } else {
        print('📅 [HOME_TAB] Không có lịch nào cho hôm nay');
        // Reset trạng thái nếu không có lịch
        setState(() {
          _hasCheckedIn = false;
        });
      }
    } else {
      setState(() {
        _currentMedication = null;
        _hasCheckedIn = false;
      });
    }
  }

  Future<void> _checkForMedicationTime() async {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _loadCurrentMedication();
        _checkForMedicationTime();
      }
    });
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> _handleCheckIn() async {
    if (_currentMedication == null || _hasCheckedIn) return;

    final authViewModel = context.read<AuthViewModel>();
    final checkInViewModel = context.read<CheckInViewModel>();
    
    if (authViewModel.currentUser == null) return;

    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _currentMedication!.time.hour,
      _currentMedication!.time.minute,
    );
    
    final isOnTime = now.difference(scheduledTime).inMinutes <= 30;

    final checkIn = CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationScheduleId: _currentMedication!.id,
      elderId: authViewModel.currentUser!.id,
      checkInTime: now,
      isOnTime: isOnTime,
    );

    final success = await checkInViewModel.createCheckIn(checkIn);
    
    if (success) {
      setState(() => _hasCheckedIn = true);
      _speak('Cảm ơn bạn đã xác nhận uống thuốc.');
    }
  }

  Future<void> _handleSOS() async {
    final authViewModel = context.read<AuthViewModel>();
    final elder = authViewModel.currentUser;
    
    if (elder == null || elder.carerId == null) {
      _speak('Không tìm thấy số điện thoại của con. Vui lòng thử lại.');
      return;
    }

    try {
      final authRepo = AuthRepository();
      final carer = await authRepo.getUserById(elder.carerId!);
      
      if (carer != null) {
        // Gửi SOS notification cho con
        final alertService = AlertService();
        await alertService.sendSOSAlert(
          carerId: carer.id,
          elderName: elder.name,
          elderPhone: elder.phoneNumber,
        );

        // Gọi điện thoại
        if (carer.phoneNumber.isNotEmpty) {
          // Loại bỏ khoảng trắng và ký tự đặc biệt, chỉ giữ lại số
          final cleanPhoneNumber = carer.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
          final uri = Uri.parse('tel:$cleanPhoneNumber');
          
          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(
                uri,
                mode: LaunchMode.platformDefault,
              );
              _speak('Đang mở ứng dụng điện thoại.');
            } else {
              _speak('Không thể mở ứng dụng điện thoại. Vui lòng thử lại.');
            }
          } catch (e) {
            // Thử lại với externalNonBrowserApplication nếu platformDefault không hoạt động
            try {
              await launchUrl(
                uri,
                mode: LaunchMode.externalNonBrowserApplication,
              );
              _speak('Đang mở ứng dụng điện thoại.');
            } catch (e2) {
              _speak('Không thể mở ứng dụng điện thoại. Vui lòng thử lại.');
            }
          }
        } else {
          _speak('Không tìm thấy số điện thoại của con.');
        }
      }
    } catch (e) {
      _speak('Có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  Future<void> _handleCallChild() async {
    if (_isSendingCallRequest) return;

    final authViewModel = context.read<AuthViewModel>();
    final elder = authViewModel.currentUser;
    
    if (elder == null || elder.carerId == null) {
      _speak('Không tìm thấy số điện thoại của con.');
      return;
    }

    try {
      final authRepo = AuthRepository();
      final carer = await authRepo.getUserById(elder.carerId!);
      
      if (carer == null) {
        _speak('Không tìm thấy thông tin của con.');
        return;
      }

      setState(() => _isSendingCallRequest = true);

      await ApiService().createCallRequest(
        elderId: elder.id,
        carerId: carer.id,
      );

      _speak('Đã gửi yêu cầu gọi lại cho con. Con sẽ gọi khi rảnh.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã gửi yêu cầu gọi lại cho con'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _speak('Có lỗi xảy ra. Vui lòng thử lại.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi yêu cầu thất bại: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingCallRequest = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationViewModel>(
      builder: (context, medicationViewModel, child) {
        if (medicationViewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader()
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
                .then()
                .shimmer(duration: 1500.ms, delay: 300.ms),
              
              Gap(24.h),
              
              // Photo Slideshow
              const PhotoSlideshow()
                .animate()
                .fadeIn(duration: 700.ms, delay: 100.ms, curve: Curves.easeOut)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 700.ms, curve: Curves.easeOutBack)
                .then()
                .shimmer(duration: 2000.ms, delay: 400.ms),
              
              Gap(24.h),
              
              // Medication reminder
              if (_currentMedication != null && !_hasCheckedIn)
                _buildMedicationReminder()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack)
                  .shimmer(duration: 2500.ms, delay: 600.ms)
                  .then()
                  .moveY(begin: 0, end: -2, duration: 2000.ms, curve: Curves.easeInOut)
                  .then()
                  .moveY(begin: -2, end: 0, duration: 2000.ms, curve: Curves.easeInOut)
                  .then(),
              
              Gap(32.h),
              
              // Quick Actions Section
              _buildQuickActionsSection()
                .animate()
                .fadeIn(duration: 700.ms, delay: 300.ms, curve: Curves.easeOut)
                .slideX(begin: -0.1, end: 0, duration: 700.ms, curve: Curves.easeOutCubic),
              
              Gap(32.h),
              
              // Today's Status
              _buildTodayStatus()
                .animate()
                .fadeIn(duration: 700.ms, delay: 400.ms, curve: Curves.easeOut)
                .slideX(begin: 0.1, end: 0, duration: 700.ms, curve: Curves.easeOutCubic)
                .then()
                .shimmer(duration: 1500.ms, delay: 200.ms),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader() {
    final authViewModel = context.read<AuthViewModel>();
    final userName = authViewModel.currentUser?.name ?? 'Bạn';
    final timeOfDay = _getTimeOfDay();
    
    return GlassmorphicContainer(
      width: double.infinity,
      height: 140.h,
      padding: EdgeInsets.all(20.w),
      borderRadius: 24.r,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          CupertinoAppTheme.primaryBlue.withOpacity(0.8),
          CupertinoAppTheme.primaryBlue.withOpacity(0.6),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.waving_hand_rounded,
                size: 32.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$timeOfDay, $userName!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 26.sp.clamp(22.0, 28.0),
                      decoration: TextDecoration.none,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Chúc bạn một ngày tốt lành',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                      fontSize: 18.sp.clamp(16.0, 20.0),
                      decoration: TextDecoration.none,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Icon(
                Icons.dashboard_rounded,
                size: 22.sp,
                color: CupertinoAppTheme.primaryBlue,
              ),
              SizedBox(width: 8.w),
              Text(
                'Thao tác nhanh',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        Gap(16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.emergency_rounded,
                title: 'SOS',
                subtitle: 'Khẩn cấp',
                color: const Color(0xFFE53935),
                onTap: _handleSOS,
                isPulsing: true,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionCard(
                icon: Icons.medication_liquid_rounded,
                title: 'Thuốc',
                subtitle: _hasCheckedIn ? 'Đã uống' : 'Chưa uống',
                color: _currentMedication != null && !_hasCheckedIn
                    ? const Color(0xFF43A047)
                    : CupertinoColors.systemGrey,
                onTap: _currentMedication != null && !_hasCheckedIn
                    ? _handleCheckIn
                    : () => _speak('Hiện tại chưa có lịch uống thuốc.'),
                isPulsing: _currentMedication != null && !_hasCheckedIn,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionCard(
                icon: Icons.phone_rounded,
                title: 'Gọi',
                subtitle: 'Con',
                color: CupertinoAppTheme.primaryBlue,
                onTap: _handleCallChild,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isPulsing = false,
  }) {
    Widget card = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
          child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          constraints: BoxConstraints(
            minHeight: 180.h.clamp(180.0, double.infinity),
            maxHeight: 200.h.clamp(200.0, double.infinity),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.12),
                color.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: color.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: isPulsing ? 20 : 12,
                offset: Offset(0, isPulsing ? 8 : 4),
                spreadRadius: isPulsing ? 2 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w.clamp(80.0, 90.0),
                height: 80.w.clamp(80.0, 90.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 40.sp.clamp(32.0, 44.0),
                ),
              ),
              Gap(12.h),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 24.sp.clamp(22.0, 26.0),
                  decoration: TextDecoration.none,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(4.h),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.withOpacity(0.75),
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp.clamp(14.0, 18.0),
                  decoration: TextDecoration.none,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    if (isPulsing && _animationsInitialized) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.98 + (_pulseAnimation.value * 0.02),
            child: card,
          );
        },
      );
    }
    return card;
  }

  Widget _buildTodayStatus() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 22.sp,
                  color: CupertinoAppTheme.primaryBlue,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Trạng thái hôm nay',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 26.sp.clamp(24.0, double.infinity),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            Gap(16.h),
            if (_currentMedication != null) ...[
              Builder(
                builder: (context) {
                  final timeStr = _currentMedication!.time.toString();
                  String displayTime = timeStr;
                  
                  if (_currentMedication!.specificDates != null && 
                      _currentMedication!.specificDates!.isNotEmpty) {
                    try {
                      final datesStr = _currentMedication!.specificDates!.map((d) {
                        try {
                          final date = DateTime.parse(d);
                          return '${date.day}/${date.month}/${date.year}';
                        } catch (e) {
                          return d;
                        }
                      }).join(', ');
                      displayTime = '$timeStr ($datesStr)';
                    } catch (e) {
                      displayTime = timeStr;
                    }
                  }
                  
                  return _buildStatusItem(
                    icon: Icons.medication_liquid_rounded,
                    title: _currentMedication!.medicationName,
                    status: _hasCheckedIn ? 'Đã uống' : 'Chưa uống',
                    statusColor: _hasCheckedIn
                        ? const Color(0xFF43A047)
                        : const Color(0xFFFF9800),
                    time: displayTime,
                  );
                },
              ),
            ] else ...[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20.sp,
                        color: CupertinoColors.systemGrey,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Chưa có lịch uống thuốc hôm nay',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 22.sp.clamp(20.0, double.infinity),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
    required String time,
  }) {
    return Card(
      elevation: 0,
      color: statusColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: statusColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp.clamp(24.0, double.infinity),
                      decoration: TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // Thời gian và trạng thái trên cùng một hàng nhưng có thể wrap
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14.sp,
                            color: CupertinoColors.secondaryLabel,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              time,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 18.sp.clamp(16.0, 20.0),
                                decoration: TextDecoration.none,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          status,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp.clamp(16.0, 20.0),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationReminder() {
    final reminderContent = Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withOpacity(0.15),
            const Color(0xFFFF9800).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFFF9800),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF9800),
                  const Color(0xFFFF9800).withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 56.sp,
              color: Colors.white,
            ),
          ),
          
          Gap(20.h),
          
          Text(
            'ĐÃ ĐẾN GIỜ UỐNG THUỐC',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFFF9800),
              fontWeight: FontWeight.w500,
              fontSize: 28.sp.clamp(24.0, double.infinity),
              letterSpacing: 0.5,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
          
          Gap(16.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medication_liquid_rounded,
                size: 40.sp.clamp(32.0, double.infinity),
                color: const Color(0xFFFF9800),
              ),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  _currentMedication!.medicationName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFFF9800),
                    fontWeight: FontWeight.w500,
                    fontSize: 26.sp.clamp(24.0, double.infinity),
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          
          Gap(12.h),
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 24.sp.clamp(20.0, double.infinity),
                  color: const Color(0xFFFF9800),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Liều lượng: ${_currentMedication!.dosage}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFFF9800),
                    fontWeight: FontWeight.w500,
                    fontSize: 24.sp.clamp(24.0, double.infinity),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    if (!_animationsInitialized) {
      return reminderContent;
    }
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: reminderContent,
        );
      },
    );
  }
}

