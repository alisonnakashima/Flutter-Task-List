import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar tarefas ao iniciar
    LoadTasks();
  }

  Future<void> LoadTasks() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {

    const platform = MethodChannel('battery');

    final theme = Theme.of(context);

    final taskProvider = Provider.of<TaskProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Tarefas'),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.battery_unknown
              ),
              onPressed: (){
                taskProvider.getBatteryLevel(context);
              }
            ),
            IconButton(
              icon: Icon(
                taskProvider.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
              ),
              onPressed: taskProvider.toggleTheme,
            ),
            IconButton(
              icon: const Icon(
                Icons.logout
              ),
              onPressed: (){
                Provider.of<TaskProvider>(context, listen: false).logout(context);
              },
            )
          ],
        ),
        body: taskProvider.isLoading ? const Center(
          child: CircularProgressIndicator(), // Exibe indicador de carregamento
        )
        : RefreshIndicator(
          onRefresh: LoadTasks, // Função de carregamento ao arrastar
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              if (taskProvider.tasks.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Nenhuma tarefa adicionada. Adicione tarefas para vê-las.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskProvider.tasks[index];
                  return ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(task.description),
                    trailing: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        taskProvider.toggleTaskCompletion(task.id);
                      },
                    ),
                    onLongPress: () {
                      taskProvider.deleteTask(task.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tarefa removida')),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddTaskScreen(),
                ),
            );
          },
          label: Text('Adicionar'), // Texto do botão
          icon: Icon(Icons.add),    // Ícone do botão
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,// Cor de fundo
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Localização do FAB

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: theme.appBarTheme.backgroundColor,
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (context) => const AddTaskScreen(),
      //       ),
      //     );
      //   },
      //   child: Icon(
      //     Icons.add,
      //     color: theme.appBarTheme.foregroundColor,
      //   ),
      // ),
      ),
    );
  }
}
