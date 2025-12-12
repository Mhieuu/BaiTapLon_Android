import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/api_service.dart';

class PhotoSlideshow extends StatefulWidget {
  const PhotoSlideshow({super.key});

  @override
  State<PhotoSlideshow> createState() => _PhotoSlideshowState();
}

class _PhotoSlideshowState extends State<PhotoSlideshow> {
  final SwiperController _swiperController = SwiperController();
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _photos = []; // Store photo data with base64
  int _currentIndex = 0;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    // Auto refresh mỗi 30 giây để load ảnh mới
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadPhotos();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authViewModel = context.read<AuthViewModel>();
      final elder = authViewModel.currentUser;
      
      if (elder == null) {
        setState(() {
          _photos = [];
          _isLoading = false;
        });
        return;
      }

      // Load photos shared by carer for this elder
      final photos = await _apiService.getPhotosByElderId(elder.id);
      
      if (mounted) {
        setState(() {
          _photos = photos;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [PHOTO_SLIDESHOW] Lỗi load ảnh: $e');
      if (mounted) {
        setState(() {
          _photos = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return GlassmorphicContainer(
        width: double.infinity,
        height: 200.h,
        borderRadius: 24.r,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
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
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show placeholder if no photos - với Glassmorphism
    if (_photos.isEmpty) {
      return GlassmorphicContainer(
        width: double.infinity,
        height: 200.h,
        borderRadius: 24.r,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_rounded,
                size: 56.sp,
                color: CupertinoColors.systemBlue,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Ảnh gia đình sẽ hiển thị ở đây',
              style: TextStyle(
                fontSize: 16.sp,
                color: CupertinoColors.label,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Con của bạn có thể chia sẻ ảnh',
              style: TextStyle(
                fontSize: 13.sp,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            Swiper(
              controller: _swiperController,
              itemCount: _photos.length,
              autoplay: true,
              autoplayDelay: 5000,
              duration: 800,
              curve: Curves.easeInOutCubic,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final photo = _photos[index];
                final imageBase64 = photo['imageBase64'] as String?;
                
                if (imageBase64 == null || imageBase64.isEmpty) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 48),
                  );
                }

                try {
                  return Image.memory(
                    base64Decode(imageBase64),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 48),
                      );
                    },
                  );
                } catch (e) {
                  print('❌ [PHOTO_SLIDESHOW] Lỗi decode ảnh: $e');
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 48),
                  );
                }
              },
            ),
            // Smooth Page Indicator
            if (_photos.length > 1)
              Positioned(
                bottom: 16.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _photos.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentIndex == index ? 24.w : 8.w,
                          height: 8.h,
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

