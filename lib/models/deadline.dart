import 'package:intl/intl.dart';

enum DeadlineType {
  assignment,
  exam,
  project,
  presentation,
  other
}

class Deadline {
  final String id;
  final String title;
  final String courseId;
  final String courseName;
  final DateTime dueDate;
  final DeadlineType type;
  final String description;
  bool isCompleted;
  
  Deadline({
    required this.id,
    required this.title,
    required this.courseId,
    required this.courseName,
    required this.dueDate,
    required this.type,
    this.description = '',
    this.isCompleted = false,
  });
  
  String get formattedDate => DateFormat('MMM dd, yyyy').format(dueDate);
  
  String get formattedTime => DateFormat('hh:mm a').format(dueDate);
  
  String get smartDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (dueDay == today) {
      return 'Today';
    } else if (dueDay == tomorrow) {
      return 'Tomorrow';
    } else if (dueDay == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(dueDate);
    }
  }
  
  bool get isUpcoming => dueDate.isAfter(DateTime.now());
  
  bool get isPastDue => !isUpcoming && !isCompleted;
  
  int get daysRemaining {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }
  
  String get deadlineTypeDisplay {
    switch (type) {
      case DeadlineType.assignment: return 'Assignment';
      case DeadlineType.exam: return 'Exam';
      case DeadlineType.project: return 'Project';
      case DeadlineType.presentation: return 'Presentation';
      case DeadlineType.other: return 'Other';
    }
  }
  
  Deadline copyWith({
    String? id,
    String? title,
    String? courseId,
    String? courseName,
    DateTime? dueDate,
    DeadlineType? type,
    String? description,
    bool? isCompleted,
  }) {
    return Deadline(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'courseId': courseId,
      'courseName': courseName,
      'dueDate': dueDate.toIso8601String(),
      'type': type.index,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
  
  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      id: json['id'],
      title: json['title'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      dueDate: DateTime.parse(json['dueDate']),
      type: DeadlineType.values[json['type']],
      description: json['description'],
      isCompleted: json['isCompleted'],
    );
  }
} 