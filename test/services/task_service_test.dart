import 'dart:io';

import 'package:test/test.dart';

import 'package:task_manager/exceptions/task_exceptions.dart';
import 'package:task_manager/models/urgent_task.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_service.dart';

void main() {
  group('Task Service Tests', () {
    late Directory tempDir;
    late TaskRepository repository;
    late TaskService service;

    setUp(() async {
      // Each test gets its own directory so suites can run in parallel.
      tempDir = await Directory.systemTemp.createTemp('task_service_test_');
      repository = TaskRepository(
        filePath: '${tempDir.path}${Platform.pathSeparator}tasks.json',
      );
      service = TaskService(repository);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
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

    test('Should keep the urgency level provided by the caller', () async {
      await service.addTask(
        title: 'Urgency Passthrough',
        priority: 'high',
        isUrgent: true,
        urgencyLevel: 9,
      );

      final tasks = await service.listTasks();
      expect(tasks.single, isA<UrgentTask>());
      expect((tasks.single as UrgentTask).urgencyLevel, equals(9));
    });

    test('Should default the urgency level when none is provided', () async {
      await service.addTask(
        title: 'Urgency Default',
        priority: 'low',
        isUrgent: true,
      );

      final tasks = await service.listTasks();
      expect(
        (tasks.single as UrgentTask).urgencyLevel,
        equals(TaskService.defaultUrgencyLevel),
      );
    });

    test('Should reject an out-of-range urgency level', () async {
      await expectLater(
        service.addTask(
          title: 'Urgency Too High',
          priority: 'high',
          isUrgent: true,
          urgencyLevel: 11,
        ),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });

    test('Should reject an unknown sort key', () async {
      await expectLater(
        service.listTasks(sortBy: 'colour'),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });

    test('Should separate completed tasks from active ones', () async {
      await service.addTask(title: 'Stays Active', priority: 'low');
      await service.addTask(title: 'Gets Completed', priority: 'low');

      final active = await service.listTasks();
      expect(active.length, equals(2));

      final target = active.firstWhere((t) => t.title == 'Gets Completed');
      await service.markCompleted(target.id);

      final remaining = await service.listTasks();
      final completed = await service.listCompleted();
      final all = await service.listAll();

      expect(remaining.single.title, equals('Stays Active'));
      expect(completed.single.title, equals('Gets Completed'));
      expect(all.length, equals(2));
    });
  });
}
