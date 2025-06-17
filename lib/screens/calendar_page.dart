import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/course_provider.dart';
import '../providers/deadline_provider.dart';
import '../themes/app_theme.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _viewType = 0; // 0 = All, 1 = Classes, 2 = To-dos

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final deadlineProvider = Provider.of<DeadlineProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Gather classes data
    Map<DateTime, List<Map<String, dynamic>>> classEvents = {};
    for (var course in courseProvider.courses) {
      for (var schedule in course.schedule) {
        // For each week day, find all dates in the current month
        DateTime firstOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
        DateTime lastOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
        for (int i = 0; i <= lastOfMonth.day - 1; i++) {
          DateTime date = firstOfMonth.add(Duration(days: i));
          if (date.weekday == schedule.day) {
            final dateKey = DateTime(date.year, date.month, date.day);
            classEvents.putIfAbsent(dateKey, () => []);
            classEvents[dateKey]!.add({
              'type': 'class',
              'course': course,
              'schedule': schedule,
            });
          }
        }
      }
    }

    // Gather deadlines data
    Map<DateTime, List<Map<String, dynamic>>> deadlineEvents = {};
    for (var deadline in deadlineProvider.deadlines) {
      final date = deadline.dueDate;
      final dateKey = DateTime(date.year, date.month, date.day);
      deadlineEvents.putIfAbsent(dateKey, () => []);
      deadlineEvents[dateKey]!.add({
        'type': 'deadline',
        'deadline': deadline,
      });
    }

    // Combined events
    Map<DateTime, List<Map<String, dynamic>>> allEvents = {};
    
    // Add class events
    classEvents.forEach((key, value) {
      allEvents.putIfAbsent(key, () => []);
      allEvents[key]!.addAll(value);
    });
    
    // Add deadline events
    deadlineEvents.forEach((key, value) {
      allEvents.putIfAbsent(key, () => []);
      allEvents[key]!.addAll(value);
    });

    List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
      final dateKey = DateTime(day.year, day.month, day.day);
      List<Map<String, dynamic>> events = [];
      
      if (_viewType == 0) { // All
        events = allEvents[dateKey] ?? [];
      } else if (_viewType == 1) { // Only classes
        events = classEvents[dateKey] ?? [];
      } else if (_viewType == 2) { // Only to-dos
        events = deadlineEvents[dateKey] ?? [];
      }
      
      return events;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // View Toggler
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black12 : Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterOption(0, 'All', isDarkMode),
                  _buildFilterOption(1, 'Classes', isDarkMode),
                  _buildFilterOption(2, 'To-dos', isDarkMode),
                ],
              ),
            ),
          ),
          
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 2,
              markerMargin: const EdgeInsets.symmetric(horizontal: 1.0),
              markerSize: 8.0,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                
                final dayEvents = _getEventsForDay(date);
                
                // Check for holidays first
                final hasHoliday = dayEvents.any((event) => 
                  event['type'] == 'deadline' && 
                  event['deadline'].type == 'holiday'
                );
                
                // If it's a holiday, only show red dot
                if (hasHoliday) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  );
                }
                
                // For non-holiday days, check for classes and to-dos
                final hasClass = dayEvents.any((event) => event['type'] == 'class');
                final hasTodo = dayEvents.any((event) => 
                  event['type'] == 'deadline' && 
                  event['deadline'].type != 'holiday'
                );
                
                List<Widget> markers = [];
                
                if (hasClass) {
                  markers.add(
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                
                if (hasTodo) {
                  markers.add(
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                
                return markers.isEmpty ? null : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: markers,
                );
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(),
          Expanded(
            child: Builder(
              builder: (context) {
                final events = _getEventsForDay(_selectedDay ?? _focusedDay);
                if (events.isEmpty) {
                  return Center(
                    child: Text(
                      _viewType == 0 ? 'Nothing scheduled for this day' 
                                    : (_viewType == 1 ? 'No classes on this day' 
                                                    : 'No to-dos on this day'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, idx) {
                    final event = events[idx];
                    final isClass = event['type'] == 'class';
                    
                    if (isClass) {
                      final course = event['course'];
                      final schedule = event['schedule'];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                            child: Icon(Icons.class_, color: AppTheme.primaryColor),
                          ),
                          title: Text(
                            course.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${schedule.startTime} - ${schedule.endTime}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    } else {
                      final deadline = event['deadline'];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: isDarkMode ? Colors.blueGrey[800] : Colors.orange[50],
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.2),
                            child: Icon(Icons.assignment, color: Colors.orange[700]),
                          ),
                          title: Text(
                            deadline.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deadline.courseName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Due: ${DateFormat('h:mm a').format(deadline.dueDate)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _isDeadlineSoon(deadline.dueDate) ? Colors.red : null,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  bool _isDeadlineSoon(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inHours;
    return difference <= 24 && difference >= 0;
  }

  Widget _buildFilterOption(int value, String label, bool isDarkMode) {
    final isSelected = _viewType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _viewType = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : isDarkMode 
                        ? Colors.white70 
                        : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getEventColor(List<Map<String, dynamic>> events) {
    if (events.isEmpty) return Colors.transparent;
    
    // Check if any event is a class
    bool hasClass = events.any((event) => event['type'] == 'class');
    
    // Check if any event is a to-do
    bool hasTodo = events.any((event) => 
      event['type'] == 'deadline' && 
      event['deadline'].type != 'holiday'
    );
    
    // If both class and to-do exist, return a list of colors
    if (hasClass && hasTodo) {
      return Colors.blue;
    }
    
    // Return blue for classes only
    if (hasClass) {
      return Colors.blue;
    }
    
    // Return yellow for to-dos only
    if (hasTodo) {
      return Colors.yellow;
    }
    
    return Colors.transparent;
  }
} 