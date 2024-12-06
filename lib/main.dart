import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/welcome_screen.dart';
import 'themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(const TaskApp());
  } catch (e) {
    print('Erro ao inicializar Firebase: $e');
    // Exibe uma erro em caso de falha
  }
}


class TaskApp extends StatefulWidget {
  const TaskApp({super.key});
  @override
  State<TaskApp> createState() => _TaskAppState();
}


class _TaskAppState extends State<TaskApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: taskProvider.isDarkTheme
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            home: WelcomeScreen(),
          );
        },
      ),
    );
  }
}
