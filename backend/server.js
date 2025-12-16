const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { MongoClient, ObjectId } = require('mongodb');
require('dotenv').config();

// Đặt múi giờ mặc định về Việt Nam để mọi timestamp trên server đồng nhất
process.env.TZ = process.env.TZ || 'Asia/Ho_Chi_Minh';

const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/antam';

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

let db;
let client;

// Kết nối MongoDB
async function connectDB() {
  try {
    client = new MongoClient(MONGODB_URI);
    await client.connect();
    db = client.db('antam');
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
}

// Routes

// Health check
app.get('/api/health', (req, res) => {
  console.log('🏥 [HEALTH] Health check request');
  res.json({ status: 'OK', message: 'An Tâm API is running' });
});

// ========== USER ROUTES ==========

// Đăng ký user
app.post('/api/users/register', async (req, res) => {
  try {
    const { name, phoneNumber, email, type } = req.body;
    
    console.log('📝 [REGISTER] Nhận request đăng ký:', { name, phoneNumber, email, type });
    
    // Kiểm tra user đã tồn tại chưa
    const existingUser = await db.collection('users').findOne({ phoneNumber });
    if (existingUser) {
      console.log('❌ [REGISTER] Số điện thoại đã tồn tại:', phoneNumber);
      return res.status(400).json({ error: 'Số điện thoại đã được sử dụng' });
    }

    const user = {
      name,
      phoneNumber,
      email,
      type, // 'carer' hoặc 'elder'
      parentId: null,
      carerId: null,
      createdAt: new Date(),
    };

    console.log('💾 [REGISTER] Đang lưu user vào database...');
    const result = await db.collection('users').insertOne(user);
    const userId = result.insertedId.toString();
    
    console.log('✅ [REGISTER] Đăng ký thành công!');
    console.log('   - User ID:', userId);
    console.log('   - Name:', name);
    console.log('   - Phone:', phoneNumber);
    console.log('   - Type:', type);
    console.log('   - Đã lưu vào database: users collection');
    
    // Verify đã lưu
    const savedUser = await db.collection('users').findOne({ _id: result.insertedId });
    if (savedUser) {
      console.log('✅ [REGISTER] Xác nhận: User đã được lưu vào database');
    } else {
      console.log('⚠️ [REGISTER] Cảnh báo: Không tìm thấy user sau khi insert');
    }
    
    res.status(201).json({ 
      success: true, 
      userId: userId,
      user: { 
        id: userId,
        name: user.name,
        phoneNumber: user.phoneNumber,
        email: user.email,
        type: user.type,
        parentId: user.parentId,
        carerId: user.carerId,
        createdAt: user.createdAt,
      }
    });
  } catch (error) {
    console.error('❌ [REGISTER] Lỗi đăng ký:', error);
    res.status(500).json({ error: 'Lỗi đăng ký: ' + error.message });
  }
});

// Đăng nhập user
app.post('/api/users/login', async (req, res) => {
  try {
    const { phoneNumber } = req.body;
    
    console.log('🔐 [LOGIN] Nhận request đăng nhập:', { phoneNumber });
    
    const user = await db.collection('users').findOne({ phoneNumber });
    
    if (!user) {
      console.log('❌ [LOGIN] Số điện thoại không tồn tại:', phoneNumber);
      return res.status(404).json({ error: 'Số điện thoại không tồn tại' });
    }

    console.log('✅ [LOGIN] Đăng nhập thành công!');
    console.log('   - User ID:', user._id.toString());
    console.log('   - Name:', user.name);
    console.log('   - Type:', user.type);

    res.json({ 
      success: true, 
      user: {
        id: user._id.toString(),
        name: user.name,
        phoneNumber: user.phoneNumber,
        email: user.email,
        type: user.type,
        parentId: user.parentId,
        carerId: user.carerId,
        createdAt: user.createdAt,
      }
    });
  } catch (error) {
    console.error('❌ [LOGIN] Lỗi đăng nhập:', error);
    res.status(500).json({ error: 'Lỗi đăng nhập: ' + error.message });
  }
});

// Lấy user theo ID
app.get('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log('👤 [GET_USER] Lấy thông tin user:', id);
    
    let user;
    // Thử với ObjectId trước, nếu không được thì dùng string
    try {
      user = await db.collection('users').findOne({ _id: new ObjectId(id) });
    } catch (e) {
      user = await db.collection('users').findOne({ _id: id });
    }
    
    if (!user) {
      console.log('❌ [GET_USER] Không tìm thấy user:', id);
      return res.status(404).json({ error: 'User not found' });
    }
    
    console.log('✅ [GET_USER] Tìm thấy user:', user.name);
    res.json({
      id: user._id.toString(),
      ...user,
      _id: user._id.toString(),
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Lỗi lấy thông tin user' });
  }
});

// Gửi request liên kết (carer gửi request cho elder)
app.post('/api/users/link-request', async (req, res) => {
  try {
    const { carerId, elderPhoneNumber } = req.body;
    
    console.log('🔗 [LINK_REQUEST] Nhận request liên kết:', { carerId, elderPhoneNumber });
    
    const carer = await db.collection('users').findOne({ 
      $or: [
        { _id: new ObjectId(carerId) },
        { _id: carerId }
      ]
    });
    
    if (!carer) {
      return res.status(404).json({ error: 'Carer not found' });
    }

    const elder = await db.collection('users').findOne({ phoneNumber: elderPhoneNumber });
    
    if (!elder) {
      return res.status(404).json({ error: 'Không tìm thấy tài khoản với số điện thoại này' });
    }

    if (elder.type !== 'elder') {
      return res.status(400).json({ error: 'Số điện thoại này không phải tài khoản Cha/Mẹ' });
    }

    // Kiểm tra xem đã có request chưa
    const existingRequest = await db.collection('link_requests').findOne({
      carerId: carerId,
      elderId: elder._id.toString(),
      status: 'pending'
    });

    if (existingRequest) {
      return res.status(400).json({ error: 'Đã gửi yêu cầu liên kết. Vui lòng chờ xác nhận' });
    }

    // Tạo request
    const request = {
      carerId: carerId,
      carerName: carer.name,
      carerPhone: carer.phoneNumber,
      elderId: elder._id.toString(),
      elderName: elder.name,
      elderPhone: elder.phoneNumber,
      status: 'pending', // pending, accepted, rejected
      createdAt: new Date(),
    };

    const result = await db.collection('link_requests').insertOne(request);
    
    console.log('✅ [LINK_REQUEST] Đã tạo request:', result.insertedId.toString());

    res.json({ 
      success: true, 
      requestId: result.insertedId.toString(),
      message: 'Đã gửi yêu cầu liên kết. Vui lòng chờ phụ huynh xác nhận' 
    });
  } catch (error) {
    console.error('❌ [LINK_REQUEST] Lỗi:', error);
    res.status(500).json({ error: 'Lỗi gửi yêu cầu liên kết: ' + error.message });
  }
});

// Xác nhận hoặc từ chối request liên kết (elder xác nhận)
app.post('/api/users/link-confirm', async (req, res) => {
  try {
    const { requestId, elderId, accept } = req.body;
    
    console.log('✅ [LINK_CONFIRM] Xác nhận request:', { requestId, elderId, accept });
    
    const request = await db.collection('link_requests').findOne({ 
      $or: [
        { _id: new ObjectId(requestId) },
        { _id: requestId }
      ]
    });
    
    if (!request) {
      return res.status(404).json({ error: 'Request not found' });
    }

    if (request.elderId !== elderId) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    if (request.status !== 'pending') {
      return res.status(400).json({ error: 'Request đã được xử lý' });
    }

    if (accept) {
      // Chấp nhận: Liên kết carer và elder
      const carerId = request.carerId;
      
      // Update carer
      try {
        await db.collection('users').updateOne(
          { _id: new ObjectId(carerId) },
          { $set: { parentId: elderId } }
        );
      } catch (e) {
        await db.collection('users').updateOne(
          { _id: carerId },
          { $set: { parentId: elderId } }
        );
      }

      // Update elder
      try {
        await db.collection('users').updateOne(
          { _id: new ObjectId(elderId) },
          { $set: { carerId: carerId } }
        );
      } catch (e) {
        await db.collection('users').updateOne(
          { _id: elderId },
          { $set: { carerId: carerId } }
        );
      }

      // Update request status
      await db.collection('link_requests').updateOne(
        { _id: request._id },
        { $set: { status: 'accepted', confirmedAt: new Date() } }
      );

      console.log('✅ [LINK_CONFIRM] Đã chấp nhận và liên kết thành công');
      res.json({ success: true, message: 'Đã liên kết thành công' });
    } else {
      // Từ chối
      await db.collection('link_requests').updateOne(
        { _id: request._id },
        { $set: { status: 'rejected', confirmedAt: new Date() } }
      );

      console.log('❌ [LINK_CONFIRM] Đã từ chối request');
      res.json({ success: true, message: 'Đã từ chối yêu cầu liên kết' });
    }
  } catch (error) {
    console.error('❌ [LINK_CONFIRM] Lỗi:', error);
    res.status(500).json({ error: 'Lỗi xác nhận: ' + error.message });
  }
});

// Lấy các request chờ xác nhận của elder
app.get('/api/users/link-requests/:elderId', async (req, res) => {
  try {
    const { elderId } = req.params;
    const requests = await db.collection('link_requests')
      .find({ 
        elderId: elderId,
        status: 'pending'
      })
      .sort({ createdAt: -1 })
      .toArray();
    
    res.json(requests.map(r => ({
      id: r._id.toString(),
      ...r,
      _id: r._id.toString(),
    })));
  } catch (error) {
    console.error('Get link requests error:', error);
    res.status(500).json({ error: 'Lỗi lấy yêu cầu liên kết' });
  }
});

// Kiểm tra trạng thái request của carer
app.get('/api/users/link-request-status/:carerId', async (req, res) => {
  try {
    const { carerId } = req.params;
    const request = await db.collection('link_requests')
      .findOne({ 
        carerId: carerId,
        status: { $in: ['pending', 'accepted', 'rejected'] }
      }, { sort: { createdAt: -1 } });
    
    if (!request) {
      return res.json(null);
    }

    res.json({
      id: request._id.toString(),
      ...request,
      _id: request._id.toString(),
    });
  } catch (error) {
    console.error('Get link request status error:', error);
    res.status(500).json({ error: 'Lỗi kiểm tra trạng thái' });
  }
});

// ========== CALL BACK REQUESTS ==========

// Cha/Mẹ gửi yêu cầu Con gọi lại khi rảnh
app.post('/api/call-requests', async (req, res) => {
  try {
    const { elderId, carerId } = req.body;

    if (!elderId || !carerId) {
      return res.status(400).json({ error: 'elderId và carerId là bắt buộc' });
    }

    // Lấy thông tin elder và carer để lưu kèm
    const elder = await db.collection('users').findOne({
      $or: [{ _id: new ObjectId(elderId) }, { _id: elderId }],
    });
    const carer = await db.collection('users').findOne({
      $or: [{ _id: new ObjectId(carerId) }, { _id: carerId }],
    });

    if (!elder || !carer) {
      return res.status(404).json({ error: 'Không tìm thấy tài khoản cha/mẹ hoặc con' });
    }

    const request = {
      elderId: elder._id.toString(),
      elderName: elder.name,
      elderPhone: elder.phoneNumber,
      carerId: carer._id.toString(),
      status: 'pending', // pending -> acknowledged
      createdAt: new Date(),
    };

    const result = await db.collection('call_requests').insertOne(request);

    res.json({
      success: true,
      requestId: result.insertedId.toString(),
      message: 'Đã gửi yêu cầu gọi lại',
    });
  } catch (error) {
    console.error('❌ [CALL_REQUEST] Lỗi gửi yêu cầu gọi lại:', error);
    res.status(500).json({ error: 'Lỗi gửi yêu cầu gọi lại: ' + error.message });
  }
});

// Con lấy các yêu cầu gọi lại đang chờ
app.get('/api/call-requests/carer/:carerId', async (req, res) => {
  try {
    const { carerId } = req.params;
    const includeAll = req.query.all === 'true';
    const statusFilter = includeAll ? { $in: ['pending', 'acknowledged'] } : 'pending';
    const requests = await db
      .collection('call_requests')
      .find({ carerId, status: statusFilter })
      .sort({ createdAt: -1 })
      .toArray();

    res.json(
      requests.map((r) => ({
        id: r._id.toString(),
        ...r,
        _id: r._id.toString(),
      }))
    );
  } catch (error) {
    console.error('❌ [CALL_REQUEST] Lỗi lấy yêu cầu gọi lại:', error);
    res.status(500).json({ error: 'Lỗi lấy yêu cầu gọi lại: ' + error.message });
  }
});

// Con đã thấy thông báo -> đánh dấu đã nhận
app.post('/api/call-requests/:id/ack', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.collection('call_requests').updateOne(
      {
        $or: [{ _id: new ObjectId(id) }, { _id: id }],
      },
      { $set: { status: 'acknowledged', acknowledgedAt: new Date() } }
    );

    if (result.modifiedCount === 0) {
      return res.status(404).json({ error: 'Không tìm thấy yêu cầu' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('❌ [CALL_REQUEST] Lỗi ack yêu cầu gọi lại:', error);
    res.status(500).json({ error: 'Lỗi xác nhận yêu cầu: ' + error.message });
  }
});

// Liên kết carer và elder (giữ lại cho backward compatibility)
app.post('/api/users/link', async (req, res) => {
  try {
    const { carerId, elderId } = req.body;
    
    const carer = await db.collection('users').findOne({ _id: carerId });
    const elder = await db.collection('users').findOne({ _id: elderId });
    
    if (!carer || !elder) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update carer
    try {
      await db.collection('users').updateOne(
        { _id: new ObjectId(carerId) },
        { $set: { parentId: elderId } }
      );
    } catch (e) {
      await db.collection('users').updateOne(
        { _id: carerId },
        { $set: { parentId: elderId } }
      );
    }

    // Update elder
    try {
      await db.collection('users').updateOne(
        { _id: new ObjectId(elderId) },
        { $set: { carerId: carerId } }
      );
    } catch (e) {
      await db.collection('users').updateOne(
        { _id: elderId },
        { $set: { carerId: carerId } }
      );
    }

    res.json({ success: true, message: 'Đã liên kết thành công' });
  } catch (error) {
    console.error('Link error:', error);
    res.status(500).json({ error: 'Lỗi liên kết' });
  }
});

// ========== MEDICATION SCHEDULE ROUTES ==========

// Tạo lịch uống thuốc
app.post('/api/medication-schedules', async (req, res) => {
  try {
    const schedule = {
      ...req.body,
      createdAt: new Date(),
    };
    const result = await db.collection('medication_schedules').insertOne(schedule);
    res.status(201).json({ 
      success: true, 
      scheduleId: result.insertedId.toString() 
    });
  } catch (error) {
    console.error('Create schedule error:', error);
    res.status(500).json({ error: 'Lỗi tạo lịch uống thuốc' });
  }
});

// Lấy lịch uống thuốc theo carerId
app.get('/api/medication-schedules/carer/:carerId', async (req, res) => {
  try {
    const schedules = await db.collection('medication_schedules')
      .find({ carerId: req.params.carerId })
      .toArray();
    
    res.json(schedules.map(s => ({
      id: s._id.toString(),
      ...s,
      _id: s._id.toString(),
    })));
  } catch (error) {
    console.error('Get schedules error:', error);
    res.status(500).json({ error: 'Lỗi lấy lịch uống thuốc' });
  }
});

// Lấy lịch uống thuốc theo elderId
app.get('/api/medication-schedules/elder/:elderId', async (req, res) => {
  try {
    const elderId = req.params.elderId;
    console.log('📅 [GET_SCHEDULES_ELDER] Lấy lịch cho elder:', elderId);
    
    // Lấy tất cả lịch active của elder (không filter theo ngày để frontend tự filter)
    const allSchedules = await db.collection('medication_schedules')
      .find({ 
        elderId: elderId, 
        isActive: true
      })
      .toArray();
    
    console.log(`📅 [GET_SCHEDULES_ELDER] Tìm thấy ${allSchedules.length} lịch active`);
    
    // Log để debug
    const today = new Date();
    const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;
    const todayWeekday = today.getDay();
    console.log(`📅 [GET_SCHEDULES_ELDER] Hôm nay: ${todayStr}, weekday: ${todayWeekday} (0=CN, 1=T2, ..., 6=T7)`);
    
    allSchedules.forEach(s => {
      console.log(`  - Lịch: ${s.medicationName}, daysOfWeek: [${s.daysOfWeek?.join(',')}], specificDates: [${s.specificDates?.join(',')}]`);
    });
    
    res.json(allSchedules.map(s => ({
      id: s._id.toString(),
      ...s,
      _id: s._id.toString(),
    })));
  } catch (error) {
    console.error('❌ [GET_SCHEDULES_ELDER] Lỗi:', error);
    res.status(500).json({ error: 'Lỗi lấy lịch uống thuốc' });
  }
});

// Xóa lịch uống thuốc
app.delete('/api/medication-schedules/:id', async (req, res) => {
  try {
    try {
      await db.collection('medication_schedules').deleteOne({ _id: new ObjectId(req.params.id) });
    } catch (e) {
      await db.collection('medication_schedules').deleteOne({ _id: req.params.id });
    }
    res.json({ success: true });
  } catch (error) {
    console.error('Delete schedule error:', error);
    res.status(500).json({ error: 'Lỗi xóa lịch' });
  }
});

// Cập nhật lịch uống thuốc
app.put('/api/medication-schedules/:id', async (req, res) => {
  try {
    const updates = { ...req.body };
    // Không cho sửa _id
    delete updates._id;

    let result;
    try {
      result = await db.collection('medication_schedules').updateOne(
        { _id: new ObjectId(req.params.id) },
        { $set: updates }
      );
    } catch (e) {
      result = await db.collection('medication_schedules').updateOne(
        { _id: req.params.id },
        { $set: updates }
      );
    }

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'Không tìm thấy lịch' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Update schedule error:', error);
    res.status(500).json({ error: 'Lỗi cập nhật lịch' });
  }
});

// ========== CHECK-IN ROUTES ==========

// Tạo check-in
app.post('/api/check-ins', async (req, res) => {
  try {
    const checkIn = {
      ...req.body,
      checkInTime: new Date(req.body.checkInTime),
    };
    const result = await db.collection('check_ins').insertOne(checkIn);
    res.status(201).json({ 
      success: true, 
      checkInId: result.insertedId.toString() 
    });
  } catch (error) {
    console.error('Create check-in error:', error);
    res.status(500).json({ error: 'Lỗi tạo check-in' });
  }
});

// Lấy check-in hôm nay
app.get('/api/check-ins/today/:scheduleId', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const checkIn = await db.collection('check_ins').findOne({
      medicationScheduleId: req.params.scheduleId,
      checkInTime: {
        $gte: today,
        $lt: tomorrow,
      },
    });

    if (checkIn) {
      res.json({
        id: checkIn._id.toString(),
        ...checkIn,
        _id: checkIn._id.toString(),
      });
    } else {
      res.json(null);
    }
  } catch (error) {
    console.error('Get today check-in error:', error);
    res.status(500).json({ error: 'Lỗi lấy check-in' });
  }
});

