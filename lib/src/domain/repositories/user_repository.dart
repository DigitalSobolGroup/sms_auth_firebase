import '../../data/models/userSMS_model.dart';

abstract class UserRepository {
  Future<UserSMS?> getUserData();
  Future<void> saveOrUpdateUser(UserSMS user);
  Future<void> deleteUser(String userId);
}