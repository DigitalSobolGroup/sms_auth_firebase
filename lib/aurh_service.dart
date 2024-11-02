import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(String phoneNumber, String name, String email) async {
    final response = await http.post(
      Uri.parse('https://your-api-endpoint.com/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phonenumber': phoneNumber,
        'name': name,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      await _saveUserToFirestore(userData);
      await _saveUserToSharedPreferences(userData);
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<void> _saveUserToFirestore(Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userData['id']).set(userData);
  }

  Future<void> _saveUserToSharedPreferences(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userData['id']);
    await prefs.setString('user_phonenumber', userData['phonenumber']);
    await prefs.setString('user_otp', userData['otp']);
    await prefs.setString('user_name', userData['name']);
    await prefs.setString('user_email', userData['email']);
  }

  Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final phoneNumber = prefs.getString('user_phonenumber');
    final otp = prefs.getString('user_otp');

    if (userId == null || phoneNumber == null || otp == null) {
      return false;
    }

    final querySnapshot = await _firestore
        .collection('users')
        .where('id', isEqualTo: userId)
        .where('phonenumber', isEqualTo: phoneNumber)
        .where('otp', isEqualTo: otp)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      return null;
    }

    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    return docSnapshot.data();
  }

  Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('users').doc(userId).update(updatedData);
    await _saveUserToSharedPreferences(updatedData);
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('users').doc(userId).delete();
    await prefs.clear();
  }
}