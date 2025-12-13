# Hướng dẫn Chạy Backend

## Vấn đề: Đăng nhập không được

Có thể do backend chưa chạy hoặc URL API không đúng.

## Giải pháp

### Bước 1: Chạy Backend Server

Mở terminal mới và chạy:

```bash
cd D:\Antam\backend
npm install
npm run dev
```

Backend sẽ chạy tại: `http://localhost:3000`

### Bước 2: Kiểm tra Backend đang chạy

Mở browser và truy cập:
- `http://localhost:3000/api/health` - Health check

Nếu thấy response, backend đã chạy.

### Bước 3: Cấu hình API URL

File `frontend/lib/config/api_config.dart` đã được cấu hình:
- **Android Emulator**: `http://10.0.2.2:3000/api` (đã set)
- **iOS Simulator/Web**: `http://localhost:3000/api`

### Bước 4: Test lại đăng nhập

1. Đảm bảo backend đang chạy
2. Hot Restart app (nhấn `R` trong terminal)
3. Thử đăng nhập lại

## Lưu ý

- Android emulator không thể dùng `localhost`, phải dùng `10.0.2.2`
- Backend phải chạy trước khi test đăng nhập
- Kiểm tra console backend để xem có request đến không

## Debug

Nếu vẫn lỗi, kiểm tra:
1. Backend có đang chạy không?
2. Port 3000 có bị block không?
3. Xem error message trong app để biết chi tiết





