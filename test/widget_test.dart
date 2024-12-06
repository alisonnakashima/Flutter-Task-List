// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_list_app/screens/task_list_screen.dart';
import 'package:task_list_app/screens/add_task_screen.dart';
import 'package:task_list_app/providers/task_provider.dart';

void main() {
  group('TaskListScreen Widget Tests', () {
    testWidgets('Displays message when task list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TaskProvider(),
          child: const MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );

      expect(find.text('Nenhuma tarefa adicionada. Adicione tarefas para vê-las.'), findsOneWidget);
    });

    testWidgets('Adds a task and displays it in the list', (WidgetTester tester) async {
      final taskProvider = TaskProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => taskProvider,
          child: const MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );

      // Open AddTaskScreen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter task details
      await tester.enterText(find.byType(TextField).at(0), 'Test Task');
      await tester.enterText(find.byType(TextField).at(1), 'Test Description');
      await tester.tap(find.text('Save Task'));

      // Wait for the list to update
      await tester.pumpAndSettle();

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('Toggles task completion', (WidgetTester tester) async {
      final taskProvider = TaskProvider();
      taskProvider.addTask('Test Task', 'Test Description');

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => taskProvider,
          child: const MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );

      final checkbox = find.byType(Checkbox);

      // Verify initial state
      expect((tester.widget<Checkbox>(checkbox).value), false);

      // Toggle the checkbox
      await tester.tap(checkbox);
      await tester.pump();

      // Verify updated state
      expect((tester.widget<Checkbox>(checkbox).value), true);
    });
  });

  group('AddTaskScreen Widget Tests', () {
    testWidgets('Displays input fields and save button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TaskProvider(),
          child: const MaterialApp(
            home: AddTaskScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Save Task'), findsOneWidget);
    });

    testWidgets('Validates empty title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TaskProvider(),
          child: const MaterialApp(
            home: AddTaskScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Save Task'));
      await tester.pump();

      expect(find.text('Title cannot be empty'), findsOneWidget);
    });

    testWidgets('Saves a task with valid input', (WidgetTester tester) async {
      final taskProvider = TaskProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => taskProvider,
          child: const MaterialApp(
            home: AddTaskScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'Test Task');
      await tester.enterText(find.byType(TextField).at(1), 'Test Description');
      await tester.tap(find.text('Save Task'));

      await tester.pumpAndSettle();

      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].title, 'Test Task');
      expect(taskProvider.tasks[0].description, 'Test Description');
    });
  });
}
