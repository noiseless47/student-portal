import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../providers/deadline_provider.dart';
import 'package:provider/provider.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];
  bool _isLoading = false;
  
  List<Course> get courses => [..._courses];
  bool get isLoading => _isLoading;
  
  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getString('courses');
      
      if (coursesJson != null) {
        final List<dynamic> decodedData = json.decode(coursesJson);
        _courses = decodedData.map((item) => Course.fromJson(item)).toList();
      }
    } catch (error) {
      debugPrint('Error loading courses: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> saveCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = json.encode(
        _courses.map((course) => course.toJson()).toList(),
      );
      await prefs.setString('courses', coursesJson);
    } catch (error) {
      debugPrint('Error saving courses: $error');
    }
  }
  
  Future<void> addCourse(Course course) async {
    _courses.add(course);
    notifyListeners();
    await saveCourses();
  }
  
  Future<void> updateCourse(Course updatedCourse) async {
    final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index >= 0) {
      _courses[index] = updatedCourse;
      notifyListeners();
      await saveCourses();
    }
  }
  
  Future<void> deleteCourse(String id) async {
    _courses.removeWhere((course) => course.id == id);
    notifyListeners();
    await saveCourses();
  }
  
  Future<void> deleteCourseCascade(String id, BuildContext context) async {
    // Delete the course
    _courses.removeWhere((course) => course.id == id);
    notifyListeners();
    await saveCourses();
    
    // Also delete associated deadlines
    final deadlineProvider = Provider.of<DeadlineProvider>(context, listen: false);
    final deadlines = deadlineProvider.deadlines;
    final relatedDeadlineIds = deadlines
        .where((deadline) => deadline.courseId == id)
        .map((deadline) => deadline.id)
        .toList();
    
    for (final deadlineId in relatedDeadlineIds) {
      await deadlineProvider.deleteDeadline(deadlineId);
    }
  }
  
  Future<void> markAttendance(String courseId) async {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index >= 0) {
      final updatedCourse = _courses[index].copyWith(
        classesHeld: _courses[index].classesHeld + 1,
        classesAttended: _courses[index].classesAttended + 1,
      );
      _courses[index] = updatedCourse;
      notifyListeners();
      await saveCourses();
    }
  }
  
  Future<void> markAttendanceWithStatus(String courseId, bool attended) async {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index >= 0) {
      if (attended) {
        final updatedCourse = _courses[index].copyWith(
          classesHeld: _courses[index].classesHeld + 1,
          classesAttended: _courses[index].classesAttended + 1,
        );
        _courses[index] = updatedCourse;
      } else {
        final updatedCourse = _courses[index].copyWith(
          classesHeld: _courses[index].classesHeld + 1,
        );
        _courses[index] = updatedCourse;
      }
      notifyListeners();
      await saveCourses();
    }
  }
  
  // Mark attendance by date
  Future<void> markAttendanceByDate(String courseId, DateTime date, String status) async {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index >= 0) {
      final dateKey = _formatDateKey(date);
      final course = _courses[index];
      
      // Make a copy of the attendance map
      final Map<String, String> updatedAttendance = Map.from(course.attendanceByDate);
      updatedAttendance[dateKey] = status;
      
      // Update the course with new attendance
      if (status == 'attended') {
        final updatedCourse = course.copyWith(
          classesHeld: course.classesHeld + 1,
          classesAttended: course.classesAttended + 1,
          attendanceByDate: updatedAttendance,
        );
        _courses[index] = updatedCourse;
      } else if (status == 'absent') {
        final updatedCourse = course.copyWith(
          classesHeld: course.classesHeld + 1,
          attendanceByDate: updatedAttendance,
        );
        _courses[index] = updatedCourse;
      } else if (status == 'cancelled') {
        // For cancelled classes, just mark status without changing counts
        final updatedCourse = course.copyWith(
          attendanceByDate: updatedAttendance,
        );
        _courses[index] = updatedCourse;
      }
      
      notifyListeners();
      await saveCourses();
    }
  }
  
  // Check if attendance is marked for a specific date
  bool isAttendanceMarkedForDate(String courseId, DateTime date) {
    final course = getCourseById(courseId);
    if (course != null) {
      final dateKey = _formatDateKey(date);
      return course.isAttendanceMarkedForDate(dateKey);
    }
    return false;
  }
  
  // Get attendance status for a specific date
  String? getAttendanceStatusForDate(String courseId, DateTime date) {
    final course = getCourseById(courseId);
    if (course != null) {
      final dateKey = _formatDateKey(date);
      return course.getAttendanceStatus(dateKey);
    }
    return null;
  }
  
  // Format date to use as a key in the attendance map
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  List<Course> getCoursesForDay(int day) {
    return _courses.where((course) {
      return course.schedule.any((schedule) => schedule.day == day);
    }).toList();
  }
  
  List<ClassSchedule> getScheduleForDay(int day) {
    List<ClassSchedule> schedules = [];
    
    for (final course in _courses) {
      for (final schedule in course.schedule) {
        if (schedule.day == day) {
          schedules.add(schedule);
        }
      }
    }
    
    // Sort by start time
    schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
    return schedules;
  }
  
  Course? getCourseById(String id) {
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Clear all courses and course data (End Semester)
  Future<void> clearAllCourses(BuildContext context) async {
    // Clear the courses list
    _courses.clear();
    notifyListeners();
    await saveCourses();
    
    // Also delete associated deadlines
    final deadlineProvider = Provider.of<DeadlineProvider>(context, listen: false);
    await deadlineProvider.clearAllDeadlines();
  }
} 