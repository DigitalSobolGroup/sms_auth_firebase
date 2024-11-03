import '../models/userSMS_model.dart';

abstract class UserDataSource {
  Future<UserSMS?> getUserData();
  Future<void> saveOrUpdateUser(UserSMS user);
  Future<void> deleteUser(String userId);
}