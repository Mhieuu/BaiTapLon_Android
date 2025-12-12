import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authViewModel = context.read<AuthViewModel>();
      final user = authViewModel.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Vui lòng đăng nhập lại';
        });
        return;
      }
      final data = await ApiService()
          .getCallRequestsForCarer(carerId: user.id, includeAcknowledged: true);
      setState(() {
        _requests = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildScrollableBody(),
      ),
    );
  }

  Widget _buildScrollableBody() {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        children: [
          Center(
            child: Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (_requests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
        children: [
          _buildEmpty(),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final r = _requests[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: const Icon(Icons.notifications_rounded),
            title: Text(r['elderName'] ?? 'Cha/Mẹ'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((r['elderPhone'] ?? '').toString().isNotEmpty)
                  Text('SĐT: ${r['elderPhone']}'),
                Text('Trạng thái: ${r['status'] ?? 'pending'}'),
                if (r['createdAt'] != null)
                  Text('Gửi lúc: ${_formatTime(r['createdAt'])}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64.sp,
            color: Theme.of(context).colorScheme.outline,
          ),
          Gap(12.h),
          Text(
            'Chưa có thông báo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Gap(4.h),
          Text(
            'Khi cha/mẹ yêu cầu gọi lại, thông báo sẽ xuất hiện tại đây.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic value) {
    try {
      final dt = DateTime.parse(value.toString()).toLocal();
      return DateFormat('HH:mm dd/MM/yyyy').format(dt);
    } catch (_) {
      return value.toString();
    }
  }
}

