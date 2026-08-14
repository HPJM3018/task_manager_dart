import 'dart:io';

import '../lib/exceptions/task_exceptions.dart';
import '../lib/models/task.dart';
import '../lib/models/urgent_task.dart';
import '../lib/repositories/task_repository.dart';
import '../lib/services/task_service.dart';

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
  final title = stdin.readLineSync() ?? '';
  if (title.isEmpty) {
    print(' Title cannot be empty');
    return;
  }

  stdout.write('Priority (low/medium/high) [medium]: ');
  final priority = stdin.readLineSync() ?? 'medium';

  stdout.write('Due date (YYYY-MM-DD) [optional]: ');
  final dueDateInput = stdin.readLineSync() ?? '';
  DateTime? dueDate;
  if (dueDateInput.isNotEmpty) {
    try {
      dueDate = DateTime.parse(dueDateInput);
    } catch (_) {
      print('Invalid date format. Use YYYY-MM-DD');
      return;
    }
  }

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
  final title = stdin.readLineSync() ?? '';
  if (title.isEmpty) {
    print('Title cannot be empty');
    return;
  }

  stdout.write('Priority (low/medium/high) [high]: ');
  final priority = stdin.readLineSync() ?? 'high';

  stdout.write('Due date (YYYY-MM-DD) [optional]: ');
  final dueDateInput = stdin.readLineSync() ?? '';
  DateTime? dueDate;
  if (dueDateInput.isNotEmpty) {
    try {
      dueDate = DateTime.parse(dueDateInput);
    } catch (_) {
      print('Invalid date format. Use YYYY-MM-DD');
      return;
    }
  }

  stdout.write('Urgency level (1-10) [5]: ');
  final urgencyInput = stdin.readLineSync() ?? '5';
  final isUrgent = true;

  await service.addTask(
    title: title,
    priority: priority,
    dueDate: dueDate,
    isUrgent: isUrgent,
  );
  print('Urgent task added successfully!');
}

Future<void> _listTasks(TaskService service) async {
  print('\n Task List');
  print('-' * 30);

  stdout.write('Sort by (priority/date) [priority]: ');
  final sortBy = stdin.readLineSync()?.toLowerCase() ?? 'priority';

  final tasks = await service.listTasks(sortBy: sortBy);

  if (tasks.isEmpty) {
    print('No tasks found.');
    return;
  }

  print('\nActive Tasks:');
  for (var task in tasks) {
    final status = task.isCompleted ? '' : '';
    final dueDate = task.dueDate != null 
        ? ' (Due: ${_formatDate(task.dueDate!)})' 
        : '';
    
    if (task is UrgentTask) {
      print('  $status ${task.title} [${task.priority}]$dueDate - URGENCY: ${task.urgencyLevel}/10');
    } else {
      print('  $status  ${task.title} [${task.priority}]$dueDate');
    }
  }

  // Show completed tasks too (changed from service._repository to service.repository)
  final allTasks = await service.repository.findAll();
  final completed = allTasks.where((t) => t.isCompleted).toList();
  if (completed.isNotEmpty) {
    print('\nCompleted Tasks:');
    for (var task in completed) {
      print('${task.title} [${task.priority}]');
    }
  }
}

Future<void> _completeTask(TaskService service) async {
  print('\n Complete Task');
  print('-' * 30);

  // Changed from service._repository to service.repository
  final tasks = await service.repository.findAll();
  final activeTasks = tasks.where((t) => !t.isCompleted).toList();

  if (activeTasks.isEmpty) {
    print('No active tasks to complete.');
    return;
  }

  print('Active tasks:');
  for (var task in activeTasks) {
    print('  ${task.id} - ${task.title} [${task.priority}]');
  }

  stdout.write('\nEnter task ID: ');
  final id = stdin.readLineSync() ?? '';
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

  // Changed from service._repository to service.repository
  final tasks = await service.repository.findAll();

  if (tasks.isEmpty) {
    print('No tasks to delete.');
    return;
  }

  print('All tasks:');
  for (var task in tasks) {
    final status = task.isCompleted ? '' : ' ';
    print('  $status ${task.id} - ${task.title} [${task.priority}]');
  }

  stdout.write('\nEnter task ID: ');
  final id = stdin.readLineSync() ?? '';
  if (id.isEmpty) {
    print('Task ID cannot be empty');
    return;
  }

  await service.deleteTask(id);
  print(' Task deleted successfully!');
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