// Lấy lịch sử check-in
app.get('/api/check-ins/elder/:elderId', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    let query = { elderId: req.params.elderId };
    
    if (startDate) {
      query.checkInTime = { ...query.checkInTime, $gte: new Date(startDate) };
    }
    if (endDate) {
      query.checkInTime = { ...query.checkInTime, $lte: new Date(endDate) };
    }

    const checkIns = await db.collection('check_ins')
      .find(query)
      .sort({ checkInTime: -1 })
      .toArray();

    res.json(checkIns.map(c => ({
      id: c._id.toString(),
      ...c,
      _id: c._id.toString(),
    })));
  } catch (error) {
    console.error('Get check-ins error:', error);
    res.status(500).json({ error: 'Lỗi lấy lịch sử' });
  }
});

// ========== APPOINTMENT ROUTES ==========

// Tạo lịch hẹn
app.post('/api/appointments', async (req, res) => {
  try {
    const appointment = {
      ...req.body,
      dateTime: new Date(req.body.dateTime),
      createdAt: new Date(),
    };
    const result = await db.collection('appointments').insertOne(appointment);
    res.status(201).json({ 
      success: true, 
      appointmentId: result.insertedId.toString() 
    });
  } catch (error) {
    console.error('Create appointment error:', error);
    res.status(500).json({ error: 'Lỗi tạo lịch hẹn' });
  }
});

