import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../themes/app_theme.dart';
import '../utils/id_generator.dart';

class AddEditCourseScreen extends StatefulWidget {
  final Course? course; // Null for new course, non-null for editing

  const AddEditCourseScreen({Key? key, this.course}) : super(key: key);

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schedules = <ClassSchedule>[];
  
  late String _id;
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _professorController;
  late TextEditingController _roomController;
  late TextEditingController _classesHeldController;
  late TextEditingController _classesAttendedController;
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data or empty values
    final course = widget.course;
    _id = course?.id ?? IdGenerator.generateId();
    _nameController = TextEditingController(text: course?.name ?? '');
    _codeController = TextEditingController(text: course?.code ?? '');
    _professorController = TextEditingController(text: course?.professor ?? '');
    _roomController = TextEditingController(text: course?.room ?? '');
    _classesHeldController = TextEditingController(text: course?.classesHeld.toString() ?? '0');
    _classesAttendedController = TextEditingController(text: course?.classesAttended.toString() ?? '0');
    
    // Add existing schedules if editing
    if (course != null) {
      _schedules.addAll(course.schedule);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _professorController.dispose();
    _roomController.dispose();
    _classesHeldController.dispose();
    _classesAttendedController.dispose();
    super.dispose();
  }
  
  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      
      // Make sure classesAttended never exceeds classesHeld
      final classesHeld = int.parse(_classesHeldController.text.trim());
      int classesAttended = int.parse(_classesAttendedController.text.trim());
      if (classesAttended > classesHeld) {
        classesAttended = classesHeld;
      }
      
      final course = Course(
        id: _id,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        professor: _professorController.text.trim(),
        room: _roomController.text.trim(),
        schedule: _schedules,
        classesHeld: classesHeld,
        classesAttended: classesAttended,
      );
      
