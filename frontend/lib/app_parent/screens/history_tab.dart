import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/check_in.dart';
import '../../viewmodels/checkin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../repositories/checkin_repository.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final elderId = authViewModel.currentUser?.id;

    if (elderId == null) {
      return const Center(
        child: Text('Vui lòng đăng nhập'),
      );
    }

    return FutureBuilder<List<CheckIn>>(
      future: CheckInRepository().getCheckInsByElderId(elderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi: ${snapshot.error}'),
          );
        }

        final checkIns = snapshot.data ?? <CheckIn>[];

        if (checkIns.isEmpty) {
          return Center(
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
                  'Chưa có lịch sử',
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
          );
        }

        // Group by date
        final grouped = <String, List<CheckIn>>{};
        for (var checkIn in checkIns) {
          final date = DateFormat('yyyy-MM-dd').format(checkIn.checkInTime);
          if (!grouped.containsKey(date)) {
            grouped[date] = <CheckIn>[];
          }
          grouped[date]!.add(checkIn);
        }

        final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            size: 24.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Lịch sử Check-in',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    Gap(8.h),
                    Text(
                      'Tổng cộng: ${checkIns.length} lần',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final date = sortedDates[index];
                  final dayCheckIns = grouped[date]!;
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                          child: Text(
                            _formatDate(date),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        ...dayCheckIns.map((checkIn) => _buildCheckInCard(checkIn)),
                      ],
                    ),
                  )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                    .slideX(begin: 0.1, end: 0);
                },
                childCount: sortedDates.length,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckInCard(CheckIn checkIn) {
    final isOnTime = checkIn.isOnTime ?? false;
    final statusColor = isOnTime
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.h),
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
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.2),
                    statusColor.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isOnTime 
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
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
                    'Đã uống thuốc',
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
                        size: 14.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        DateFormat('HH:mm').format(checkIn.checkInTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isOnTime ? 'Đúng giờ' : 'Trễ',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == yesterday) {
      return 'Hôm qua';
    } else {
      return DateFormat('EEEE, dd/MM/yyyy', 'vi').format(date);
    }
  }
}