// Lấy lịch hẹn theo carerId
app.get('/api/appointments/carer/:carerId', async (req, res) => {
  try {
    const appointments = await db.collection('appointments')
      .find({ carerId: req.params.carerId })
      .sort({ dateTime: 1 })
      .toArray();
    
    res.json(appointments.map(a => ({
      id: a._id.toString(),
      ...a,
      _id: a._id.toString(),
    })));
  } catch (error) {
    console.error('Get appointments error:', error);
    res.status(500).json({ error: 'Lỗi lấy lịch hẹn' });
  }
});

// Cập nhật lịch hẹn
app.put('/api/appointments/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const update = { ...req.body };
    if (update.dateTime) {
      update.dateTime = new Date(update.dateTime);
    }
    
    try {
      await db.collection('appointments').updateOne(
        { _id: new ObjectId(id) },
        { $set: update }
      );
    } catch (e) {
      await db.collection('appointments').updateOne(
        { _id: id },
        { $set: update }
      );
    }
    res.json({ success: true });
  } catch (error) {
    console.error('Update appointment error:', error);
    res.status(500).json({ error: 'Lỗi cập nhật lịch hẹn' });
  }
});

// Xóa lịch hẹn
app.delete('/api/appointments/:id', async (req, res) => {
  try {
    try {
      await db.collection('appointments').deleteOne({ _id: new ObjectId(req.params.id) });
    } catch (e) {
      await db.collection('appointments').deleteOne({ _id: req.params.id });
    }
    res.json({ success: true });
  } catch (error) {
    console.error('Delete appointment error:', error);
    res.status(500).json({ error: 'Lỗi xóa lịch hẹn' });
  }
});

