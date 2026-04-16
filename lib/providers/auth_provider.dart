import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      ApiService.setToken(token);
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String phone, String otp) async {
    final data = await ApiService.post('auth.php', {
      'action': 'verify_otp',
      'phone': phone,
      'otp': otp,
    });
    
    if (data['success'] == true) {
      _isAuthenticated = true;
      _user = data['user'];
      ApiService.setToken(data['token']);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
      
      notifyListeners();
    }
    return data;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _user = null;
    ApiService.setToken('');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    
    notifyListeners();
  }
}

String jsonEncode(dynamic data) => data.toString();
