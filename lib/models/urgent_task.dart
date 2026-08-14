import '../exceptions/task_exceptions.dart';
import 'task.dart';
import 'task_priority.dart';

class UrgentTask extends Task {
  final int urgencyLevel;

  UrgentTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isCompleted = false,
    super.createdAt,
    required this.urgencyLevel,
  }) {
    if (urgencyLevel < 1 || urgencyLevel > 10) {
      throw InvalidTaskDataException(
        'urgencyLevel', 
        'Must be between 1 and 10'
      );
    }
  }

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'],
      title: json['title'],
      priority: TaskPriority.fromString(json['priority'] ?? 'high'),
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : null,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      urgencyLevel: json['urgencyLevel'] ?? 5,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.toString(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'type': 'UrgentTask',
      'urgencyLevel': urgencyLevel,
    };
  }

  @override
  String toString() {
    return ' URGENT (Level $urgencyLevel): $title';
  }
}