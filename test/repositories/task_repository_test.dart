import 'dart:io';

import 'package:test/test.dart';

import 'package:task_manager/exceptions/task_exceptions.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/task_priority.dart';
import 'package:task_manager/repositories/task_repository.dart';

void main() {
  group('Repository Tests', () {
    late Directory tempDir;
    late TaskRepository repository;

    setUp(() async {
      // Each test gets its own directory so suites can run in parallel.
      tempDir = await Directory.systemTemp.createTemp('task_repository_test_');
      repository = TaskRepository(
        filePath: '${tempDir.path}${Platform.pathSeparator}tasks.json',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
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
      await expectLater(
        repository.delete('NONEXISTENT'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });
  });
}
