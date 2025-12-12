import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'dart:async';

class LinkParentScreen extends StatefulWidget {
  const LinkParentScreen({super.key});

  @override
  State<LinkParentScreen> createState() => _LinkParentScreenState();
}

class _LinkParentScreenState extends State<LinkParentScreen> {
  final _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isCheckingStatus = false;
  User? _linkedParent;
  Map<String, dynamic>? _pendingRequest;
  Timer? _statusCheckTimer;
  bool _isShowingDialog = false; // Flag để tránh hiển thị dialog nhiều lần

  @override
  void initState() {
    super.initState();
    _loadLinkedParent();
    _checkPendingRequest();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLinkedParent() async {
    final authViewModel = context.read<AuthViewModel>();
    final carer = authViewModel.currentUser;
    if (carer != null && carer.parentId != null) {
      try {
        final parent = await _apiService.getUserById(carer.parentId!);
        if (mounted) {
          setState(() {
            _linkedParent = parent;
          });
        }
      } catch (e) {
        print('Error loading parent: $e');
      }
    }
  }

  Future<void> _checkPendingRequest() async {
    final authViewModel = context.read<AuthViewModel>();
    final carer = authViewModel.currentUser;
    if (carer == null) return;

    setState(() => _isCheckingStatus = true);
    try {
      final request = await _apiService.getLinkRequestStatus(carer.id);
      if (mounted) {
        setState(() {
          _pendingRequest = request;
          _isCheckingStatus = false;
        });

        if (request != null && request['status'] == 'pending') {
          // Bắt đầu polling để kiểm tra trạng thái
          _startStatusPolling();
        } else if (request != null && request['status'] == 'accepted') {
          // Request đã được chấp nhận, reload parent
          final authViewModel = context.read<AuthViewModel>();
          await authViewModel.loadSavedUser();
          await _loadLinkedParent();
          // Chỉ hiển thị dialog nếu chưa có parent được load
          if (mounted && _linkedParent == null) {
            _showSuccessDialog('Liên kết thành công!', 'Phụ huynh đã chấp nhận yêu cầu liên kết của bạn.');
          } else if (mounted) {
            // Nếu đã có parent, chỉ cập nhật UI mà không hiển thị dialog
            setState(() {
              _pendingRequest = null;
            });
          }
        } else if (request != null && request['status'] == 'rejected') {
          _showErrorDialog('Yêu cầu bị từ chối', 'Phụ huynh đã từ chối yêu cầu liên kết của bạn.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  void _startStatusPolling() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authViewModel = context.read<AuthViewModel>();
      final carer = authViewModel.currentUser;
      if (carer == null) {
        timer.cancel();
        return;
      }

      try {
        final request = await _apiService.getLinkRequestStatus(carer.id);
        if (request != null && request['status'] != 'pending') {
          timer.cancel();
          if (mounted) {
            setState(() {
              _pendingRequest = request;
            });

            if (request['status'] == 'accepted') {
              // Refresh user info trước
              final authViewModel = context.read<AuthViewModel>();
              await authViewModel.loadSavedUser();
              await _loadLinkedParent();
              // Chỉ hiển thị dialog nếu chưa có parent được load
              if (mounted && _linkedParent == null) {
                _showSuccessDialog('Liên kết thành công!', 'Phụ huynh đã chấp nhận yêu cầu liên kết của bạn.');
              } else if (mounted) {
                // Nếu đã có parent, chỉ cập nhật UI mà không hiển thị dialog
                setState(() {
                  _pendingRequest = null;
                });
              }
            } else if (request['status'] == 'rejected') {
              _showErrorDialog('Yêu cầu bị từ chối', 'Phụ huynh đã từ chối yêu cầu liên kết của bạn.');
            }
          }
        }
      } catch (e) {
        print('Error checking status: $e');
      }
    });
  }

  Future<void> _sendLinkRequest() async {
    if (_phoneController.text.isEmpty) {
      _showError('Vui lòng nhập số điện thoại');
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final carer = authViewModel.currentUser;
    if (carer == null) {
      _showError('Vui lòng đăng nhập lại');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.sendLinkRequest(
        carer.id,
        _phoneController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _pendingRequest = {
            'status': 'pending',
            'elderPhone': _phoneController.text.trim(),
          };
        });

        // Gửi thông báo cho phụ huynh (trong thực tế sẽ gửi qua push notification)
        await NotificationService().showAlertNotification(
          title: 'Yêu cầu liên kết',
          body: 'Bạn có yêu cầu liên kết từ ${carer.name}. Vui lòng mở app để xác nhận.',
        );

        _showInfoDialog(
          'Đã gửi yêu cầu',
          'Yêu cầu liên kết đã được gửi đến phụ huynh. Vui lòng chờ xác nhận.',
        );

        // Bắt đầu polling
        _startStatusPolling();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
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

  void _showSuccessDialog(String title, String message) {
    // Tránh hiển thị dialog nhiều lần
    if (_isShowingDialog || !mounted) return;
    
    // Dừng polling trước
    _statusCheckTimer?.cancel();
    
    setState(() {
      _isShowingDialog = true;
    });
    
    // Đóng dialog hiện tại nếu có
    Navigator.of(context).popUntil((route) => route.isFirst || !(route is DialogRoute));
    
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho đóng bằng cách tap bên ngoài
      builder: (dialogContext) => PopScope(
        canPop: false, // Không cho đóng bằng nút back
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
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
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog
                // Refresh user info và cập nhật UI
                if (mounted) {
                  setState(() {
                    _isShowingDialog = false;
                    _pendingRequest = null; // Xóa pending request
                  });
                  final authViewModel = context.read<AuthViewModel>();
                  authViewModel.loadSavedUser().then((_) {
                    if (mounted) {
                      _loadLinkedParent(); // Load lại parent info
                    }
                  });
                }
              },
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
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
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
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingRequest = null;
              });
            },
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
        title: Text(
          'Liên kết tài khoản Cha/Mẹ',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                elevation: 0,
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
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Hướng dẫn',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '1. Yêu cầu Cha/Mẹ đăng ký tài khoản trước\n'
                        '2. Nhập số điện thoại của Cha/Mẹ để gửi yêu cầu liên kết\n'
                        '3. Chờ phụ huynh xác nhận trong app\n'
                        '4. Sau khi liên kết, bạn có thể tạo lịch uống thuốc cho Cha/Mẹ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                .slideY(begin: -0.1, end: 0),

              SizedBox(height: 32.h),

              // Linked Parent Card
              if (_linkedParent != null)
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Đã liên kết',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Tên: ${_linkedParent!.name}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'SĐT: ${_linkedParent!.phoneNumber}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              // TODO: Implement unlink
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            child: Text(
                              'Hủy liên kết',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1))

              // Pending Request Card
              else if (_pendingRequest != null && _pendingRequest!['status'] == 'pending')
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Đang chờ xác nhận',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Yêu cầu liên kết đã được gửi đến số điện thoại:\n${_pendingRequest!['elderPhone'] ?? ''}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Vui lòng chờ phụ huynh xác nhận...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .shimmer(duration: 2000.ms, delay: 400.ms)

              // Link Form
              else ...[
                TextField(
                  controller: _phoneController,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: TextDecoration.none,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại Cha/Mẹ',
                    hintText: 'Nhập số điện thoại đã đăng ký',
                    prefixIcon: Container(
                      margin: EdgeInsets.all(8.w),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.phone_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.sp,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  keyboardType: TextInputType.phone,
                )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _sendLinkRequest,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isLoading
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
                                Icons.send_rounded,
                                size: 20.sp,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Gửi yêu cầu liên kết',
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
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
