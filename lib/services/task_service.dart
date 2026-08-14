import 'dart:math';
import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../models/urgent_task.dart';
import '../repositories/task_repository.dart';

class TaskService {
  /// Urgency level applied when the caller does not provide one.
  static const int defaultUrgencyLevel = 5;

  /// Sort keys accepted by [listTasks].
  static const List<String> sortOptions = ['priority', 'date'];

  final TaskRepository _repository;

  TaskService(this._repository);

  Future<void> addTask({
    required String title,
    required String priority,
    DateTime? dueDate,
    bool isUrgent = false,
    int? urgencyLevel,
  }) async {
    if (title.trim().isEmpty) {
      throw InvalidTaskDataException('title', 'Title cannot be empty');
    }

    final taskPriority = TaskPriority.fromString(priority);
    final id = _generateId();

    Task task;
    if (isUrgent) {
      // Urgent tasks are always high priority; UrgentTask validates the range.
      task = UrgentTask(
        id: id,
        title: title.trim(),
        priority: TaskPriority.high,
        dueDate: dueDate,
        urgencyLevel: urgencyLevel ?? defaultUrgencyLevel,
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
    if (!sortOptions.contains(sortBy)) {
      throw InvalidTaskDataException(
        'sortBy',
        'Must be one of: ${sortOptions.join(', ')}',
      );
    }

    final tasks = await _repository.findAll();

    // Only active tasks are listed here; see listCompleted() and listAll().
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

  /// Every task, completed or not.
  Future<List<Task>> listAll() => _repository.findAll();

  /// Tasks that have already been completed.
  Future<List<Task>> listCompleted() async {
    final tasks = await _repository.findAll();
    return tasks.where((t) => t.isCompleted).toList();
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