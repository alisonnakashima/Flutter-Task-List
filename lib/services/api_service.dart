import 'package:dio/dio.dart';
import '../models/task.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      // baseUrl: 'https://flutter-task-list.free.beeceptor.com',
      baseUrl: 'https://mpb25628e1e09afd24fd.free.beeceptor.com', //teste 2
    ),
  );

  Future<List<Task>> fetchTasks() async {
    try {
      final response = await _dio.get('/tasks');
      if (response.statusCode == 200) {
        final List tasksJson = response.data;
        print(response);
        return tasksJson.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar tarefas');
      }
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: $e');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final response = await _dio.post('/tasks', data: task.toJson());
      print('Resposta do servidor: ${response.data}');
    } catch (e) {
      throw Exception('Erro ao adicionar tarefa: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _dio.delete('/tasks/$id');
    } catch (e) {
      throw Exception('Erro ao deletar tarefa: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _dio.put('/tasks/${task.id}', data: task.toJson());
    } catch (e) {
      throw Exception('Erro ao atualizar tarefa: $e');
    }
  }
}
