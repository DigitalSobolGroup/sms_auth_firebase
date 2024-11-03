import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_auth_firebase/src/data/models/userSMS_model.dart';
import 'package:sms_auth_firebase/src/data/datasources/user_data_source.dart';

class UserDataSourceImpl implements UserDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserSMS?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      return null;
    }

    final docSnapshot = await _firestore.collection('usersSMS').doc(userId).get();
    if (docSnapshot.exists) {
      return UserSMS.fromJson(docSnapshot.data()!);
    }
    return null;
  }

  @override
  Future<void> saveOrUpdateUser(UserSMS user) async {
    final prefs = await SharedPreferences.getInstance();
    final existingPhoneNumber = prefs.getString('user_phonenumber');

    if (existingPhoneNumber == user.phoneNumber) {
      await _firestore.collection('usersSMS').doc(user.id).update(user.toJson());
    } else {
      await _firestore.collection('usersSMS').doc(user.id).set(user.toJson());
    }

    await _saveUserToSharedPreferences(user);
  }

  Future<void> _saveUserToSharedPreferences(UserSMS user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_phonenumber', user.phoneNumber);
    await prefs.setString('user_otp', user.otp);
    await prefs.setString('user_name', user.name);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('usersSMS').doc(userId).delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}