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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Course' : 'Add Course'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveCourse,
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
                        hintText: 'e.g. Introduction to Computer Science',
                        prefixIcon: Icon(Icons.book),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter course name';
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
                        hintText: 'e.g. CS 101',
                        prefixIcon: Icon(Icons.code),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter course code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Professor
                    TextFormField(
                      controller: _professorController,
                      decoration: const InputDecoration(
                        labelText: 'Professor',
                        hintText: 'e.g. Dr. John Smith',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter professor name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Classes Held and Attended Section
                    Text(
                      'Attendance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Classes Held with text field and buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Label
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Classes Held:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        // Minus button
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            final value = int.tryParse(_classesHeldController.text) ?? 0;
                            if (value > 0) {
                              setState(() {
                                _classesHeldController.text = (value - 1).toString();
                              });
                            }
                          },
                        ),
                        // Text field
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _classesHeldController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final number = int.tryParse(value);
                              if (number == null || number < 0) {
                                return 'Invalid';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Ensure attended doesn't exceed held
                              final held = int.tryParse(value) ?? 0;
                              final attended = int.tryParse(_classesAttendedController.text) ?? 0;
                              if (attended > held) {
                                setState(() {
                                  _classesAttendedController.text = held.toString();
                                });
                              }
                            },
                          ),
                        ),
                        // Plus button
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            final value = int.tryParse(_classesHeldController.text) ?? 0;
                            setState(() {
                              _classesHeldController.text = (value + 1).toString();
                            });
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Classes Attended with text field and buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Label
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Classes Attended:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        // Minus button
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            final value = int.tryParse(_classesAttendedController.text) ?? 0;
                            if (value > 0) {
                              setState(() {
                                _classesAttendedController.text = (value - 1).toString();
                              });
                            }
                          },
                        ),
                        // Text field
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _classesAttendedController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final attended = int.tryParse(value);
                              if (attended == null || attended < 0) {
                                return 'Invalid';
                              }
                              
                              final held = int.tryParse(_classesHeldController.text) ?? 0;
                              if (attended > held) {
                                return 'Too high';
                              }
                              return null;
                            },
                          ),
                        ),
                        // Plus button
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            final attended = int.tryParse(_classesAttendedController.text) ?? 0;
                            final held = int.tryParse(_classesHeldController.text) ?? 0;
                            
                            if (attended < held) {
                              setState(() {
                                _classesAttendedController.text = (attended + 1).toString();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Class Schedules
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Class Schedules',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton.icon(
                          onPressed: _addSchedule,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Time'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    if (_schedules.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No class schedules added yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
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
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(schedule.dayName),
                              subtitle: Text('${schedule.startTime} - ${schedule.endTime} in ${schedule.room}'),
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
    );
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
  late TextEditingController _roomController;
  
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
        
    _roomController = TextEditingController(text: initialSchedule?.room ?? '');
  }
  
  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
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
        room: _roomController.text.trim(),
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
            const SizedBox(height: 16),
            
            // Room
            TextFormField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room',
                hintText: 'e.g. B-201',
                prefixIcon: Icon(Icons.room),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter room number';
                }
                return null;
              },
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