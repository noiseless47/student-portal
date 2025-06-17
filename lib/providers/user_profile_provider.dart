import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  String _name = '';
  String _email = '';
  String _university = '';
  String _department = '';
  String _academicYear = '';
  String _studentId = '';
  String _bio = '';
  String _phoneNumber = '';
  bool _isLoading = false;
  
  String get name => _name;
  String get email => _email;
  String get university => _university;
  String get department => _department;
  String get academicYear => _academicYear;
  String get studentId => _studentId;
  String get bio => _bio;
  String get phoneNumber => _phoneNumber;
  bool get isLoading => _isLoading;
  
  String get initials {
    if (_name.isEmpty) return 'S';
    final nameParts = _name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return _name[0].toUpperCase();
  }
  
  UserProfileProvider() {
    // Load user profile when provider is created
    loadUserProfile();
  }
  
  Future<void> loadUserProfile() async {
    _isLoading = true;
    // Notify listeners in a separate microtask to avoid build phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString('user_name') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _university = prefs.getString('user_university') ?? '';
      _department = prefs.getString('user_department') ?? '';
      _academicYear = prefs.getString('user_academic_year') ?? '';
      _studentId = prefs.getString('user_student_id') ?? '';
      _bio = prefs.getString('user_bio') ?? '';
      _phoneNumber = prefs.getString('user_phone_number') ?? '';
    } catch (error) {
      debugPrint('Error loading user profile: $error');
    } finally {
      _isLoading = false;
      // Notify listeners in a separate microtask to avoid build phase issues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
  
  Future<void> saveUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _name);
      await prefs.setString('user_email', _email);
      await prefs.setString('user_university', _university);
      await prefs.setString('user_department', _department);
      await prefs.setString('user_academic_year', _academicYear);
      await prefs.setString('user_student_id', _studentId);
      await prefs.setString('user_bio', _bio);
      await prefs.setString('user_phone_number', _phoneNumber);
    } catch (error) {
      debugPrint('Error saving user profile: $error');
      rethrow;
    }
  }
  
  Future<void> updateProfile({
    String? name,
    String? email,
    String? university,
    String? department,
    String? academicYear,
    String? studentId,
    String? bio,
    String? phoneNumber,
  }) async {
    try {
      // Update values
      bool hasChanges = false;
      
      if (name != null && name != _name) {
        _name = name;
        hasChanges = true;
      }
      
      if (email != null && email != _email) {
        _email = email;
        hasChanges = true;
      }
      
      if (university != null && university != _university) {
        _university = university;
        hasChanges = true;
      }
      
      if (department != null && department != _department) {
        _department = department;
        hasChanges = true;
      }
      
      if (academicYear != null && academicYear != _academicYear) {
        _academicYear = academicYear;
        hasChanges = true;
      }
      
      if (studentId != null && studentId != _studentId) {
        _studentId = studentId;
        hasChanges = true;
      }
      
      if (bio != null && bio != _bio) {
        _bio = bio;
        hasChanges = true;
      }
      
      if (phoneNumber != null && phoneNumber != _phoneNumber) {
        _phoneNumber = phoneNumber;
        hasChanges = true;
      }
      
      if (hasChanges) {
        // Save to storage first
        await saveUserProfile();
        
        // Then notify listeners in a separate microtask
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (error) {
      debugPrint('Error updating profile: $error');
      rethrow;
    }
  }
} 