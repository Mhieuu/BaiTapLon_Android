import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Trợ giúp',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpSection(
              context,
              icon: Icons.medication_liquid_rounded,
              title: 'Cách uống thuốc',
              content: [
                '1. Khi đến giờ uống thuốc, màn hình sẽ hiển thị thông báo',
                '2. Bấm vào nút "Thuốc" màu xanh để xác nhận đã uống',
                '3. App sẽ tự động ghi nhận thời gian bạn uống thuốc',
              ],
              color: Theme.of(context).colorScheme.primary,
            ),
            Gap(16.h),
            _buildHelpSection(
              context,
              icon: Icons.emergency_rounded,
              title: 'Nút SOS Khẩn cấp',
              content: [
                '1. Bấm nút "SOS" màu đỏ khi gặp tình huống khẩn cấp',
                '2. App sẽ tự động gọi điện cho con của bạn',
                '3. Con sẽ nhận được thông báo khẩn cấp ngay lập tức',
              ],
              color: Colors.red,
            ),
            Gap(16.h),
            _buildHelpSection(
              context,
              icon: Icons.phone_rounded,
              title: 'Gọi con',
              content: [
                '1. Bấm nút "Gọi" để gọi điện cho con',
                '2. Đây là cuộc gọi thông thường, không khẩn cấp',
                '3. Con sẽ nhận cuộc gọi như bình thường',
              ],
              color: Colors.blue,
            ),
            Gap(16.h),
            _buildHelpSection(
              context,
              icon: Icons.history_rounded,
              title: 'Xem lịch sử',
              content: [
                '1. Vào tab "Lịch sử" để xem các lần đã uống thuốc',
                '2. Xem thời gian và trạng thái (đúng giờ/trễ)',
                '3. Lịch sử được sắp xếp theo ngày',
              ],
              color: Colors.green,
            ),
            Gap(16.h),
            _buildHelpSection(
              context,
              icon: Icons.settings_rounded,
              title: 'Cài đặt',
              content: [
                '1. Vào tab "Cài đặt" để tùy chỉnh app',
                '2. Điều chỉnh thông báo, âm thanh, cỡ chữ',
                '3. Xem và xác nhận yêu cầu liên kết từ con',
              ],
              color: Colors.purple,
            ),
            Gap(24.h),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Lưu ý',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    Gap(12.h),
                    Text(
                      '• App sẽ tự động phát âm thanh nhắc nhở khi đến giờ uống thuốc\n'
                      '• Nếu bạn quên uống thuốc, con sẽ nhận được thông báo cảnh báo\n'
                      '• Luôn đảm bảo điện thoại có kết nối mạng để nhận thông báo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> content,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: color.withOpacity(0.2),
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
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24.sp,
                  ),
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
            Gap(16.h),
            ...content.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}


