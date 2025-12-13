import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class PhotoSharingScreen extends StatefulWidget {
  const PhotoSharingScreen({super.key});

  @override
  State<PhotoSharingScreen> createState() => _PhotoSharingScreenState();
}

class _PhotoSharingScreenState extends State<PhotoSharingScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _photos = []; // Store photo data with id and base64
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var carer = _authService.currentUser;
      
      // Nếu không có user, thử refresh từ saved user
      if (carer == null) {
        final loaded = await _authService.loadSavedUser();
        if (loaded) {
          carer = _authService.currentUser;
        }
      }
      
      // Nếu vẫn không có user, báo lỗi
      if (carer == null) {
        setState(() {
          _errorMessage = 'Vui lòng đăng nhập lại';
          _isLoading = false;
        });
        return;
      }

      // Load photos uploaded by this carer
      final photos = await _apiService.getPhotosByCarerId(carer.id);
      
      if (mounted) {
        setState(() {
          _photos = photos;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [PHOTO_SHARING] Lỗi load ảnh: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tải ảnh: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _imageToBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        var carer = _authService.currentUser;
        
        // Nếu không có user, thử refresh từ saved user
        if (carer == null) {
          final loaded = await _authService.loadSavedUser();
          if (loaded) {
            carer = _authService.currentUser;
          }
        }
        
        // Nếu vẫn không có user, báo lỗi
        if (carer == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Vui lòng đăng nhập lại';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng đăng nhập lại')),
            );
          }
          return;
        }

        // Nếu chưa có parentId, thử refresh user info từ API
        if (carer.parentId == null || carer.parentId!.isEmpty) {
          print('🔄 [PHOTO_SHARING] parentId null, đang refresh user info...');
          final refreshed = await _authService.refreshCurrentUser();
          if (refreshed) {
            carer = _authService.currentUser;
          }
        }

        // Kiểm tra lại sau khi refresh
        if (carer == null || carer.parentId == null || carer.parentId!.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Chưa liên kết với tài khoản cha/mẹ';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chưa liên kết với tài khoản cha/mẹ. Vui lòng liên kết trước khi chia sẻ ảnh.')),
            );
          }
          return;
        }

        // Convert image to base64
        final imageBase64 = await _imageToBase64(image.path);

        // Upload to API
        await _apiService.uploadPhoto(
          carerId: carer.id,
          elderId: carer.parentId!,
          imageBase64: imageBase64,
        );

        // Reload photos
        await _loadPhotos();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã tải ảnh lên thành công')),
          );
        }
      }
    } catch (e) {
      print('❌ [PHOTO_SHARING] Lỗi upload ảnh: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi upload ảnh: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deletePhoto(String photoId, int index) async {
    try {
      setState(() => _isLoading = true);
      await _apiService.deletePhoto(photoId);
      
      // Remove from local list
      setState(() {
        _photos.removeAt(index);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa ảnh')),
        );
      }
    } catch (e) {
      print('❌ [PHOTO_SHARING] Lỗi xóa ảnh: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa ảnh: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chia sẻ ảnh'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPhotos,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading && _photos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _photos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadPhotos,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : _photos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có ảnh nào',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nhấn nút "Thêm ảnh" để chia sẻ ảnh với cha/mẹ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPhotos,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          final imageBase64 = photo['imageBase64'] as String?;
                          
                          if (imageBase64 == null || imageBase64.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(imageBase64),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 48),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    final photoId = photo['id'] as String?;
                                    if (photoId != null) {
                                      _deletePhoto(photoId, index);
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _pickAndUploadImage,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add_photo_alternate),
        label: const Text('Thêm ảnh'),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}

