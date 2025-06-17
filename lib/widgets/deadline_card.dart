import 'package:flutter/material.dart';
import '../models/deadline.dart';
import '../themes/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class DeadlineCard extends StatelessWidget {
  final Deadline deadline;
  final VoidCallback onTap;
  final VoidCallback onToggleCompletion;
  
  const DeadlineCard({
    Key? key,
    required this.deadline,
    required this.onTap,
    required this.onToggleCompletion,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bool isCompleted = deadline.isCompleted;
    final bool isPastDue = deadline.isPastDue;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    final primaryColor = isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;
    final secondaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.secondaryColor;
    final successColor = AppTheme.successColor;
    final errorColor = isDarkMode ? AppTheme.darkErrorColor : AppTheme.errorColor;
    final warningColor = AppTheme.warningColor;
    final textSecondary = isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    
    Color _getStatusColor() {
      if (isCompleted) return successColor;
      if (isPastDue) return errorColor;
      if (deadline.daysRemaining <= 3) return warningColor;
      return secondaryColor;
    }
    
    IconData _getStatusIcon() {
      if (isCompleted) return Icons.check_circle_outline;
      if (isPastDue) return Icons.warning_amber_outlined;
      return Icons.access_time_outlined;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deadline.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          deadline.courseName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isCompleted,
                    onChanged: (_) => onToggleCompletion(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: successColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Date and Time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      deadline.deadlineTypeDisplay,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      !isCompleted && !isPastDue
                          ? '${deadline.daysRemaining} day${deadline.daysRemaining == 1 ? '' : 's'} remaining'
                          : isPastDue
                              ? 'Past due'
                              : 'Completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Date and Time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${deadline.smartDate} at ${deadline.formattedTime}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              
              if (deadline.description.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      deadline.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 