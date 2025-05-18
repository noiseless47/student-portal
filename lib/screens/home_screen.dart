import 'package:flutter/material.dart';
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
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'add_edit_course_screen.dart';
import 'add_edit_deadline_screen.dart';
import 'settings_screen.dart';
import '../providers/user_profile_provider.dart';
import 'course_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Add listener to update the FAB when tab changes
    _tabController.addListener(() {
      setState(() {});
    });
    
    // Load data when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
      Provider.of<DeadlineProvider>(context, listen: false).loadDeadlines();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 230.0,
              floating: false,
              pinned: true,
              backgroundColor: innerBoxIsScrolled ? AppTheme.primaryColor : Colors.transparent,
              elevation: innerBoxIsScrolled ? 4 : 0,
              title: innerBoxIsScrolled ? Text(
                'Student Portal',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // Slightly smaller when scrolling
                ),
              ) : null,
              titleSpacing: 10,
              actions: [
                // Settings button
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                const SizedBox(width: 8), // Add a small padding on the right
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.zero,
                  title: null,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 50,
                        left: 16,
                        right: 16,
                        bottom: 65,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Student Portal title with same indent as welcome text
                          Text(
                            'Student Portal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8), // Reduce spacing between title and welcome text
                          Consumer<UserProfileProvider>(
                            builder: (context, userProfileProvider, _) {
                              final nickname = userProfileProvider.nickname.isNotEmpty 
                                ? userProfileProvider.nickname
                                : 'Student';
                              return Text(
                                'Welcome Back, $nickname!',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelPadding: const EdgeInsets.symmetric(vertical: 10.0),
                tabs: const [
                  Tab(text: 'Timetable'),
                  Tab(text: 'Courses'),
                  Tab(text: 'Deadlines'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTimetableTab(),
            _buildCoursesTab(),
            _buildDeadlinesTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  Widget _buildFloatingActionButton() {
    IconData icon;
    VoidCallback onPressed;
    
    switch (_tabController.index) {
      case 1:
        icon = Icons.school;
        onPressed = _addNewCourse;
        break;
      case 2:
        icon = Icons.add_task;
        onPressed = _addNewDeadline;
        break;
      default:
        // No FAB for timetable tab
        return const SizedBox.shrink();
    }
    
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon),
      backgroundColor: AppTheme.primaryColor,
    );
  }
  
  Widget _buildCoursesTab() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        if (courseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final courses = courseProvider.courses;
        
        if (courses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No courses yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first course to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addNewCourse,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Course'),
                ),
              ],
            ),
          );
        }
        
        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 80),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: AppTheme.mediumAnimationDuration,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: CourseCard(
                      course: courses[index],
                      onTap: () => _viewCourseDetails(courses[index]),
                      onMarkAttendance: () => _markAttendance(courses[index].id),
                      onMarkAbsence: () => _markAttendanceWithStatus(courses[index].id, false),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
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
                                            schedule.room,
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
  
  Widget _buildDeadlinesTab() {
    return Consumer<DeadlineProvider>(
      builder: (context, deadlineProvider, child) {
        if (deadlineProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final upcomingDeadlines = deadlineProvider.upcomingDeadlines;
        final pastDueDeadlines = deadlineProvider.pastDueDeadlines;
        final completedDeadlines = deadlineProvider.completedDeadlines;
        
        if (upcomingDeadlines.isEmpty && pastDueDeadlines.isEmpty && completedDeadlines.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No deadlines yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first deadline to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addNewDeadline,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Deadline'),
                ),
              ],
            ),
          );
        }
        
        return AnimationLimiter(
          child: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            children: [
              if (upcomingDeadlines.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Upcoming',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(upcomingDeadlines.length, (index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: AppTheme.mediumAnimationDuration,
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: DeadlineCard(
                          deadline: upcomingDeadlines[index],
                          onTap: () => _viewDeadlineDetails(upcomingDeadlines[index]),
                          onToggleCompletion: () => _toggleDeadlineCompletion(upcomingDeadlines[index].id),
                        ),
                      ),
                    ),
                  );
                }),
              ],
              
              if (pastDueDeadlines.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Past Due',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ),
                ...List.generate(pastDueDeadlines.length, (index) {
                  return AnimationConfiguration.staggeredList(
                    position: index + upcomingDeadlines.length,
                    duration: AppTheme.mediumAnimationDuration,
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: DeadlineCard(
                          deadline: pastDueDeadlines[index],
                          onTap: () => _viewDeadlineDetails(pastDueDeadlines[index]),
                          onToggleCompletion: () => _toggleDeadlineCompletion(pastDueDeadlines[index].id),
                        ),
                      ),
                    ),
                  );
                }),
              ],
              
              if (completedDeadlines.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Completed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ),
                ...List.generate(completedDeadlines.length, (index) {
                  return AnimationConfiguration.staggeredList(
                    position: index + upcomingDeadlines.length + pastDueDeadlines.length,
                    duration: AppTheme.mediumAnimationDuration,
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: DeadlineCard(
                          deadline: completedDeadlines[index],
                          onTap: () => _viewDeadlineDetails(completedDeadlines[index]),
                          onToggleCompletion: () => _toggleDeadlineCompletion(completedDeadlines[index].id),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as attended'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Mark as absent - increment only held, not attended
      provider.markAttendanceWithStatus(courseId, false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as absent'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _markClassCancelled(String courseId) {
    // Class didn't happen - no changes to attendance counts
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Class marked as cancelled'),
        backgroundColor: Colors.grey,
      ),
    );
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
    Color backgroundColor = status == 'attended' 
        ? Colors.green
        : status == 'absent' 
            ? Colors.red 
            : Colors.grey;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(statusMessage),
        backgroundColor: backgroundColor,
      ),
    );
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
} 