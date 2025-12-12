import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'dart:async';

class LinkRequestsScreen extends StatefulWidget {
  const LinkRequestsScreen({super.key});

  @override
  State<LinkRequestsScreen> createState() => _LinkRequestsScreenState();
}

class _LinkRequestsScreenState extends State<LinkRequestsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    // Auto refresh mỗi 3 giây
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadRequests();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    final authViewModel = context.read<AuthViewModel>();
    final elder = authViewModel.currentUser;
    if (elder == null) return;

    try {
      final requests = await _apiService.getLinkRequestsForElder(elder.id);
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRequest(String requestId, bool accept) async {
    final authViewModel = context.read<AuthViewModel>();
    final elder = authViewModel.currentUser;
    if (elder == null) return;

    try {
      await _apiService.confirmLinkRequest(
        requestId: requestId,
        elderId: elder.id,
        accept: accept,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept ? 'Đã chấp nhận yêu cầu liên kết' : 'Đã từ chối yêu cầu liên kết',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            backgroundColor: accept
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        );
        await _loadRequests();
        // Reload user để cập nhật carerId
        await authViewModel.loadSavedUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Yêu cầu liên kết',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link_off_rounded,
                        size: 80.sp,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Chưa có yêu cầu liên kết',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Các yêu cầu liên kết từ con sẽ hiển thị ở đây',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.only(bottom: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        color: Theme.of(context).colorScheme.surface,
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
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person_add_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          request['carerName'] ?? 'Người dùng',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'SĐT: ${request['carerPhone'] ?? ''}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                'muốn liên kết với tài khoản của bạn',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _handleRequest(request['id'], false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.error,
                                        padding: EdgeInsets.symmetric(vertical: 14.h),
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                      child: Text(
                                        'Từ chối',
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () => _handleRequest(request['id'], true),
                                      style: FilledButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 14.h),
                                      ),
                                      child: Text(
                                        'Chấp nhận',
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                        .slideY(begin: 0.1, end: 0);
                    },
                  ),
                ),
    );
  }
}



