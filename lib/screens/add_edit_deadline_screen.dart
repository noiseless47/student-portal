import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/deadline.dart';
import '../providers/course_provider.dart';
import '../providers/deadline_provider.dart';
import '../themes/app_theme.dart';
import '../utils/toast_util.dart';
import '../utils/id_generator.dart';

class AddEditDeadlineScreen extends StatefulWidget {
  final Deadline? deadline; // Null for new deadline, non-null for editing

  const AddEditDeadlineScreen({Key? key, this.deadline}) : super(key: key);

  @override
  State<AddEditDeadlineScreen> createState() => _AddEditDeadlineScreenState();
}

class _AddEditDeadlineScreenState extends State<AddEditDeadlineScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _id;
  late TextEditingController _titleController;
  late String _courseId;
  late String _courseName;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late DeadlineType _type;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  
  bool _isLoading = false;
  List<Map<String, String>> _courses = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data or empty values
    final deadline = widget.deadline;
    _id = deadline?.id ?? IdGenerator.generateId();
    _titleController = TextEditingController(text: deadline?.title ?? '');
    _courseId = deadline?.courseId ?? '';
    _courseName = deadline?.courseName ?? '';
    
    if (deadline != null) {
      _dueDate = deadline.dueDate;
      _dueTime = TimeOfDay(
        hour: deadline.dueDate.hour,
        minute: deadline.dueDate.minute,
      );
    } else {
      // Default to tomorrow at noon
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _dueDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      _dueTime = const TimeOfDay(hour: 12, minute: 0);
    }
    
    _type = deadline?.type ?? DeadlineType.assignment;
    _descriptionController = TextEditingController(text: deadline?.description ?? '');
    _isCompleted = deadline?.isCompleted ?? false;
    
    // Load available courses
    _loadCourses();
  }
  
  Future<void> _loadCourses() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final courses = courseProvider.courses;
    
    setState(() {
      _courses = courses.map((course) => {
        'id': course.id,
        'name': '${course.code} - ${course.name}',
      }).toList();
      
      // If we don't have a course selected yet and there are courses available, select the first one
      if (_courseId.isEmpty && _courses.isNotEmpty) {
        _courseId = _courses[0]['id']!;
        _courseName = _courses[0]['name']!;
      }
    });
  }
  
  String _getSmartDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);
    
    if (dateDay == today) {
      return 'Today (${DateFormat('MMM dd, yyyy').format(date)})';
    } else if (dateDay == tomorrow) {
      return 'Tomorrow (${DateFormat('MMM dd, yyyy').format(date)})';
    } else if (dateDay == yesterday) {
      return 'Yesterday (${DateFormat('MMM dd, yyyy').format(date)})';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }
  
  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    
    if (pickedTime != null && pickedTime != _dueTime) {
      setState(() {
        _dueTime = pickedTime;
      });
    }
  }
  
  DateTime _combineDateAndTime() {
    return DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );
  }
  
  Future<void> _saveDeadline() async {
    if (!_formKey.currentState!.validate()) {
      ToastUtil.showError('Please fix the errors in the form');
      return;
    }
    
    if (_courseId.isEmpty) {
      ToastUtil.showError('Please select a course');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final deadlineProvider = Provider.of<DeadlineProvider>(context, listen: false);
      
      final deadline = Deadline(
        id: _id,
        title: _titleController.text.trim(),
        courseId: _courseId,
        courseName: _courseName,
        dueDate: _combineDateAndTime(),
        type: _type,
        description: _descriptionController.text.trim(),
        isCompleted: _isCompleted,
      );
      
      if (widget.deadline == null) {
        // Adding new deadline
        await deadlineProvider.addDeadline(deadline);
        if (mounted) {
          ToastUtil.showSuccess('Deadline added successfully');
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        // Updating existing deadline
        await deadlineProvider.updateDeadline(deadline);
        if (mounted) {
          ToastUtil.showSuccess('Deadline updated successfully');
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.deadline != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Deadline' : 'Add Deadline'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveDeadline,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deadline Basic Info
                    Text(
                      'Deadline Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Final Project Submission',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Course Selector
                    if (_courses.isEmpty)
                      Card(
                        color: Colors.amber.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'No courses available',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Please add at least one course before creating a deadline.',
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Course Name (manual)',
                                  hintText: 'e.g. Introduction to Computer Science',
                                  prefixIcon: Icon(Icons.school),
                                ),
                                initialValue: _courseName,
                                onChanged: (value) {
                                  setState(() {
                                    _courseName = value;
                                    _courseId = 'manual-${IdGenerator.generateId()}';
                                  });
                                },
                                validator: (value) {
                                  if ((value == null || value.trim().isEmpty) && _courseId.isEmpty) {
                                    return 'Please enter a course name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Course',
                          prefixIcon: Icon(Icons.school),
                        ),
                        value: _courses.any((c) => c['id'] == _courseId) ? _courseId : null,
                        items: _courses.map((course) {
                          return DropdownMenuItem<String>(
                            value: course['id'],
                            child: Text(course['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _courseId = value;
                              _courseName = _courses.firstWhere((c) => c['id'] == value)['name']!;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null && _courses.isNotEmpty) {
                            return 'Please select a course';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    
                    // Deadline Type
                    DropdownButtonFormField<DeadlineType>(
                      decoration: const InputDecoration(
                        labelText: 'Deadline Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: _type,
                      items: DeadlineType.values.map((type) {
                        String displayName;
                        IconData icon;
                        
                        switch (type) {
                          case DeadlineType.assignment:
                            displayName = 'Assignment';
                            icon = Icons.assignment;
                            break;
                          case DeadlineType.exam:
                            displayName = 'Exam';
                            icon = Icons.quiz;
                            break;
                          case DeadlineType.project:
                            displayName = 'Project';
                            icon = Icons.folder_special;
                            break;
                          case DeadlineType.presentation:
                            displayName = 'Presentation';
                            icon = Icons.slideshow;
                            break;
                          case DeadlineType.other:
                            displayName = 'Other';
                            icon = Icons.article;
                            break;
                        }
                        
                        return DropdownMenuItem<DeadlineType>(
                          value: type,
                          child: Row(
                            children: [
                              Icon(icon, size: 16),
                              const SizedBox(width: 8),
                              Text(displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _type = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Due Date and Time
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Due Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: _getSmartDate(_dueDate),
                            ),
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Due Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            controller: TextEditingController(
                              text: _dueTime.format(context),
                            ),
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Completion Status
                    SwitchListTile(
                      title: const Text('Mark as Completed'),
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() => _isCompleted = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 