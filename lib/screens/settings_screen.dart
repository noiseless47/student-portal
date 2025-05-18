import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider.dart';
import '../themes/app_theme.dart';
import '../models/course.dart';
import 'add_edit_course_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User Profile Settings
          _buildSettingsSection(
            context,
            'User Profile',
            [
              _buildUserProfileSettings(context),
            ],
          ),
          
          // Theme Settings
          _buildSettingsSection(
            context,
            'Appearance',
            [
              _buildThemeSwitcher(context),
            ],
          ),
          
          // Course Management
          _buildSettingsSection(
            context,
            'Course Management',
            [
              _buildCourseList(context),
            ],
          ),
          
          // Semester Management
          _buildSettingsSection(
            context,
            'Semester Management',
            [
              ListTile(
                leading: const Icon(Icons.event_busy, color: Colors.red),
                title: const Text('End Semester'),
                subtitle: const Text('Clear all courses and deadlines to start a new semester'),
                onTap: () => _showEndSemesterConfirmation(context),
              ),
            ],
          ),
          
          // App Information
          _buildSettingsSection(
            context,
            'About',
            [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Privacy Policy'),
                onTap: () {
                  _showPrivacyPolicyDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(height: 4),
      ],
    );
  }
  
  Widget _buildUserProfileSettings(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Full Name'),
          subtitle: Text(
            userProfileProvider.name.isNotEmpty 
                ? userProfileProvider.name 
                : 'Not set'
          ),
          trailing: const Icon(Icons.edit),
          onTap: () => _showNameEditDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.face),
          title: const Text('Nickname'),
          subtitle: Text(
            userProfileProvider.nickname.isNotEmpty 
                ? userProfileProvider.nickname 
                : 'Not set'
          ),
          trailing: const Icon(Icons.edit),
          onTap: () => _showNicknameEditDialog(context),
        ),
      ],
    );
  }
  
  void _showNameEditDialog(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final TextEditingController controller = TextEditingController(text: userProfileProvider.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Full Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                userProfileProvider.updateProfile(name: controller.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name updated successfully')),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    ).then((_) {
      controller.dispose();
    });
  }
  
  void _showNicknameEditDialog(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final TextEditingController controller = TextEditingController(text: userProfileProvider.nickname);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nickname'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nickname',
            hintText: 'Enter your nickname',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                userProfileProvider.updateProfile(nickname: controller.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nickname updated successfully')),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    ).then((_) {
      controller.dispose();
    });
  }
  
  Widget _buildThemeSwitcher(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SwitchListTile(
      title: const Text('Dark Mode'),
      subtitle: Text(themeProvider.isDarkMode ? 'Currently using dark theme' : 'Currently using light theme'),
      secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
      value: themeProvider.isDarkMode,
      onChanged: (_) {
        themeProvider.toggleTheme();
      },
    );
  }
  
  Widget _buildCourseList(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final courses = courseProvider.courses;
        
        if (courses.isEmpty) {
          return const ListTile(
            leading: Icon(Icons.school_outlined),
            title: Text('No courses'),
            subtitle: Text('Add courses from the main screen'),
          );
        }
        
        return ExpansionTile(
          title: const Text('Manage Courses'),
          subtitle: Text('${courses.length} courses'),
          leading: const Icon(Icons.school),
          initiallyExpanded: true,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: Text(
                      course.code.isNotEmpty 
                          ? course.code.substring(0, min(2, course.code.length))
                          : '',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(course.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.code),
                      Text(
                        'Attendance: ${course.classesAttended}/${course.classesHeld} (${course.attendancePercentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: course.isAttendanceCritical ? Colors.red : Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => _editCourse(context, course),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                        onPressed: () => _editCourse(context, course),
                        tooltip: 'Edit Course',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context, course),
                        tooltip: 'Delete Course',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  void _editCourse(BuildContext context, Course course) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCourseScreen(course: course),
      ),
    );
    
    if (result == true) {
      // Course updated successfully, show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
  
  void _showDeleteConfirmation(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete "${course.name}"?\n\n'
          'This will also delete all associated deadlines and attendance records.',
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<CourseProvider>(context, listen: false).deleteCourseCascade(course.id, context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${course.name} deleted'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Effective Date: May 15, 2023',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Student Portal ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how your personal information is collected, used, and disclosed by Student Portal.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'INFORMATION WE COLLECT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'We collect information you provide directly to us, such as when you create an account, update your profile, use interactive features, or access services. This may include your name, email, profile picture, academic information, course schedules, and attendance records.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'HOW WE USE YOUR INFORMATION',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'We use the information we collect to provide, maintain, and improve our services, including to track your academic progress, manage your schedule, and personalize your experience.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'DATA STORAGE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'All your data is stored locally on your device. We do not collect or transmit your information to external servers. Your data is only accessible to you through this app.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'CHANGES TO THIS POLICY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'We may modify this Privacy Policy from time to time. When we make changes, we will notify you by updating the effective date at the top of this policy.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showEndSemesterConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm End Semester'),
        content: Text(
          'Are you sure you want to clear all courses and deadlines to start a new semester?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('END SEMESTER', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<CourseProvider>(context, listen: false).clearAllCourses(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All courses and deadlines cleared'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Helper function to handle min of two integers
int min(int a, int b) {
  return a < b ? a : b;
}