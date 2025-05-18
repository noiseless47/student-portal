import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  String _name = '';
  String _nickname = '';
  bool _isLoading = false;
  
  String get name => _name;
  String get nickname => _nickname;
  bool get isLoading => _isLoading;
  
  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString('user_name') ?? '';
      _nickname = prefs.getString('user_nickname') ?? '';
    } catch (error) {
      debugPrint('Error loading user profile: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> saveUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _name);
      await prefs.setString('user_nickname', _nickname);
    } catch (error) {
      debugPrint('Error saving user profile: $error');
    }
  }
  
  Future<void> updateProfile({String? name, String? nickname}) async {
    if (name != null) _name = name;
    if (nickname != null) _nickname = nickname;
    notifyListeners();
    await saveUserProfile();
  }
} 