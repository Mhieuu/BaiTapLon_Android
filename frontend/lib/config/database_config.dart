class DatabaseConfig {
  // Thay đổi connection string này với MongoDB của bạn
  static const String connectionString = 
      'mongodb://localhost:27017/antam';
  
  // Hoặc sử dụng MongoDB Atlas
  // static const String connectionString = 
  //     'mongodb+srv://username:password@cluster.mongodb.net/antam?retryWrites=true&w=majority';
  
  static const String databaseName = 'antam';
  
  // Collection names
  static const String usersCollection = 'users';
  static const String medicationSchedulesCollection = 'medication_schedules';
  static const String appointmentsCollection = 'appointments';
  static const String checkInsCollection = 'check_ins';
  static const String familyConnectionsCollection = 'family_connections';
  static const String photosCollection = 'photos';
}

