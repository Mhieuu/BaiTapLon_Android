import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../models/user.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../app_con/screens/dashboard_screen.dart';
import '../app_parent/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isLogin = true;
  UserType _selectedType = UserType.carer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _switchMode(bool isLogin) {
    if (_isLogin != isLogin) {
      setState(() {
        _isLogin = isLogin;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _handleSubmit() async {
    // Validate
    if (!_isLogin) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Vui lòng nhập họ tên');
        return;
      }
      if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
        _showError('Vui lòng nhập email hợp lệ');
        return;
      }
    }
    if (_phoneController.text.trim().isEmpty || _phoneController.text.length < 10) {
      _showError('Vui lòng nhập số điện thoại hợp lệ (ít nhất 10 số)');
      return;
    }

    final authViewModel = context.read<AuthViewModel>();

    if (_isLogin) {
      final success = await authViewModel.login(_phoneController.text.trim());
      if (!mounted) return;
      
      if (success) {
        final user = authViewModel.currentUser;
        if (user != null) {
          // Hiển thị thông báo thành công
          _showSuccess('Đăng nhập thành công!');
          // Đợi 1.5 giây để user đọc thông báo
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            _navigateToHome(user.type);
          }
        } else {
          _showError('Đăng nhập thành công nhưng không lấy được thông tin user');
        }
      } else {
        // Hiển thị lỗi nếu có
        final errorMsg = authViewModel.errorMessage ?? 'Đăng nhập thất bại';
        _showError(errorMsg);
      }
    } else {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        type: _selectedType,
        createdAt: DateTime.now(),
      );

      final success = await authViewModel.register(user);
      if (!mounted) return;
      
      if (success) {
        final registeredUser = authViewModel.currentUser;
        if (registeredUser != null) {
          // Hiển thị thông báo thành công
          _showSuccess('Đăng ký thành công!\nĐã lưu vào database.');
          // Đợi 2 giây để user đọc thông báo, sau đó mới navigate
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            _navigateToHome(registeredUser.type);
          }
        } else {
          _showError('Đăng ký thành công nhưng không lấy được thông tin user');
        }
      } else {
        // Hiển thị lỗi nếu có
        final errorMsg = authViewModel.errorMessage ?? 'Đăng ký thất bại';
        _showError(errorMsg);
      }
    }
  }

  void _navigateToHome(UserType userType) {
    if (userType == UserType.elder) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ParentMainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24.sp),
            Gap(12.w),
            Text(
              'Lỗi',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green[700], size: 28.sp),
              ),
              Gap(12.w),
              Expanded(
                child: Text(
                  'Thành công',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          content: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              message,
              style: TextStyle(fontSize: 16.sp, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Gap(40.h),
                    
                    // Logo Section
                    _buildLogoSection(),
                    
                    Gap(50.h),
                    
                    // Tab Selector
                    _buildTabSelector(),
                    
                    Gap(40.h),
                    
                    // Form Section
                    _buildFormSection(),
                    
                    Gap(40.h),
                    
                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo Circle
        Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue[700]!,
                Colors.blue[500]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withAlpha(102),
                blurRadius: 40,
                spreadRadius: 8,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.favorite,
            size: 80.sp,
            color: Colors.white,
          ),
        ),
        
        Gap(30.h),
        
        // App Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.home,
                size: 28.sp,
                color: Colors.blue[700],
              ),
            ),
            Gap(16.w),
            Text(
              'An Tâm',
              style: TextStyle(
                fontSize: 44.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
                letterSpacing: 1.2,
                height: 1.2,
              ),
            ),
          ],
        ),
        
        Gap(12.h),
        
        // Subtitle
        Text(
          'Hệ thống Chăm sóc Người cao tuổi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              icon: Icons.person,
              label: 'Đăng nhập',
              isSelected: _isLogin,
              onTap: () => _switchMode(true),
            ),
          ),
          Gap(8.w),
          Expanded(
            child: _buildTab(
              icon: Icons.person_add,
              label: 'Đăng ký',
              isSelected: !_isLogin,
              onTap: () => _switchMode(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
            ),
            Gap(8.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue[700] : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Header
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLogin ? Icons.account_circle : Icons.person_add_alt_1,
                    size: 24.sp,
                    color: Colors.blue[700],
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Text(
                      _isLogin ? 'Đăng nhập tài khoản' : 'Tạo tài khoản mới',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Gap(28.h),
            
            // Form Fields
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              child: _isLogin
                  ? _buildLoginFields()
                  : _buildRegisterFields(),
            ),
            
            Gap(32.h),
            
            // Submit Button
            Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: authViewModel.isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.blue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: authViewModel.isLoading
                        ? SizedBox(
                            height: 24.h,
                            width: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isLogin ? Icons.arrow_forward : Icons.check_circle,
                                size: 22.sp,
                              ),
                              Gap(10.w),
                              Text(
                                _isLogin ? 'Đăng nhập' : 'Đăng ký',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFields() {
    return Column(
      key: const ValueKey('login'),
      children: [
        _buildInputField(
          controller: _phoneController,
          label: 'Số điện thoại',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildRegisterFields() {
    return Column(
      key: const ValueKey('register'),
      children: [
        _buildInputField(
          controller: _nameController,
          label: 'Họ và tên',
          icon: Icons.person,
        ),
        Gap(20.h),
        _buildInputField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        Gap(20.h),
        _buildUserTypeSelector(),
        Gap(20.h),
        _buildInputField(
          controller: _phoneController,
          label: 'Số điện thoại',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 16.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22.sp),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<UserType>(
        value: _selectedType,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.people, size: 22.sp),
          labelText: 'Loại tài khoản',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        ),
        items: [
          DropdownMenuItem(
            value: UserType.carer,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 18.sp, color: Colors.grey[700]),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'Người Con (Chăm sóc)',
                    style: TextStyle(fontSize: 15.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: UserType.elder,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: 18.sp, color: Colors.grey[700]),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'Người Cha/Mẹ',
                    style: TextStyle(fontSize: 15.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedType = value;
            });
          }
        },
        dropdownColor: Colors.white,
        style: TextStyle(fontSize: 15.sp, color: Colors.grey[900]),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            size: 16.sp,
            color: Colors.grey[600],
          ),
          Gap(8.w),
          Text(
            'An toàn và bảo mật',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
