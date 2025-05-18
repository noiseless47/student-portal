import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deadline.dart';

class DeadlineProvider with ChangeNotifier {
  List<Deadline> _deadlines = [];
  bool _isLoading = false;
  
  List<Deadline> get deadlines => [..._deadlines];
  bool get isLoading => _isLoading;
  
  List<Deadline> get upcomingDeadlines {
    return _deadlines
        .where((deadline) => deadline.isUpcoming && !deadline.isCompleted)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  List<Deadline> get pastDueDeadlines {
    return _deadlines
        .where((deadline) => deadline.isPastDue)
        .toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }
  
  List<Deadline> get completedDeadlines {
    return _deadlines
        .where((deadline) => deadline.isCompleted)
        .toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }
  
  Future<void> loadDeadlines() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final deadlinesJson = prefs.getString('deadlines');
      
      if (deadlinesJson != null) {
        final List<dynamic> decodedData = json.decode(deadlinesJson);
        _deadlines = decodedData.map((item) => Deadline.fromJson(item)).toList();
      }
    } catch (error) {
      debugPrint('Error loading deadlines: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> saveDeadlines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deadlinesJson = json.encode(
        _deadlines.map((deadline) => deadline.toJson()).toList(),
      );
      await prefs.setString('deadlines', deadlinesJson);
    } catch (error) {
      debugPrint('Error saving deadlines: $error');
    }
  }
  
  Future<void> addDeadline(Deadline deadline) async {
    _deadlines.add(deadline);
    notifyListeners();
    await saveDeadlines();
  }
  
  Future<void> updateDeadline(Deadline updatedDeadline) async {
    final index = _deadlines.indexWhere((d) => d.id == updatedDeadline.id);
    if (index >= 0) {
      _deadlines[index] = updatedDeadline;
      notifyListeners();
      await saveDeadlines();
    }
  }
  
  Future<void> deleteDeadline(String id) async {
    _deadlines.removeWhere((deadline) => deadline.id == id);
    notifyListeners();
    await saveDeadlines();
  }
  
  Future<void> toggleDeadlineCompletion(String id) async {
    final index = _deadlines.indexWhere((deadline) => deadline.id == id);
    if (index >= 0) {
      final deadline = _deadlines[index];
      _deadlines[index] = deadline.copyWith(
        isCompleted: !deadline.isCompleted,
      );
      notifyListeners();
      await saveDeadlines();
    }
  }
  
  List<Deadline> getDeadlinesByCourse(String courseId) {
    return _deadlines
        .where((deadline) => deadline.courseId == courseId)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  Deadline? getDeadlineById(String id) {
    try {
      return _deadlines.firstWhere((deadline) => deadline.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Clear all deadlines (End Semester)
  Future<void> clearAllDeadlines() async {
    _deadlines.clear();
    notifyListeners();
    await saveDeadlines();
  }
} 