class Course {
  final String id;
  final String name;
  final String code;
  final String professor;
  final String room; // Common room for the course
  final List<ClassSchedule> schedule;
  int classesHeld;      // Renamed from totalSessions
  int classesAttended;  // Renamed from attendedSessions
  Map<String, String> attendanceByDate; // Map of date -> status ('attended', 'absent', 'cancelled')
  
  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.professor,
    this.room = '',
    required this.schedule,
    this.classesHeld = 0,     // Default to 0, renamed
    this.classesAttended = 0, // Renamed
    Map<String, String>? attendanceByDate,
  }) : this.attendanceByDate = attendanceByDate ?? {};
  
  double get attendancePercentage => 
      classesHeld > 0 ? (classesAttended / classesHeld) * 100 : 0;
  
  bool get isAttendanceCritical => attendancePercentage < 75;
  
  void markAttendance() {
    if (classesAttended < classesHeld) {
      classesAttended++;
    }
  }
  
  // Check if attendance has been marked for a specific date
  bool isAttendanceMarkedForDate(String dateKey) {
    return attendanceByDate.containsKey(dateKey);
  }
  
  // Get attendance status for a specific date
  String? getAttendanceStatus(String dateKey) {
    return attendanceByDate[dateKey];
  }
  
  // Mark attendance for a specific date
  void markAttendanceForDate(String dateKey, String status) {
    attendanceByDate[dateKey] = status;
  }
  
  Course copyWith({
    String? id,
    String? name,
    String? code,
    String? professor,
    String? room,
    List<ClassSchedule>? schedule,
    int? classesHeld,
    int? classesAttended,
    Map<String, String>? attendanceByDate,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      professor: professor ?? this.professor,
      room: room ?? this.room,
      schedule: schedule ?? this.schedule,
      classesHeld: classesHeld ?? this.classesHeld,
      classesAttended: classesAttended ?? this.classesAttended,
      attendanceByDate: attendanceByDate ?? this.attendanceByDate,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'professor': professor,
      'room': room,
      'schedule': schedule.map((s) => s.toJson()).toList(),
      'classesHeld': classesHeld,
      'classesAttended': classesAttended,
      'attendanceByDate': attendanceByDate,
    };
  }
  
  factory Course.fromJson(Map<String, dynamic> json) {
    // Handle backwards compatibility with old data structure
    final classesHeld = json.containsKey('classesHeld') 
        ? json['classesHeld'] 
        : json['totalSessions'] ?? 0;
        
    final classesAttended = json.containsKey('classesAttended')
        ? json['classesAttended']
        : json['attendedSessions'] ?? 0;
        
    // Handle attendance by date
    Map<String, String> attendanceByDate = {};
    if (json.containsKey('attendanceByDate')) {
      final Map<String, dynamic> attendanceData = json['attendanceByDate'];
      attendanceData.forEach((key, value) {
        attendanceByDate[key] = value.toString();
      });
    }
    
    return Course(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      professor: json['professor'],
      room: json.containsKey('room') ? json['room'] : '',
      schedule: (json['schedule'] as List)
          .map((s) => ClassSchedule.fromJson(s))
          .toList(),
      classesHeld: classesHeld,
      classesAttended: classesAttended,
      attendanceByDate: attendanceByDate,
    );
  }
}

class ClassSchedule {
  final int day; // 1 = Monday, 2 = Tuesday, etc.
  final String startTime;
  final String endTime;
  final String? room; // Optional now, will use course.room if null
  
  ClassSchedule({
    required this.day,
    required this.startTime,
    required this.endTime,
    this.room,
  });
  
  String get dayName {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
    };
  }
  
  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      day: json['day'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      room: json['room'],
    );
  }
} 