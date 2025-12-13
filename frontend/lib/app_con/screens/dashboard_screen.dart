import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/medication_schedule.dart';
import '../../viewmodels/medication_viewmodel.dart';
import '../../viewmodels/checkin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../repositories/checkin_repository.dart';
import '../../services/background_service.dart';
import '../../services/notification_service.dart';
import '../../screens/login_screen.dart';
import 'schedule_screen.dart';
import 'history_screen.dart';
import 'photo_sharing_screen.dart';
import 'link_parent_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const int _pageSize = 5;
  int _currentPage = 0;
  bool _notificationsRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final medicationViewModel = context.read<MedicationViewModel>();
      
      if (authViewModel.currentUser != null) {
        final carerId = authViewModel.currentUser!.id;
        medicationViewModel.loadSchedulesByCarer(carerId);
        
        // Bắt đầu background service để kiểm tra alerts
        BackgroundService().startAlertChecking(carerId);
      }

      // Yêu cầu quyền thông báo nếu chưa làm
      if (!_notificationsRequested) {
        NotificationService().initialize();
        _notificationsRequested = true;
      }
    });
  }

  @override
  void dispose() {
    // Dừng background service khi logout
    BackgroundService().stopAlertChecking();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Đăng xuất',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (shouldLogout == true && mounted) {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.dashboard_rounded,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: _handleLogout,
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.logout_rounded,
              size: 20.sp,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LinkParentScreen()),
              );
            },
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.link_rounded,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () async {
              final authViewModel = context.read<AuthViewModel>();
              final user = authViewModel.currentUser;
              if (user != null) {
                await context
                    .read<MedicationViewModel>()
                    .loadSchedulesByCarer(user.id);
              }
            },
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Thông báo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.notifications_rounded,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<MedicationViewModel, AuthViewModel>(
          builder: (context, medicationViewModel, authViewModel, child) {
            return RefreshIndicator(
              onRefresh: () async {
                final user = authViewModel.currentUser;
                if (user != null) {
                  setState(() => _currentPage = 0);
                  await medicationViewModel.loadSchedulesByCarer(user.id);
                }
              },
              child: medicationViewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Welcome Header
                        SliverToBoxAdapter(
                          child: _buildWelcomeHeader(authViewModel.currentUser?.name ?? 'Bạn'),
                        ),
                        
                        // Error banner if load thất bại
                        if (medicationViewModel.errorMessage != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                              child: Card(
                                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.error_outline,
                                      color: Theme.of(context).colorScheme.error),
                                  title: Text(
                                    'Không tải được lịch',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Text(
                                    medicationViewModel.errorMessage!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  trailing: TextButton(
                                    onPressed: () async {
                                      final user = authViewModel.currentUser;
                                      if (user != null) {
                                        await medicationViewModel.loadSchedulesByCarer(user.id);
                                      }
                                    },
                                    child: const Text('Thử lại'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        // Statistics Cards
                        SliverToBoxAdapter(
                          child: _buildStatisticsCards(medicationViewModel),
                        ),
                        
                        // Status Today Section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    size: 24.sp,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Trạng thái hôm nay',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Status Cards
                        if (medicationViewModel.schedules.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final pagedSchedules = _getPagedSchedules(medicationViewModel.schedules);
                                final schedule = pagedSchedules[index];
                                return _buildScheduleStatusCard(schedule);
                              },
                              childCount: _getPagedSchedules(medicationViewModel.schedules).length,
                            ),
                          ),

                        if (medicationViewModel.schedules.length > _pageSize)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Trang ${_currentPage + 1}/${_getTotalPages(medicationViewModel.schedules.length)}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _currentPage > 0
                                            ? () => setState(() => _currentPage--)
                                            : null,
                                        icon: const Icon(Icons.chevron_left_rounded),
                                      ),
                                      IconButton(
                                        onPressed: (_currentPage + 1) <
                                                _getTotalPages(medicationViewModel.schedules.length)
                                            ? () => setState(() => _currentPage++)
                                            : null,
                                        icon: const Icon(Icons.chevron_right_rounded),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        // Quick Actions
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Icon(
                                        Icons.dashboard_rounded,
                                        size: 24.sp,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                Text(
                                  'Thao tác nhanh',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                _buildQuickActions(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(MedicationViewModel medicationViewModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.medication_liquid_rounded,
              title: 'Tổng lịch',
              value: '${medicationViewModel.schedules.length}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FutureBuilder(
              future: _getComplianceRate(medicationViewModel),
              builder: (context, snapshot) {
                final rate = snapshot.data ?? 0.0;
                return _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  title: 'Tuân thủ',
                  value: '${(rate * 100).toInt()}%',
                  color: const Color(0xFF43A047),
                );
              },
            ),
          ),
        ],
      ),
    )
      .animate()
      .fadeIn(duration: 400.ms, delay: 200.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Future<double> _getComplianceRate(MedicationViewModel medicationViewModel) async {
    if (medicationViewModel.schedules.isEmpty) return 0.0;
    
    final authViewModel = context.read<AuthViewModel>();
    final carer = authViewModel.currentUser;
    if (carer == null || carer.parentId == null) return 0.0;

    // Tính % tuân thủ trong tháng hiện tại
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    // Lấy tất cả check-ins trong tháng
    final checkIns = await CheckInRepository().getCheckInsByElderId(
      carer.parentId!,
      startDate: startOfMonth,
      endDate: now,
    );

    if (checkIns.isEmpty) return 0.0;

    // Tính số lần check-in đúng giờ
    final onTimeCount = checkIns.where((c) => c.isOnTime ?? false).length;
    return (onTimeCount / checkIns.length);
  }

  Widget _buildWelcomeHeader(String name) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              size: 36.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Xin chào, $name!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.3,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        'Theo dõi sức khỏe cha mẹ mỗi ngày',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
      .animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildScheduleStatusCard(MedicationSchedule schedule) {
    return Consumer<CheckInViewModel>(
      builder: (context, checkInViewModel, child) {
        return FutureBuilder(
          future: CheckInRepository().getTodayCheckIn(schedule.id),
          builder: (context, snapshot) {
            final checkIn = snapshot.data;
            final isCompleted = checkIn != null;
            final isTimeToTake = schedule.isTimeToTake();
            final statusColor = isCompleted 
                ? const Color(0xFF43A047)
                : (isTimeToTake 
                    ? const Color(0xFFFF9800)
                    : Theme.of(context).colorScheme.outline);

            return Card(
              elevation: 0,
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: statusColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              color: Theme.of(context).colorScheme.surface,
              child: ListTile(
                leading: Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.2),
                        statusColor.withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isCompleted 
                        ? Icons.check_circle_rounded
                        : Icons.medication_liquid_rounded,
                    color: statusColor,
                    size: 28.sp,
                  ),
                ),
                title: Text(
                  schedule.medicationName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${schedule.time.toString()} - ${schedule.dosage}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (schedule.specificDates != null && schedule.specificDates!.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  'Ngày: ${schedule.specificDates!.map((d) {
                                    try {
                                      final date = DateTime.parse(d);
                                      return '${date.day}/${date.month}/${date.year}';
                                    } catch (e) {
                                      return d;
                                    }
                                  }).join(', ')}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (checkIn != null) ...[
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16.sp,
                              color: const Color(0xFF43A047),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Đã uống lúc ${_formatTime(checkIn.checkInTime)}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF43A047),
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (isTimeToTake) ...[
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16.sp,
                              color: const Color(0xFFFF9800),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Chưa uống',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFFF9800),
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleScreen(schedule: schedule),
                        ),
                      );
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xóa lịch'),
                          content: Text('Bạn chắc chắn muốn xóa lịch ${schedule.medicationName}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Xóa',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await context
                            .read<MedicationViewModel>()
                            .deleteSchedule(schedule.id, schedule.carerId);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Sửa'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa'),
                    ),
                  ],
                ),
              ),
            )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_liquid_rounded,
            size: 80.sp,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: 24.h),
          Text(
            'Chưa có lịch uống thuốc',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Thêm lịch để bắt đầu theo dõi',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.calendar_month_rounded,
            title: 'Lịch trình',
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleScreen()),
              );
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildActionCard(
            icon: Icons.history_rounded,
            title: 'Lịch sử',
            color: const Color(0xFF43A047),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildActionCard(
            icon: Icons.photo_library_rounded,
            title: 'Ảnh',
            color: const Color(0xFFFF9800),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhotoSharingScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
                letterSpacing: 0.3,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
      .animate()
      .fadeIn(duration: 400.ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1))
      .then()
      .shimmer(duration: 1500.ms, delay: 200.ms);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  List<MedicationSchedule> _getPagedSchedules(List<MedicationSchedule> source) {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize) > source.length ? source.length : (start + _pageSize);
    return source.sublist(start, end);
  }

  int _getTotalPages(int totalItems) {
    if (totalItems == 0) return 1;
    return (totalItems / _pageSize).ceil();
  }
}

