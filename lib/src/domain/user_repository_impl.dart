import 'package:sms_auth_firebase/src/domain/repositories/user_repository.dart';
import 'package:sms_auth_firebase/src/data/datasources/user_data_source.dart';

import '../data/models/userSMS_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  Future<UserSMS?> getUserData() async {
    return await dataSource.getUserData();
  }

  @override
  Future<void> saveOrUpdateUser(UserSMS user) async {
    await dataSource.saveOrUpdateUser(user);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await dataSource.deleteUser(userId);
  }
}