import 'dart:io';
import 'package:test/test.dart';
import '../lib/exceptions/task_exceptions.dart';
import '../lib/models/task.dart';
import '../lib/models/task_priority.dart';
import '../lib/models/urgent_task.dart';
import '../lib/repositories/task_repository.dart';
import '../lib/services/task_service.dart';

void main() {
  // Test 1: Task Creation
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

  // Test 2: Urgent Task Creation
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

  group('Repository Tests', () {
    late TaskRepository repository;
    final testFile = 'test_tasks.json';

    setUp(() async {
      // Use a test file
      repository = TaskRepository(filePath: testFile);
      // Clean up before each test
      final file = File(testFile);
      if (await file.exists()) {
        await file.delete();
      }
    });

    tearDown(() async {
      // Clean up after each test
      final file = File(testFile);
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('Should save and find a task', () async {
      final task = TaskImpl(
        id: 'T004',
        title: 'Repository Test',
        priority: TaskPriority.medium,
      );

      await repository.save(task);
      final found = await repository.findById('T004');
      expect(found, isNotNull);
      expect(found!.id, equals('T004'));
      expect(found.title, equals('Repository Test'));
    });

    test('Should delete a task', () async {
      final task = TaskImpl(
        id: 'T005',
        title: 'Delete Me',
        priority: TaskPriority.low,
      );

      await repository.save(task);
      await repository.delete('T005');
      final found = await repository.findById('T005');
      expect(found, isNull);
    });

    test('Should throw exception when deleting non-existent task', () async {
      expect(
        () => repository.delete('NONEXISTENT'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });
  });

  // Test 5: Service Integration
  group('Task Service Tests', () {
    late TaskService service;
    late TaskRepository repository;
    final testFile = 'test_tasks_service.json';

    setUp(() async {
      repository = TaskRepository(filePath: testFile);
      service = TaskService(repository);
      final file = File(testFile);
      if (await file.exists()) {
        await file.delete();
      }
    });

    tearDown(() async {
      final file = File(testFile);
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('Should add and list tasks', () async {
      await service.addTask(
        title: 'Integration Test',
        priority: 'high',
        dueDate: DateTime(2026, 8, 20),
      );

      final tasks = await service.listTasks();
      expect(tasks.length, equals(1));
      expect(tasks[0].title, equals('Integration Test'));
    });

    test('Should handle invalid title', () async {
      await expectLater(
        service.addTask(
          title: '',
          priority: 'medium',
        ),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });

    test('Should add urgent task', () async {
      await service.addTask(
        title: 'Urgent Service Test',
        priority: 'high',
        isUrgent: true,
      );

      final tasks = await service.listTasks();
      expect(tasks.length, equals(1));
      expect(tasks[0], isA<UrgentTask>());
    });

    test('Should mark task as completed', () async {
      await service.addTask(
        title: 'Complete Service Test',
        priority: 'low',
      );

      final tasks = await service.listTasks();
      expect(tasks.length, equals(1));

      final task = tasks[0];
      await service.markCompleted(task.id);

      final updated = await repository.findById(task.id);
      expect(updated!.isCompleted, isTrue);
    });
  });

  // Test 6: JSON Serialization
  group('JSON Serialization Tests', () {
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