import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import 'repository.dart';

class TaskRepository implements Repository<Task> {
  final String filePath;
  List<Task> _tasks = [];

  TaskRepository({String? filePath})
      : filePath = filePath ?? 'tasks.json';

  @override
  Future<List<Task>> findAll() async {
    await _loadTasks();
    return List.from(_tasks);
  }

  @override
  Future<Task?> findById(String id) async {
    await _loadTasks();
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Task task) async {
    await _loadTasks();
    final existingIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (existingIndex != -1) {
      _tasks[existingIndex] = task;
    } else {
      _tasks.add(task);
    }
    await _saveTasks();
  }

  @override
  Future<void> delete(String id) async {
    await _loadTasks();
    final initialLength = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);
    if (_tasks.length == initialLength) {
      throw TaskNotFoundException(id);
    }
    await _saveTasks();
  }

  @override
  Future<void> deleteAll() async {
    _tasks.clear();
    await _saveTasks();
  }

  Future<void> _loadTasks() async {
    final file = File(filePath);
    if (!await file.exists()) {
      _tasks = [];
      return;
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        _tasks = [];
        return;
      }

      final List<dynamic> jsonData = json.decode(content);
      _tasks = jsonData.map((json) {
        final type = json['type'] ?? 'Task';
        if (type == 'UrgentTask') {
          return UrgentTask.fromJson(json);
        }
        return Task.fromJson(json);
      }).toList();
    } catch (e) {
      throw TaskPersistenceException('load tasks', e.toString());
    }
  }

  Future<void> _saveTasks() async {
    try {
      final file = File(filePath);
      final jsonData = _tasks.map((task) => task.toJson()).toList();
      final content = json.encode(jsonData);
      await file.writeAsString(content);
    } catch (e) {
      throw TaskPersistenceException('save tasks', e.toString());
    }
  }
}