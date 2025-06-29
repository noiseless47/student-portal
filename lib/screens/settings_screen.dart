import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/course_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/deadline_provider.dart';
import '../themes/app_theme.dart';
import '../models/course.dart';
import '../utils/toast_util.dart';
import 'add_edit_course_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                subtitle: const Text('2.1.0'),
                trailing: const Icon(Icons.launch, size: 20),
                onTap: () => _launchUrl('https://www.asishky.me/app-updates'),
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
          
          // Developer Info
          _buildSettingsSection(
            context,
            'Developer',
            [
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.code, color: AppTheme.primaryColor),
                title: const Text('Created with ❤️ by'),
                subtitle: const Text('Asish Kumar Yeleti'),
              ),
              _buildDeveloperSocialLinks(context),
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
    
    return ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Full Name'),
          subtitle: Text(
            userProfileProvider.name.isNotEmpty 
                ? userProfileProvider.name 
                : 'Not set'
          ),
          trailing: const Icon(Icons.edit),
          onTap: () => _navigateToEditProfile(context, 'name'),
    );
  }
  
  void _navigateToEditProfile(BuildContext context, String fieldToEdit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(fieldToEdit: fieldToEdit),
      ),
    );
    
    if (result == true) {
      // Field updated successfully, show feedback to user
      ToastUtil.showSuccess('${fieldToEdit.capitalize()} updated successfully');
    }
  }
  
  Widget _buildThemeSwitcher(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'App Theme',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Light'),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (mode) {
            if (mode != null) themeProvider.setThemeMode(mode);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark'),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (mode) {
            if (mode != null) themeProvider.setThemeMode(mode);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System Default'),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (mode) {
            if (mode != null) themeProvider.setThemeMode(mode);
      },
        ),
      ],
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
              ToastUtil.showError('${course.name} deleted');
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
              ToastUtil.showError('All courses and deadlines cleared');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSocialLinks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSocialButton(
            context,
            icon: FontAwesomeIcons.linkedin,
            label: 'LinkedIn',
            url: 'https://www.linkedin.com/in/asishkumaryeleti/',
            color: const Color(0xFF0077B5),
          ),
          const SizedBox(width: 16),
          _buildSocialButton(
            context,
            icon: FontAwesomeIcons.github,
            label: 'GitHub',
            url: 'https://github.com/noiseless47',
            color: const Color(0xFF333333),
          ),
          const SizedBox(width: 16),
          _buildSocialButton(
            context,
            icon: FontAwesomeIcons.instagram,
            label: 'Instagram',
            url: 'https://www.instagram.com/asishky/',
            color: const Color(0xFFE1306C),
          ),
          const SizedBox(width: 16),
          _buildSocialButton(
            context,
            icon: FontAwesomeIcons.globe,
            label: 'Website',
            url: 'https://www.asishky.me',
            color: const Color(0xFF2C974B),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

// Helper function to handle min of two integers
int min(int a, int b) {
  return a < b ? a : b;
}

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}