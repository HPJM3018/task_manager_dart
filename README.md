# Task Manager CLI

A command-line task management application built in pure Dart. This application lets you efficiently manage your tasks with a priority system and data persistence.

## Features

- **Add tasks** with a title, priority (low/medium/high) and an optional due date
- **Urgent tasks** with an urgency level (1-10)
- **List tasks** sorted by priority or date
- **Mark tasks as completed**
- **Delete tasks**
- **Data persistence** in a local JSON file
- **Priority tasks** highlighted
- **Due date handling**

## Technologies Used

- **Dart** - Programming language
- **Test** - Unit testing framework

## Project Structure

```
task_manager/
├── bin/
│   └── task_manager.dart          # Main entry point
├── lib/
│   ├── models/
│   │   ├── task.dart              # Abstract Task class
│   │   ├── urgent_task.dart       # UrgentTask subclass
│   │   └── task_priority.dart     # Priority enumeration
│   ├── repositories/
│   │   ├── repository.dart        # Repository<T> interface
│   │   └── task_repository.dart   # Repository implementation
│   ├── services/
│   │   └── task_service.dart      # Business logic
│   └── exceptions/
│       └── task_exceptions.dart   # Custom exceptions
├── test/
│   └── task_manager_test.dart     # Unit tests
├── pubspec.yaml                    # Project dependencies
└── tasks.json                      # Persistence file (generated)
```

## Installation

### Prerequisites

- Dart SDK 3.0.0 or higher
- [Install Dart](https://dart.dev/get-dart)

### Installation steps

1. **Clone the project**

```bash
git clone <repo-url>
cd task_manager
```

2. **Install the dependencies**

```bash
dart pub get
```

## Usage

### Start the application

```bash
dart run bin/task_manager.dart
```

Or compile to an executable:

```bash
dart compile exe bin/task_manager.dart -o task_manager
./task_manager
```

### Available commands

| Command | Description |
|----------|-------------|
| `add` | Add a new task |
| `urgent` | Add an urgent task |
| `list` | List all tasks |
| `complete` | Mark a task as completed |
| `delete` | Delete a task |
| `help` | Show the help |
| `exit` | Quit the application |

### Usage examples

#### 1. Add a standard task

```
Enter command: add

Add New Task
------------------------------
Title: Buy groceries
Priority (low/medium/high) [medium]: high
Due date (YYYY-MM-DD) [optional]: 2026-08-20
Task added successfully!
```

#### 2. Add an urgent task

```
Enter command: urgent

Add Urgent Task
------------------------------
Title: Fix the critical bug
Priority (low/medium/high) [high]: high
Due date (YYYY-MM-DD) [optional]: 2026-08-15
Urgency level (1-10) [5]: 9
Urgent task added successfully!
```

#### 3. List the tasks

```
Enter command: list
Sort by (priority/date) [priority]: priority

Active Tasks:
  Fix the critical bug [HIGH] (Due: 2026-08-15) - URGENCY: 9/10
  Buy groceries [HIGH] (Due: 2026-08-20)
```

#### 4. Mark a task as completed

```
Enter command: complete

Complete Task
------------------------------
Active tasks:
  AB12CD - Fix the critical bug [HIGH]
  EF34GH - Buy groceries [HIGH]

Enter task ID: AB12CD
Task marked as completed!
```

#### 5. Delete a task

```
Enter command: delete

Delete Task
------------------------------
All tasks:
   AB12CD - Fix the critical bug [HIGH]
   EF34GH - Buy groceries [HIGH]

Enter task ID: EF34GH
Task deleted successfully!
```

## Architecture

- Repository Pattern
- Service Layer
- Inheritance and interfaces
- Generics
- Custom exceptions

## Tests

### Run the tests

```bash
# Run all the tests
dart test

# Run the tests with more details
dart test --verbose

# Run a specific test file
dart test test/task_manager_test.dart

# Run the tests with code coverage
dart test --coverage coverage
```

### Test coverage

The suite contains 19 tests covering:

- Task creation
- Urgent task creation and urgency level validation (1-10)
- Marking tasks as completed
- Repository operations (CRUD)
- Service integration (adding, listing, sorting, completing)
- Separation of active and completed tasks
- Input validation and rejection of unknown sort keys
- JSON serialization
- Exception handling

## Additional Documentation

- [Dart Documentation](https://dart.dev/guides)
- [Test Package](https://pub.dev/packages/test)

## License

Lady cloud