// ========== PHOTO SHARING ROUTES ==========

// Upload photo (carer uploads photo to share with elder)
app.post('/api/photos', async (req, res) => {
  try {
    const { carerId, elderId, imageBase64, description } = req.body;

    if (!carerId || !elderId || !imageBase64) {
      return res.status(400).json({ error: 'carerId, elderId và imageBase64 là bắt buộc' });
    }

    // Verify carer and elder exist
    const carer = await db.collection('users').findOne({
      $or: [{ _id: new ObjectId(carerId) }, { _id: carerId }],
    });
    const elder = await db.collection('users').findOne({
      $or: [{ _id: new ObjectId(elderId) }, { _id: elderId }],
    });

    if (!carer || !elder) {
      return res.status(404).json({ error: 'Không tìm thấy tài khoản' });
    }

    const photo = {
      carerId: carer._id.toString(),
      carerName: carer.name,
      elderId: elder._id.toString(),
      elderName: elder.name,
      imageBase64: imageBase64, // Store base64 encoded image
      description: description || '',
      createdAt: new Date(),
    };

    const result = await db.collection('photos').insertOne(photo);

    console.log(`✅ [PHOTO_UPLOAD] Đã upload ảnh ID: ${result.insertedId.toString()}`);

    res.status(201).json({
      success: true,
      photoId: result.insertedId.toString(),
      message: 'Đã tải ảnh lên thành công',
    });
  } catch (error) {
    console.error('❌ [PHOTO_UPLOAD] Lỗi upload ảnh:', error);
    res.status(500).json({ error: 'Lỗi upload ảnh: ' + error.message });
  }
});

