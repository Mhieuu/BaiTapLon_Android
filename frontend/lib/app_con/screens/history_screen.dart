import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/check_in.dart';
import '../../repositories/checkin_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final CheckInRepository _checkInRepository = CheckInRepository();
  List<CheckIn> _checkIns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final authViewModel = context.read<AuthViewModel>();
      final carer = authViewModel.currentUser;
      if (carer != null && carer.parentId != null) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final checkIns = await _checkInRepository.getCheckInsByElderId(
          carer.parentId!,
          startDate: startOfMonth,
          endDate: now,
        );
        if (mounted) {
          setState(() {
            _checkIns = checkIns;
            _checkIns.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculateComplianceRate() {
    if (_checkIns.isEmpty) return 0.0;
    final onTimeCount = _checkIns.where((c) => c.isOnTime).length;
    return (onTimeCount / _checkIns.length) * 100;
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
                Icons.history_rounded,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Lịch sử Check-in',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: _checkIns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 80.sp,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          Gap(24.h),
                          Text(
                            'Chưa có lịch sử check-in',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Gap(8.h),
                          Text(
                            'Lịch sử check-in sẽ hiển thị ở đây',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildComplianceCard(),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildCheckInCard(_checkIns[index], index);
                            },
                            childCount: _checkIns.length,
                          ),
                        ),
                        SliverToBoxAdapter(child: Gap(40.h)),
                      ],
                    ),
            ),
    );
  }

  Widget _buildComplianceCard() {
    final rate = _calculateComplianceRate();
    final rateColor = rate >= 90
        ? Theme.of(context).colorScheme.primary
        : (rate >= 70
            ? Colors.orange
            : Theme.of(context).colorScheme.error);
    
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rateColor.withOpacity(0.15),
            rateColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: rateColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: rateColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: rateColor,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Tỷ lệ tuân thủ tháng này',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Gap(20.h),
          Text(
            '${rate.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: rateColor,
              decoration: TextDecoration.none,
            ),
          ),
          Gap(12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: rateColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${_checkIns.where((c) => c.isOnTime ?? false).length}/${_checkIns.length} lần đúng giờ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: rateColor,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    )
      .animate()
      .fadeIn(duration: 500.ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildCheckInCard(CheckIn checkIn, int index) {
    final isOnTime = checkIn.isOnTime ?? false;
    final statusColor = isOnTime
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: statusColor.withOpacity(0.05),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
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
                isOnTime ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: statusColor,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(checkIn.checkInTime),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        DateFormat('HH:mm').format(checkIn.checkInTime),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isOnTime ? 'Đúng giờ' : 'Trễ',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              isOnTime ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
              color: statusColor,
              size: 24.sp,
            ),
          ],
        ),
      ),
    )
      .animate()
      .fadeIn(duration: 400.ms, delay: (index * 50).ms)
      .slideX(begin: 0.1, end: 0);
  }
}

