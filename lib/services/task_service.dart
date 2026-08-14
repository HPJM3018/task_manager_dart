import 'dart:math';
import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../models/urgent_task.dart';
import '../repositories/task_repository.dart';

class TaskService {
  final TaskRepository _repository;

  // Ajoutez ce getter public
  TaskRepository get repository => _repository;

  TaskService(this._repository);

  Future<void> addTask({
    required String title,
    required String priority,
    DateTime? dueDate,
    bool isUrgent = false,
  }) async {
    if (title.trim().isEmpty) {
      throw InvalidTaskDataException('title', 'Title cannot be empty');
    }

    final taskPriority = TaskPriority.fromString(priority);
    final id = _generateId();

    Task task;
    if (isUrgent) {
      // Urgent tasks are always high priority
      task = UrgentTask(
        id: id,
        title: title.trim(),
        priority: TaskPriority.high,
        dueDate: dueDate,
        urgencyLevel: taskPriority.priorityLevel + 5,
      );
    } else {
      task = TaskImpl(
        id: id,
        title: title.trim(),
        priority: taskPriority,
        dueDate: dueDate,
      );
    }

    await _repository.save(task);
  }

  Future<List<Task>> listTasks({String sortBy = 'priority'}) async {
    final tasks = await _repository.findAll();
    
    // Filter out completed tasks by default, but show all if requested
    final activeTasks = tasks.where((t) => !t.isCompleted).toList();
    
    if (sortBy == 'priority') {
      activeTasks.sort((a, b) {
        // Urgent tasks come first
        if (a is UrgentTask && b is! UrgentTask) return -1;
        if (b is UrgentTask && a is! UrgentTask) return 1;
        if (a is UrgentTask && b is UrgentTask) {
          return b.urgencyLevel.compareTo(a.urgencyLevel);
        }
        // Sort by priority level
        final priorityCompare = b.priority.priorityLevel.compareTo(a.priority.priorityLevel);
        if (priorityCompare != 0) return priorityCompare;
        // Then by due date
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        return 0;
      });
    } else if (sortBy == 'date') {
      activeTasks.sort((a, b) {
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        return 0;
      });
    }

    return activeTasks;
  }

  Future<void> markCompleted(String id) async {
    final task = await _repository.findById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }
    task.markCompleted();
    await _repository.save(task);
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
  }

  String _generateId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
}