import '../exceptions/task_exceptions.dart';
import 'task_priority.dart';

abstract class TaskInterface {
  String get id;
  String get title;
  TaskPriority get priority;
  DateTime? get dueDate;
  bool get isCompleted;
  DateTime get createdAt;

  void markCompleted();
  Map<String, dynamic> toJson();
}

abstract class Task extends TaskInterface {
  @override
  final String id;
  @override
  final String title;
  @override
  final TaskPriority priority;
  @override
  final DateTime? dueDate;
  @override
  bool isCompleted;
  @override
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  void markCompleted() {
    if (isCompleted) {
      throw TaskAlreadyCompletedException(id);
    }
    isCompleted = true;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final priority = TaskPriority.fromString(json['priority'] ?? 'medium');
    final dueDate = json['dueDate'] != null 
        ? DateTime.parse(json['dueDate']) 
        : null;
    final createdAt = DateTime.parse(json['createdAt']);

    return TaskImpl(
      id: json['id'],
      title: json['title'],
      priority: priority,
      dueDate: dueDate,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: createdAt,
    );
  }
}

// Concrete implementation of Task
class TaskImpl extends Task {
  TaskImpl({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isCompleted = false,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.toString(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'type': 'Task',
    };
  }
}