// Interface for custom exceptions
abstract class TaskException implements Exception {
  String get message;
  @override
  String toString() => 'TaskException: $message';
}

class TaskNotFoundException extends TaskException {
  final String id;
  TaskNotFoundException(this.id);

  @override
  String get message => 'Task with ID "$id" not found';
}

class InvalidTaskDataException extends TaskException {
  final String field;
  final String reason;

  InvalidTaskDataException(this.field, this.reason);

  @override
  String get message => 'Invalid task data: $field - $reason';
}

class TaskPersistenceException extends TaskException {
  final String operation;
  final String details;

  TaskPersistenceException(this.operation, this.details);

  @override
  String get message => 'Failed to $operation: $details';
}

class TaskAlreadyCompletedException extends TaskException {
  final String id;

  TaskAlreadyCompletedException(this.id);

  @override
  String get message => 'Task with ID "$id" is already completed';
}