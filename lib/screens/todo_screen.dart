import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deadline_provider.dart';
import '../providers/theme_provider.dart';
import '../models/deadline.dart';
import '../themes/app_theme.dart';
import '../utils/toast_util.dart';
import 'package:intl/intl.dart';
import 'add_edit_deadline_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load deadlines when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeadlineProvider>(context, listen: false).loadDeadlines();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDeadline,
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add, 
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer2<DeadlineProvider, ThemeProvider>(
      builder: (context, deadlineProvider, themeProvider, child) {
        final isDarkMode = true; // Force dark mode for this screen
        
        if (deadlineProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final upcomingDeadlines = deadlineProvider.upcomingDeadlines;
        final pastDueDeadlines = deadlineProvider.pastDueDeadlines;
        final completedDeadlines = deadlineProvider.completedDeadlines;
        
        if (upcomingDeadlines.isEmpty && pastDueDeadlines.isEmpty && completedDeadlines.isEmpty) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No to-do items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addNewDeadline,
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first task'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Container(
          color: Colors.black,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcomingDeadlines.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Upcoming', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                ...upcomingDeadlines.map((deadline) => _buildDeadlineTile(context, deadline, isDarkMode)),
              ],
              if (pastDueDeadlines.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Past Due', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                ...pastDueDeadlines.map((deadline) => _buildDeadlineTile(context, deadline, isDarkMode)),
              ],
              if (completedDeadlines.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Completed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                ...completedDeadlines.map((deadline) => _buildDeadlineTile(context, deadline, isDarkMode)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeadlineTile(BuildContext context, Deadline deadline, bool isDarkMode) {
    final provider = Provider.of<DeadlineProvider>(context, listen: false);
    final isCompleted = deadline.isCompleted;
    final typeColor = Colors.blue[200];
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFF1A1A1A), // Dark gray background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: ListTile(
          leading: GestureDetector(
            onTap: () {
              provider.toggleDeadlineCompletion(deadline.id);
              // Show Android-style Toast notification
              ToastUtil.show(
                isCompleted ? 'Task marked as incomplete' : 'Task completed'
              );
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      deadline.title.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (deadline.courseName.isNotEmpty)
                Text(
                  deadline.courseName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                'Due ${deadline.smartDate}, ${DateFormat('h:mm a').format(deadline.dueDate)}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          trailing: Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: typeColor?.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              deadline.deadlineTypeDisplay,
              style: TextStyle(
                color: Colors.blue[200],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          onTap: () => _viewDeadlineDetails(deadline),
        ),
      ),
    );
  }
} 