enum TaskPriority {
  low,
  medium,
  high;

  @override
  String toString() => name.toUpperCase();

  int get priorityLevel {
    switch (this) {
      case TaskPriority.low:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.high:
        return 2;
    }
  }

  static TaskPriority fromString(String value) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }
}