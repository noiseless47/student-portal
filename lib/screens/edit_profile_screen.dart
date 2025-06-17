import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../themes/app_theme.dart';
import '../utils/toast_util.dart';

class EditProfileScreen extends StatefulWidget {
  final String fieldToEdit;
  
  const EditProfileScreen({
    Key? key,
    required this.fieldToEdit,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _controller;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    
    // We need to use addPostFrameCallback to access context safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeController();
    });
  }
  
  void _initializeController() {
    final userProvider = Provider.of<UserProfileProvider>(context, listen: false);
    
    switch (widget.fieldToEdit) {
      case 'name':
        _controller.text = userProvider.name;
        break;
      case 'email':
        _controller.text = userProvider.email;
        break;
      case 'university':
        _controller.text = userProvider.university;
        break;
      case 'department':
        _controller.text = userProvider.department;
        break;
      case 'academicYear':
        _controller.text = userProvider.academicYear;
        break;
      case 'studentId':
        _controller.text = userProvider.studentId;
        break;
      case 'bio':
        _controller.text = userProvider.bio;
        break;
    }
  }
  
  String _getTitle() {
    switch (widget.fieldToEdit) {
      case 'name':
        return 'Edit Full Name';
      case 'email':
        return 'Edit Email';
      case 'university':
        return 'Edit University';
      case 'department':
        return 'Edit Department';
      case 'academicYear':
        return 'Edit Academic Year';
      case 'studentId':
        return 'Edit Student ID';
      case 'bio':
        return 'Edit Bio';
      default:
        return 'Edit Profile';
    }
  }
  
  String _getLabel() {
    switch (widget.fieldToEdit) {
      case 'name':
        return 'Full Name';
      case 'email':
        return 'Email Address';
      case 'university':
        return 'University Name';
      case 'department':
        return 'Department/Major';
      case 'academicYear':
        return 'Academic Year';
      case 'studentId':
        return 'Student ID';
      case 'bio':
        return 'Bio';
      default:
        return 'Value';
    }
  }
  
  String _getHint() {
    switch (widget.fieldToEdit) {
      case 'name':
        return 'Enter your full name';
      case 'email':
        return 'Enter your email address';
      case 'university':
        return 'Enter your university name';
      case 'department':
        return 'Enter your department or major';
      case 'academicYear':
        return 'Enter your current academic year';
      case 'studentId':
        return 'Enter your student ID';
      case 'bio':
        return 'Tell us about yourself';
      default:
        return 'Enter value';
    }
  }
  
  String _getButtonText() {
    return 'Save ${widget.fieldToEdit.substring(0, 1).toUpperCase()}${widget.fieldToEdit.substring(1)}';
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _saveField() async {
    final value = _controller.text.trim();
    
    if (widget.fieldToEdit == 'name' && value.isEmpty) {
      ToastUtil.showError('Name cannot be empty');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userProvider = Provider.of<UserProfileProvider>(context, listen: false);
      
      switch (widget.fieldToEdit) {
        case 'name':
          await userProvider.updateProfile(name: value);
          break;
        case 'email':
          await userProvider.updateProfile(email: value);
          break;
        case 'university':
          await userProvider.updateProfile(university: value);
          break;
        case 'department':
          await userProvider.updateProfile(department: value);
          break;
        case 'academicYear':
          await userProvider.updateProfile(academicYear: value);
          break;
        case 'studentId':
          await userProvider.updateProfile(studentId: value);
          break;
        case 'bio':
          await userProvider.updateProfile(bio: value);
          break;
      }
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ToastUtil.showError('Error: ${e.toString()}');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.fieldToEdit == 'academicYear')
              _buildYearPicker()
            else
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: _getLabel(),
                  hintText: _getHint(),
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
                textCapitalization: widget.fieldToEdit == 'name' || 
                                    widget.fieldToEdit == 'university' || 
                                    widget.fieldToEdit == 'department'
                    ? TextCapitalization.words
                    : TextCapitalization.none,
                keyboardType: widget.fieldToEdit == 'email'
                    ? TextInputType.emailAddress
                    : widget.fieldToEdit == 'phoneNumber'
                        ? TextInputType.phone
                        : TextInputType.text,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveField,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_getButtonText()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearPicker() {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (index) => currentYear + index);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLabel(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListWheelScrollView(
            itemExtent: 50,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            children: years.map((year) {
              return Center(
                child: Text(
                  year.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
            onSelectedItemChanged: (index) {
              _controller.text = years[index].toString();
            },
          ),
        ),
      ],
    );
  }
} 