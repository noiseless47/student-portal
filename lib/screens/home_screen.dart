import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../providers/deadline_provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_theme.dart';
import '../widgets/course_card.dart';
import '../widgets/deadline_card.dart';
import '../utils/id_generator.dart';
import '../models/course.dart';
import '../models/deadline.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'add_edit_course_screen.dart';
import 'add_edit_deadline_screen.dart';
import 'settings_screen.dart';
import '../providers/user_profile_provider.dart';
import 'course_detail_screen.dart';
import 'profile_screen.dart';
import 'todo_screen.dart';
import 'calendar_page.dart';
import '../utils/toast_util.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  @override
  void initState() {
    super.initState();
    
    // Load data when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
      Provider.of<DeadlineProvider>(context, listen: false).loadDeadlines();
    });
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final isDarkMode = themeProvider.isDarkMode;
              final drawerBg = isDarkMode ? Colors.black : Colors.white;
              final textColor = isDarkMode ? Colors.white : Colors.black;
              final iconColor = isDarkMode ? Colors.white : Colors.black;
              final highlightColor = isDarkMode ? const Color(0xFF1976D2) : const Color(0xFF1976D2);
              return Container(
                color: drawerBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ClassMate',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              fontFamily: 'Outfit',
                              letterSpacing: 0.5,
                            ),
                          ),
                          Consumer<UserProfileProvider>(
                            builder: (context, userProfileProvider, _) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileScreen(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: highlightColor,
                                  child: Text(
                                    userProfileProvider.initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Navigation section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          // Classes (selected)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: highlightColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.home, color: Colors.white),
                              title: const Text(
                                'Classes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                          ),
                          // Calendar
                          ListTile(
                            leading: Icon(Icons.calendar_today, color: iconColor),
                            title: Text(
                              'Calendar',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CalendarPage(),
                                ),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          // Notifications
                          ListTile(
                            leading: Icon(Icons.notifications, color: iconColor),
                            title: Text(
                              'Notifications',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            onTap: () {
                              // TODO: Implement notifications
                              ToastUtil.show('Notifications coming soon!');
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          // To-do (moved here, styled like notifications)
                          ListTile(
                            leading: Icon(Icons.checklist, color: iconColor),
                            title: Text(
                              'To-do',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showTodoScreen();
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Courses section title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                        'Courses',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Outfit',
                        ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: highlightColor, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditCourseScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Course list
                    Expanded(
                      child: Consumer<CourseProvider>(
                        builder: (context, courseProvider, _) {
                          final courses = courseProvider.courses;
                          if (courses.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No courses yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 8),
                            itemCount: courses.length,
                            separatorBuilder: (context, idx) => const SizedBox(height: 0),
                            itemBuilder: (context, idx) {
                              final course = courses[idx];
                              return ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        course.name,
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Outfit',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${course.classesAttended}/${course.classesHeld}',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white70 : Colors.black54,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: course.isAttendanceCritical ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${course.attendancePercentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: course.isAttendanceCritical ? Colors.red : Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  course.room.isNotEmpty ? course.room : course.code,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                    fontFamily: 'Outfit',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _viewCourseDetails(course);
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Settings and Help at the bottom as ListTiles
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Column(
                        children: [
                          Divider(color: isDarkMode ? Colors.white24 : Colors.black12, height: 1),
                          ListTile(
                            leading: Icon(Icons.settings, color: iconColor),
                            title: Text('Settings', style: TextStyle(color: textColor, fontFamily: 'Lexend')),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          ListTile(
                            leading: Icon(Icons.help_outline, color: iconColor),
                            title: Text('Help', style: TextStyle(color: textColor, fontFamily: 'Lexend')),
                            onTap: () async {
                              Navigator.pop(context);
                              final Uri url = Uri.parse('https://www.asishky.me/classmate/help/');
                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                ToastUtil.showError('Could not open help page');
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            final isDarkMode = themeProvider.isDarkMode;
            final textColor = isDarkMode ? Colors.white : Colors.black;
            final iconColor = isDarkMode ? Colors.white : Colors.black;
            final bgColor = isDarkMode ? Colors.black : Colors.white;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              icon: Icon(Icons.menu, color: iconColor, size: 28),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ClassMate',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Consumer<UserProfileProvider>(
                        builder: (context, userProfileProvider, _) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: isDarkMode ? Colors.white : Colors.black,
                              child: Text(
                                userProfileProvider.initials,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Consumer2<DeadlineProvider, ThemeProvider>(
                    builder: (context, deadlineProvider, themeProvider, _) {
                      final isDarkMode = themeProvider.isDarkMode;
                      final boxColor = isDarkMode ? Colors.black : Colors.white;
                      final borderColor = isDarkMode ? Colors.white24 : Colors.black12;
                      final textColor = isDarkMode ? Colors.white : Colors.black;
                      final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
                      final iconBg = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
                      final iconColor = isDarkMode ? Colors.white : Colors.black;
                      final blueLink = themeProvider.isDarkMode 
                        ? Colors.lightBlue[300]!
                        : Colors.blue[700]!;
                      final upcomingDeadlines = deadlineProvider.upcomingDeadlines;

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.checklist_rounded,
                                        color: isDarkMode ? AppTheme.primaryColor : AppTheme.primaryColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'To-Do This Week',
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => _showTodoScreen(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        'View all',
                                        style: TextStyle(
                                          color: blueLink,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (upcomingDeadlines.isEmpty) ...[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 48,
                                          color: subTextColor.withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No work coming up immediately',
                                          style: TextStyle(
                                            color: subTextColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                ...upcomingDeadlines.take(3).map((deadline) => GestureDetector(
                                  onTap: () => _showTodoScreen(),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.black12 : Colors.black.withOpacity(0.02),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDarkMode ? Colors.white12 : Colors.black.withOpacity(0.05),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Priority indicator dot instead of checkbox
                                          Container(
                                            margin: const EdgeInsets.only(top: 5),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _getDeadlineTypeColor(deadline.type, isDarkMode),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        deadline.title,
                                                        style: TextStyle(
                                                          color: textColor,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 8),
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: _getDeadlineTypeColor(deadline.type, isDarkMode).withOpacity(0.15),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(
                                                        deadline.deadlineTypeDisplay,
                                                        style: TextStyle(
                                                          color: _getDeadlineTypeColor(deadline.type, isDarkMode),
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                if (deadline.courseName.isNotEmpty)
                                                  Text(
                                                    deadline.courseName,
                                                    style: TextStyle(
                                                      color: subTextColor,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time_rounded,
                                                      size: 14,
                                                      color: subTextColor.withOpacity(0.8),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${deadline.smartDate}, ${DateFormat('h:mm a').format(deadline.dueDate)}',
                                                      style: TextStyle(
                                                        color: subTextColor,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )).toList(),
                                if (upcomingDeadlines.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => _showTodoScreen(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'View ${upcomingDeadlines.length - 3} more',
                                                style: TextStyle(
                                                  color: blueLink,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12,
                                                color: blueLink,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildTimetableTab(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildTimetableTab() {
    final today = DateTime.now();
    final weekday = today.weekday;
    
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
        ),
        const Divider(),
        Expanded(
          child: Consumer<CourseProvider>(
            builder: (context, courseProvider, child) {
              final schedules = courseProvider.getScheduleForDay(_selectedDay.weekday);
              final courses = courseProvider.getCoursesForDay(_selectedDay.weekday);
              
              if (schedules.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: AppTheme.primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No classes today',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enjoy your free day!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final courseSchedules = course.schedule
                      .where((s) => s.day == _selectedDay.weekday)
                      .toList();
                  
                  // Check if attendance is already marked for this date
                  final isAttendanceMarked = courseProvider.isAttendanceMarkedForDate(
                    course.id, 
                    _selectedDay
                  );
                  final attendanceStatus = isAttendanceMarked 
                      ? courseProvider.getAttendanceStatusForDate(course.id, _selectedDay)
                      : null;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      course.code,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Show attendance status or action buttons
                              if (isAttendanceMarked) ...[
                                // Show the attendance status
                                _buildAttendanceStatusChip(context, attendanceStatus ?? ''),
                              ] else if (!_selectedDay.isAfter(DateTime.now())) ...[
                                // Show attendance action buttons
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline),
                                  color: Colors.green,
                                  tooltip: 'Mark Attended',
                                  onPressed: () => _markAttendanceForDate(course.id, 'attended'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel_outlined),
                                  color: Colors.red,
                                  tooltip: 'Mark Absent',
                                  onPressed: () => _markAttendanceForDate(course.id, 'absent'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.grey,
                                  tooltip: 'Mark Cancelled',
                                  onPressed: () => _markAttendanceForDate(course.id, 'cancelled'),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...courseSchedules.map((schedule) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  // Time section
                                  Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${schedule.startTime} - ${schedule.endTime}',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Location
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.room,
                                          size: 16,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            schedule.room ?? course.room,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Attendance percentage
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getAttendanceColor(course.attendancePercentage).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getAttendanceColor(course.attendancePercentage),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${course.attendancePercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: _getAttendanceColor(course.attendancePercentage),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  void _addNewCourse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditCourseScreen()),
    );
    
    if (result == true) {
      // Course added successfully, no additional action needed
      // as the provider is already updated
    }
  }
  
  void _addNewDeadline() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditDeadlineScreen()),
    );
    
    if (result == true) {
      // Deadline added successfully, no additional action needed
      // as the provider is already updated
    }
  }
  
  void _viewCourseDetails(Course course) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
    
    if (result == true) {
      // Course updated successfully, refresh the courses
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    }
  }
  
  void _viewDeadlineDetails(Deadline deadline) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDeadlineScreen(deadline: deadline),
      ),
    );
    
    if (result == true) {
      // Deadline updated successfully, no additional action needed
      // as the provider is already updated
    }
  }
  
  void _markAttendanceWithStatus(String courseId, bool attended) {
    final provider = Provider.of<CourseProvider>(context, listen: false);
    
    if (attended) {
      // Mark as attended - increment both held and attended
      provider.markAttendanceWithStatus(courseId, true);
      ToastUtil.show('Marked as attended');
    } else {
      // Mark as absent - increment only held, not attended
      provider.markAttendanceWithStatus(courseId, false);
      ToastUtil.show('Marked as absent');
    }
  }
  
  void _markClassCancelled(String courseId) {
    // Class didn't happen - no changes to attendance counts
    ToastUtil.show('Class marked as cancelled');
  }

  void _toggleDeadlineCompletion(String deadlineId) {
    Provider.of<DeadlineProvider>(context, listen: false).toggleDeadlineCompletion(deadlineId);
  }

  // Renamed this method to avoid confusion with the new _markAttendanceWithStatus
  void _markAttendance(String courseId) {
    _markAttendanceWithStatus(courseId, true);
  }

  void _markAttendanceForDate(String courseId, String status) {
    final provider = Provider.of<CourseProvider>(context, listen: false);
    provider.markAttendanceByDate(courseId, _selectedDay, status);
    
    String statusMessage = 'Marked as $status';
    
    ToastUtil.show(statusMessage);
  }

  Widget _buildAttendanceStatusChip(BuildContext context, String status) {
    Color bgColor;
    Color textColor = Colors.white;
    IconData statusIcon;
    
    if (status == 'attended') {
      bgColor = Colors.green.shade600;
      statusIcon = Icons.check_circle;
    } else if (status == 'absent') {
      bgColor = Colors.red.shade600;
      statusIcon = Icons.cancel;
    } else {
      bgColor = Colors.grey.shade600;
      textColor = Colors.black87;
      statusIcon = Icons.remove_circle;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: textColor, size: 16),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage < 50) {
      return Colors.red[800]!; // Deep red for very critical
    } else if (percentage < 65) {
      return Colors.red; // Red for critical
    } else if (percentage < 75) {
      return Colors.orange; // Orange for borderline
    } else if (percentage < 85) {
      return Colors.amber; // Amber for okay
    } else if (percentage < 95) {
      return Colors.lightGreen; // Light green for good
    } else {
      return Colors.green[700]!; // Dark green for excellent
    }
  }

  // Helper method to get color based on deadline type
  Color _getDeadlineTypeColor(DeadlineType type, bool isDarkMode) {
    switch (type) {
      case DeadlineType.assignment:
        return isDarkMode ? Colors.blue[200]! : Colors.blue[600]!;
      case DeadlineType.exam:
        return isDarkMode ? Colors.red[200]! : Colors.red[600]!;
      case DeadlineType.project:
        return isDarkMode ? Colors.purple[200]! : Colors.purple[600]!;
      case DeadlineType.presentation:
        return isDarkMode ? Colors.amber[200]! : Colors.amber[600]!;
      case DeadlineType.other:
        return isDarkMode ? Colors.green[200]! : Colors.green[600]!;
    }
  }

  void _showTodoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TodoScreen(),
      ),
    );
  }
} 