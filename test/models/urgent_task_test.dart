import 'package:test/test.dart';

import 'package:task_manager/exceptions/task_exceptions.dart';
import 'package:task_manager/models/task_priority.dart';
import 'package:task_manager/models/urgent_task.dart';

void main() {
  group('Urgent Task Tests', () {
    test('Should create an urgent task with valid urgency level', () {
      final urgentTask = UrgentTask(
        id: 'U001',
        title: 'Urgent Test',
        priority: TaskPriority.high,
        urgencyLevel: 8,
      );

      expect(urgentTask, isA<UrgentTask>());
      expect(urgentTask.urgencyLevel, equals(8));
    });

    test('Should throw exception for invalid urgency level', () {
      expect(
        () => UrgentTask(
          id: 'U002',
          title: 'Invalid Urgent',
          priority: TaskPriority.high,
          urgencyLevel: 11,
        ),
        throwsA(isA<InvalidTaskDataException>()),
      );

      expect(
        () => UrgentTask(
          id: 'U003',
          title: 'Invalid Urgent',
          priority: TaskPriority.high,
          urgencyLevel: 0,
        ),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });
  });

  group('Urgent Task JSON Serialization Tests', () {
    test('Should serialize and deserialize urgent task correctly', () {
      final urgentTask = UrgentTask(
        id: 'U004',
        title: 'Urgent JSON Test',
        priority: TaskPriority.high,
        urgencyLevel: 9,
        dueDate: DateTime(2026, 8, 25),
      );

      final json = urgentTask.toJson();
      final deserialized = UrgentTask.fromJson(json);

      expect(deserialized.id, equals(urgentTask.id));
      expect(deserialized.title, equals(urgentTask.title));
      expect(deserialized.urgencyLevel, equals(urgentTask.urgencyLevel));
    });
  });
}
