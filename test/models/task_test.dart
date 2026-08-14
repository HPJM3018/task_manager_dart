import 'package:test/test.dart';

import 'package:task_manager/exceptions/task_exceptions.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/task_priority.dart';

void main() {
  group('Task Creation Tests', () {
    test('Should create a task with valid data', () {
      final task = TaskImpl(
        id: 'T001',
        title: 'Test Task',
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 8, 15),
      );

      expect(task.id, equals('T001'));
      expect(task.title, equals('Test Task'));
      expect(task.priority, equals(TaskPriority.high));
      expect(task.dueDate, isNotNull);
      expect(task.isCompleted, isFalse);
    });
  });

  group('Task Completion Tests', () {
    test('Should mark task as completed', () {
      final task = TaskImpl(
        id: 'T002',
        title: 'Complete Me',
        priority: TaskPriority.low,
      );

      expect(task.isCompleted, isFalse);
      task.markCompleted();
      expect(task.isCompleted, isTrue);
    });

    test('Should throw exception when completing already completed task', () {
      final task = TaskImpl(
        id: 'T003',
        title: 'Already Done',
        priority: TaskPriority.medium,
      );

      task.markCompleted();
      expect(
        () => task.markCompleted(),
        throwsA(isA<TaskAlreadyCompletedException>()),
      );
    });
  });

  group('Task JSON Serialization Tests', () {
    test('Should serialize and deserialize task correctly', () {
      final task = TaskImpl(
        id: 'T006',
        title: 'JSON Test',
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 8, 25),
      );

      final json = task.toJson();
      final deserialized = Task.fromJson(json);

      expect(deserialized.id, equals(task.id));
      expect(deserialized.title, equals(task.title));
      expect(deserialized.priority, equals(task.priority));
      expect(deserialized.dueDate?.year, equals(task.dueDate?.year));
    });
  });
}
