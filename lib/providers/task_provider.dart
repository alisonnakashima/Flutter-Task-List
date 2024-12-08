import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_list_app/screens/welcome_screen.dart';
import 'package:task_list_app/services/api_service.dart';
import 'package:task_list_app/services/local_storage_service.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  final localStorageService = LocalStorageService();
  final apiService = ApiService();
  bool _isDarkTheme = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isDarkTheme => _isDarkTheme;

  bool _isLoading = false; // Indica se está carregando tarefas
  bool get isLoading => _isLoading; // Getter para acesso externo

  void addTask(String title, String description) async {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      description: description,
    );
    _tasks.add(newTask);
    localStorageService.saveTasks(_tasks.map((task) => task.toJson()).toList());
    try {
      await ApiService().addTask(newTask); // Envia para a API
    } catch (e) {
      print('Erro ao sincronizar com a API: $e');
    }
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    final savedTasks;
    try {
      savedTasks = await ApiService().fetchTasks();
      print(savedTasks);
      _tasks.clear(); // Para garantir que a lista seja limpa antes de carregar
      _tasks.addAll(savedTasks);
    } catch (e) {
      print('Erro de sincronização com a API: $e');
      print('Carregando dados da memória interna');
      final savedTasks = await localStorageService.loadTasks();
      _tasks.clear(); // Para garantir que a lista seja limpa antes de carregar
      _tasks.addAll(savedTasks.map((taskJson) => Task.fromJson(taskJson)));
      print(savedTasks);
    }
    _isLoading = false;
    notifyListeners();
  }

  void deleteTask(int id) async {

    try {
      await ApiService().deleteTask(id); // Envia para a API
    } catch (e) {
      print('Erro de sincronização com a API: $e');
    }
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void toggleTaskCompletion(int id) async {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.toggleCompletion();
    try {
      await ApiService().updateTask(task); // Envia para a API
    } catch (e) {
      print('Erro na atualização com a API: $e');
    }

    notifyListeners();
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  Future<void> logout(context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao executar o logout: $e')),
      );
    }
    FirebaseAuth.instance.signOut();
  }
}