// Get photos for elder (elder views photos shared by carer)
app.get('/api/photos/elder/:elderId', async (req, res) => {
  try {
    const { elderId } = req.params;
    const photos = await db
      .collection('photos')
      .find({ elderId: elderId })
      .sort({ createdAt: -1 })
      .toArray();

    res.json(
      photos.map((p) => ({
        id: p._id.toString(),
        carerId: p.carerId,
        carerName: p.carerName,
        elderId: p.elderId,
        elderName: p.elderName,
        imageBase64: p.imageBase64,
        description: p.description || '',
        createdAt: p.createdAt,
      }))
    );
  } catch (error) {
    console.error('❌ [PHOTO_GET] Lỗi lấy ảnh:', error);
    res.status(500).json({ error: 'Lỗi lấy ảnh: ' + error.message });
  }
});

// Get photos uploaded by carer
app.get('/api/photos/carer/:carerId', async (req, res) => {
  try {
    const { carerId } = req.params;
    const photos = await db
      .collection('photos')
      .find({ carerId: carerId })
      .sort({ createdAt: -1 })
      .toArray();

    res.json(
      photos.map((p) => ({
        id: p._id.toString(),
        carerId: p.carerId,
        carerName: p.carerName,
        elderId: p.elderId,
        elderName: p.elderName,
        imageBase64: p.imageBase64,
        description: p.description || '',
        createdAt: p.createdAt,
      }))
    );
  } catch (error) {
    console.error('❌ [PHOTO_GET] Lỗi lấy ảnh:', error);
    res.status(500).json({ error: 'Lỗi lấy ảnh: ' + error.message });
  }
});

// Delete photo
app.delete('/api/photos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    try {
      await db.collection('photos').deleteOne({ _id: new ObjectId(id) });
    } catch (e) {
      await db.collection('photos').deleteOne({ _id: id });
    }
    console.log(`✅ [PHOTO_DELETE] Đã xóa ảnh ID: ${id}`);
    res.json({ success: true });
  } catch (error) {
    console.error('❌ [PHOTO_DELETE] Lỗi xóa ảnh:', error);
    res.status(500).json({ error: 'Lỗi xóa ảnh: ' + error.message });
  }
});

// Start server
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log('='.repeat(50));
    console.log(`🚀 Server is running on http://localhost:${PORT}`);
    console.log(`📡 API Base URL: http://localhost:${PORT}/api`);
    console.log(`🏥 Health Check: http://localhost:${PORT}/api/health`);
    console.log('='.repeat(50));
    console.log('📝 Logging enabled - Tất cả requests sẽ được log');
    console.log('');
  });
});

module.exports = app;

