import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../themes/app_theme.dart';
import '../utils/toast_util.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _navigateToEditField(BuildContext context, String fieldToEdit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(fieldToEdit: fieldToEdit),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDarkMode ? AppTheme.darkCardColor : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, userProfileProvider, _) {
          final name = userProfileProvider.name.isNotEmpty
              ? userProfileProvider.name
              : 'Student';
              
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with avatar and name
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          userProfileProvider.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit, 
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            onPressed: () => _navigateToEditField(context, 'name'),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 8),
                          ),
                        ],
                      ),
                      if (userProfileProvider.department.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            userProfileProvider.department,
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryTextColor,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ),
                      if (userProfileProvider.university.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            userProfileProvider.university,
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryTextColor,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Academic Information Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'ACADEMIC INFORMATION',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      
                      // Student ID
                      _buildProfileItem(
                        context: context,
                        title: 'Student ID',
                        value: userProfileProvider.studentId,
                        icon: Icons.badge_outlined,
                        onTap: () => _navigateToEditField(context, 'studentId'),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      
                      const Divider(height: 1, indent: 56, endIndent: 16),
                      
                      // Year of Graduation
                      _buildProfileItem(
                        context: context,
                        title: 'Year of Graduation',
                        value: userProfileProvider.academicYear,
                        icon: Icons.school_outlined,
                        onTap: () => _navigateToEditField(context, 'academicYear'),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      
                      const Divider(height: 1, indent: 56, endIndent: 16),
                      
                      // Department/Major
                      _buildProfileItem(
                        context: context,
                        title: 'Department/Major',
                        value: userProfileProvider.department,
                        icon: Icons.category_outlined,
                        onTap: () => _navigateToEditField(context, 'department'),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      
                      const Divider(height: 1, indent: 56, endIndent: 16),
                      
                      // University
                      _buildProfileItem(
                        context: context,
                        title: 'University',
                        value: userProfileProvider.university,
                        icon: Icons.account_balance_outlined,
                        onTap: () => _navigateToEditField(context, 'university'),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Contact Information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'CONTACT INFORMATION',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      
                      // Email
                      _buildProfileItem(
                        context: context,
                        title: 'Email Address',
                        value: userProfileProvider.email,
                        icon: Icons.email_outlined,
                        onTap: () => _navigateToEditField(context, 'email'),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      
                      const Divider(height: 1, indent: 56, endIndent: 16),
                      
                      // Phone Number
                      _buildProfileItem(
                        context: context,
                        title: 'Phone Number',
                        value: userProfileProvider.phoneNumber,
                        icon: Icons.phone_outlined,
                        onTap: () => _navigateToEditField(context, 'phoneNumber'),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bio Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ABOUT ME',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                              onPressed: () => _navigateToEditField(context, 'bio'),
                              tooltip: 'Edit Bio',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: userProfileProvider.bio.isNotEmpty
                            ? Text(
                                userProfileProvider.bio,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              )
                            : Text(
                                'Tap the edit button to add your bio...',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProfileItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Function onTap,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : 'Not set',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
} 