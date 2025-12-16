# An Tâm Backend API

REST API backend cho hệ thống An Tâm sử dụng Node.js, Express và MongoDB.

## Cài đặt

1. Cài đặt dependencies:
```bash
npm install
```

2. Tạo file `.env` từ `.env.example`:
```bash
cp .env.example .env
```

3. Cấu hình MongoDB connection string trong `.env`:
```
MONGODB_URI=mongodb://localhost:27017/antam
PORT=3000
```

4. Chạy server:
```bash
# Development mode (với nodemon)
npm run dev

# Production mode
npm start
```

## API Endpoints

### Health Check
- `GET /api/health` - Kiểm tra server

### Users
- `POST /api/users/register` - Đăng ký user
- `POST /api/users/login` - Đăng nhập
- `GET /api/users/:id` - Lấy thông tin user
- `POST /api/users/link` - Liên kết carer và elder

### Medication Schedules
- `POST /api/medication-schedules` - Tạo lịch uống thuốc
- `GET /api/medication-schedules/carer/:carerId` - Lấy lịch theo carer
- `GET /api/medication-schedules/elder/:elderId` - Lấy lịch theo elder
- `DELETE /api/medication-schedules/:id` - Xóa lịch

### Check-ins
- `POST /api/check-ins` - Tạo check-in
- `GET /api/check-ins/today/:scheduleId` - Lấy check-in hôm nay
- `GET /api/check-ins/elder/:elderId` - Lấy lịch sử check-in

### Appointments
- `POST /api/appointments` - Tạo lịch hẹn
- `GET /api/appointments/carer/:carerId` - Lấy lịch hẹn
- `PUT /api/appointments/:id` - Cập nhật lịch hẹn
- `DELETE /api/appointments/:id` - Xóa lịch hẹn

## Request/Response Examples

### Đăng ký User
```json
POST /api/users/register
{
  "name": "Nguyễn Văn A",
  "phoneNumber": "0123456789",
  "email": "nguyenvana@example.com",
  "type": "carer"
}
```

### Tạo Medication Schedule
```json
POST /api/medication-schedules
{
  "carerId": "123",
  "elderId": "456",
  "medicationName": "Thuốc Huyết áp",
  "dosage": "1 viên",
  "time": {
    "hour": 8,
    "minute": 0
  },
  "daysOfWeek": [1, 2, 3, 4, 5, 6, 7],
  "isActive": true
}
```