      if (widget.course == null) {
        // Adding new course
        await courseProvider.addCourse(course);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course added successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        // Updating existing course
        await courseProvider.updateCourse(course);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _addSchedule() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddScheduleBottomSheet(
        onSave: (schedule) {
          setState(() {
            _schedules.add(schedule);
          });
        },
      ),
    );
  }
  
  void _editSchedule(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddScheduleBottomSheet(
        initialSchedule: _schedules[index],
        onSave: (schedule) {
          setState(() {
            _schedules[index] = schedule;
          });
        },
      ),
    );
  }
  
  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;
    
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges()) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text('You have unsaved changes. Do you want to discard them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Course' : 'Add Course'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Course Basic Info
                            Text(
                              'Course Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            
                            // Course Name
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Course Name',
                                hintText: 'Enter course name',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a course name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Course Code
                            TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                labelText: 'Course Code',
                                hintText: 'Enter course code',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a course code';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Professor Name
                            TextFormField(
                              controller: _professorController,
                              decoration: const InputDecoration(
                                labelText: 'Professor Name',
                                hintText: 'Enter professor name',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter professor name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Room
                            TextFormField(
                              controller: _roomController,
                              decoration: const InputDecoration(
                                labelText: 'Room',
                                hintText: 'Enter room number',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter room number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Attendance Information
                            Text(
                              'Attendance Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            
                            // Classes Held
                            TextFormField(
                              controller: _classesHeldController,
                              decoration: const InputDecoration(
                                labelText: 'Classes Held',
                                hintText: 'Enter number of classes held',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter number of classes held';
                                }
                                final number = int.tryParse(value);
                                if (number == null || number < 0) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Classes Attended
                            TextFormField(
                              controller: _classesAttendedController,
                              decoration: const InputDecoration(
                                labelText: 'Classes Attended',
                                hintText: 'Enter number of classes attended',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter number of classes attended';
                                }
                                final number = int.tryParse(value);
                                if (number == null || number < 0) {
                                  return 'Please enter a valid number';
                                }
                                final classesHeld = int.tryParse(_classesHeldController.text) ?? 0;
                                if (number > classesHeld) {
                                  return 'Classes attended cannot exceed classes held';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Schedule Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Class Schedule',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                TextButton.icon(
                                  onPressed: _addSchedule,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Schedule'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Schedule List
                            if (_schedules.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'No schedules added yet',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _schedules.length,
                                itemBuilder: (context, index) {
                                  final schedule = _schedules[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(
                                        '${_getDayName(schedule.day)} ${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _editSchedule(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => _removeSchedule(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveCourse,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Course'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool _hasUnsavedChanges() {
    if (widget.course == null) {
      // For new course, check if any field is filled
      return _nameController.text.isNotEmpty ||
          _codeController.text.isNotEmpty ||
          _professorController.text.isNotEmpty ||
          _roomController.text.isNotEmpty ||
          _classesHeldController.text != '0' ||
          _classesAttendedController.text != '0' ||
          _schedules.isNotEmpty;
    } else {
      // For editing, check if any field is different from original
      return _nameController.text != widget.course!.name ||
          _codeController.text != widget.course!.code ||
          _professorController.text != widget.course!.professor ||
          _roomController.text != widget.course!.room ||
          _classesHeldController.text != widget.course!.classesHeld.toString() ||
          _classesAttendedController.text != widget.course!.classesAttended.toString() ||
          !_areSchedulesEqual(_schedules, widget.course!.schedule);
    }
  }

  bool _areSchedulesEqual(List<ClassSchedule> a, List<ClassSchedule> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].day != b[i].day ||
          a[i].startTime != b[i].startTime ||
          a[i].endTime != b[i].endTime ||
          a[i].room != b[i].room) {
        return false;
      }
    }
    return true;
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  String _formatTime(String timeString) {
    // The time is already in the correct format from the model
    return timeString;
  }
}

class AddScheduleBottomSheet extends StatefulWidget {
  final ClassSchedule? initialSchedule;
  final Function(ClassSchedule) onSave;

  const AddScheduleBottomSheet({
    Key? key,
    this.initialSchedule,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddScheduleBottomSheet> createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<AddScheduleBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late int _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  
  @override
  void initState() {
    super.initState();
    
    final initialSchedule = widget.initialSchedule;
    _selectedDay = initialSchedule?.day ?? 1; // Default to Monday
    
    // Parse time strings or set defaults
    _startTime = initialSchedule != null
        ? _parseTimeString(initialSchedule.startTime)
        : const TimeOfDay(hour: 9, minute: 0);
        
    _endTime = initialSchedule != null
        ? _parseTimeString(initialSchedule.endTime)
        : const TimeOfDay(hour: 10, minute: 30);
  }
  
  TimeOfDay _parseTimeString(String timeString) {
    // Expected format: '10:00 AM', '2:30 PM', etc.
    final parts = timeString.split(' ');
    final timeParts = parts[0].split(':');
    
    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);
    
    // Convert to 24-hour format
    if (parts[1] == 'PM' && hour < 12) {
      hour += 12;
    } else if (parts[1] == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return TimeOfDay(hour: hour, minute: minute);
  }
  
  String _formatTimeOfDay(TimeOfDay time) {
    // Convert 24-hour to 12-hour format with AM/PM
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
  
  Future<void> _selectTime(bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
          
          // If end time is earlier than start time, update it
          if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }
  
  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }
  
  void _save() {
    if (_formKey.currentState!.validate()) {
      final schedule = ClassSchedule(
        day: _selectedDay,
        startTime: _formatTimeOfDay(_startTime),
        endTime: _formatTimeOfDay(_endTime),
      );
      
      widget.onSave(schedule);
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Class Schedule',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Day Selector
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Day of Week',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              value: _selectedDay,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Monday')),
                DropdownMenuItem(value: 2, child: Text('Tuesday')),
                DropdownMenuItem(value: 3, child: Text('Wednesday')),
                DropdownMenuItem(value: 4, child: Text('Thursday')),
                DropdownMenuItem(value: 5, child: Text('Friday')),
                DropdownMenuItem(value: 6, child: Text('Saturday')),
                DropdownMenuItem(value: 7, child: Text('Sunday')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDay = value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a day';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Start Time
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(true),
                    controller: TextEditingController(text: _formatTimeOfDay(_startTime)),
                  ),
                ),
                const SizedBox(width: 16),
                
                // End Time
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(false),
                    controller: TextEditingController(text: _formatTimeOfDay(_endTime)),
                    validator: (value) {
                      if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
                        return 'End time must be after start time';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 