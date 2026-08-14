import 'dart:io';

import 'package:task_manager/exceptions/task_exceptions.dart';
import 'package:task_manager/models/urgent_task.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_service.dart';

void main() async {
  final repository = TaskRepository();
  final service = TaskService(repository);

  print('\n TASK MANAGER CLI');
  print('=' * 50);

  while (true) {
    print('\nCommands:');
    print('  add       - Add a new task');
    print('  list      - List all tasks');
    print('  complete  - Mark a task as completed');
    print('  delete    - Delete a task');
    print('  urgent    - Add an urgent task');
    print('  help      - Show this help');
    print('  exit      - Exit the application');
    print('=' * 50);
    stdout.write('\nEnter command: ');

    final input = stdin.readLineSync()?.toLowerCase().trim() ?? '';
    if (input.isEmpty) continue;

    try {
      switch (input) {
        case 'add':
          await _addTask(service);
          break;
        case 'urgent':
          await _addUrgentTask(service);
          break;
        case 'list':
          await _listTasks(service);
          break;
        case 'complete':
          await _completeTask(service);
          break;
        case 'delete':
          await _deleteTask(service);
          break;
        case 'help':
          _showHelp();
          break;
        case 'exit':
          print('\n Goodbye!');
          return;
        default:
          print('\n Unknown command. Type "help" for available commands.');
      }
    } on TaskException catch (e) {
      print('\n Error: ${e.message}');
    } catch (e) {
      print('\n Unexpected error: $e');
    }
  }
}

Future<void> _addTask(TaskService service) async {
  print('\n Add New Task');
  print('-' * 30);

  stdout.write('Title: ');
  final title = stdin.readLineSync()?.trim() ?? '';
  if (title.isEmpty) {
    print('Title cannot be empty');
    return;
  }

  stdout.write('Priority (low/medium/high) [medium]: ');
  final priorityInput = stdin.readLineSync()?.trim() ?? '';
  final priority = priorityInput.isEmpty ? 'medium' : priorityInput;

  final dueDate = _readDueDate();
  if (dueDate == _invalidDate) return;

  await service.addTask(
    title: title,
    priority: priority,
    dueDate: dueDate,
  );
  print('Task added successfully!');
}

Future<void> _addUrgentTask(TaskService service) async {
  print('\n Add Urgent Task');
  print('-' * 30);

  stdout.write('Title: ');
  final title = stdin.readLineSync()?.trim() ?? '';
  if (title.isEmpty) {
    print('Title cannot be empty');
    return;
  }

  stdout.write('Priority (low/medium/high) [high]: ');
  final priorityInput = stdin.readLineSync()?.trim() ?? '';
  final priority = priorityInput.isEmpty ? 'high' : priorityInput;

  final dueDate = _readDueDate();
  if (dueDate == _invalidDate) return;

  stdout.write('Urgency level (1-10) [5]: ');
  final urgencyInput = stdin.readLineSync()?.trim() ?? '';
  var urgencyLevel = TaskService.defaultUrgencyLevel;
  if (urgencyInput.isNotEmpty) {
    final parsed = int.tryParse(urgencyInput);
    if (parsed == null) {
      print('Urgency level must be a whole number between 1 and 10');
      return;
    }
    urgencyLevel = parsed;
  }

  await service.addTask(
    title: title,
    priority: priority,
    dueDate: dueDate,
    isUrgent: true,
    urgencyLevel: urgencyLevel,
  );
  print('Urgent task added successfully!');
}

Future<void> _listTasks(TaskService service) async {
  print('\n Task List');
  print('-' * 30);

  stdout.write('Sort by (priority/date) [priority]: ');
  final sortInput = stdin.readLineSync()?.toLowerCase().trim() ?? '';
  final sortBy = sortInput.isEmpty ? 'priority' : sortInput;

  final tasks = await service.listTasks(sortBy: sortBy);
  final completed = await service.listCompleted();

  if (tasks.isEmpty && completed.isEmpty) {
    print('No tasks found.');
    return;
  }

  if (tasks.isEmpty) {
    print('\nNo active tasks.');
  } else {
    print('\nActive Tasks:');
    for (var task in tasks) {
      final dueDate = task.dueDate != null
          ? ' (Due: ${_formatDate(task.dueDate!)})'
          : '';

      if (task is UrgentTask) {
        print('  ${task.title} [${task.priority}]$dueDate'
            ' - URGENCY: ${task.urgencyLevel}/10');
      } else {
        print('  ${task.title} [${task.priority}]$dueDate');
      }
    }
  }

  if (completed.isNotEmpty) {
    print('\nCompleted Tasks:');
    for (var task in completed) {
      print('  ${task.title} [${task.priority}]');
    }
  }
}

Future<void> _completeTask(TaskService service) async {
  print('\n Complete Task');
  print('-' * 30);

  final activeTasks = await service.listTasks();

  if (activeTasks.isEmpty) {
    print('No active tasks to complete.');
    return;
  }

  print('Active tasks:');
  for (var task in activeTasks) {
    print('  ${task.id} - ${task.title} [${task.priority}]');
  }

  stdout.write('\nEnter task ID: ');
  final id = stdin.readLineSync()?.trim() ?? '';
  if (id.isEmpty) {
    print('Task ID cannot be empty');
    return;
  }

  await service.markCompleted(id);
  print(' Task marked as completed!');
}

Future<void> _deleteTask(TaskService service) async {
  print('\n Delete Task');
  print('-' * 30);

  final tasks = await service.listAll();

  if (tasks.isEmpty) {
    print('No tasks to delete.');
    return;
  }

  print('All tasks:');
  for (var task in tasks) {
    final status = task.isCompleted ? '[done]' : '[todo]';
    print('  $status ${task.id} - ${task.title} [${task.priority}]');
  }

  stdout.write('\nEnter task ID: ');
  final id = stdin.readLineSync()?.trim() ?? '';
  if (id.isEmpty) {
    print('Task ID cannot be empty');
    return;
  }

  await service.deleteTask(id);
  print(' Task deleted successfully!');
}

/// Sentinel returned by [_readDueDate] when the input could not be parsed.
final DateTime _invalidDate = DateTime.utc(0);

/// Prompts for an optional due date. Returns null when left blank and
/// [_invalidDate] when the input is not a valid date.
DateTime? _readDueDate() {
  stdout.write('Due date (YYYY-MM-DD) [optional]: ');
  final dueDateInput = stdin.readLineSync()?.trim() ?? '';
  if (dueDateInput.isEmpty) return null;

  try {
    return DateTime.parse(dueDateInput);
  } catch (_) {
    print('Invalid date format. Use YYYY-MM-DD');
    return _invalidDate;
  }
}

void _showHelp() {
  print('\n Help');
  print('=' * 50);
  print('''
  add       - Add a new task with title, priority, and optional due date
  urgent    - Add a high-priority urgent task with urgency level
  list      - List all active tasks sorted by priority or date
  complete  - Mark a task as completed using its ID
  delete    - Delete a task using its ID
  help      - Show this help message
  exit      - Exit the application

Examples:
  > add
  Title: Complete project
  Priority: high
  Due date: 2026-08-15

  > urgent
  Title: Fix critical bug
  Priority: high
  Urgency level: 9
  ''');
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}