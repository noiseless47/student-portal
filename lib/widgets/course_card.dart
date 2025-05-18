import 'package:flutter/material.dart';
import '../models/course.dart';
import '../themes/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onMarkAttendance;
  final VoidCallback? onMarkAbsence;
  
  const CourseCard({
    Key? key,
    required this.course,
    required this.onTap,
    required this.onMarkAttendance,
    this.onMarkAbsence,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final attendancePercentage = course.attendancePercentage;
    final isAttendanceCritical = course.isAttendanceCritical;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    final primaryColor = isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;
    final successColor = AppTheme.successColor;
    final errorColor = isDarkMode ? AppTheme.darkErrorColor : AppTheme.errorColor;
    final textSecondary = isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.code,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        color: Colors.green,
                        onPressed: onMarkAttendance,
                        tooltip: 'Mark Attended',
                      ),
                      if (onMarkAbsence != null)
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          color: Colors.red,
                          onPressed: onMarkAbsence,
                          tooltip: 'Mark Absent',
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Professor
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    course.professor,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Schedule - Days of week in circles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDayCircle(context, 'M', 1, primaryColor),
                  _buildDayCircle(context, 'T', 2, primaryColor),
                  _buildDayCircle(context, 'W', 3, primaryColor),
                  _buildDayCircle(context, 'T', 4, primaryColor),
                  _buildDayCircle(context, 'F', 5, primaryColor),
                  _buildDayCircle(context, 'S', 6, primaryColor),
                  _buildDayCircle(context, 'S', 7, primaryColor),
                ],
              ),
              const SizedBox(height: 16),
              
              // Attendance Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${attendancePercentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isAttendanceCritical 
                              ? errorColor
                              : successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: course.attendancePercentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: isAttendanceCritical 
                        ? errorColor 
                        : successColor,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${course.classesAttended}/${course.classesHeld} classes attended',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCircle(BuildContext context, String day, int dayNumber, Color color) {
    // Check if there's a class on this day
    final hasClass = course.schedule.any((schedule) => schedule.day == dayNumber);
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    // Background color should be different in dark mode for days without classes
    final backgroundColor = hasClass 
        ? color.withOpacity(0.2) 
        : isDarkMode 
            ? Colors.grey.shade800  // Dark background for no-class days in dark mode
            : Colors.grey.shade200;  // Light background for no-class days in light mode
    
    // Text color should be different in dark mode for days without classes
    final textColor = hasClass 
        ? color 
        : isDarkMode 
            ? Colors.grey.shade400  // Lighter grey text in dark mode
            : Colors.grey;          // Standard grey text in light mode
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: hasClass ? Border.all(color: color, width: 2) : null,
      ),
      child: Center(
        child: Text(
          day,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
} 