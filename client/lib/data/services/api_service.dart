import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../models/project.dart';
import '../models/project_input.dart';
import '../models/search_results.dart';
import '../models/task.dart';
import '../models/task_input.dart';
import '../models/team.dart';
import '../models/user.dart';
import '../models/enums.dart';

class ApiService {
  ApiService({Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 12),
              headers: const {'Content-Type': 'application/json'},
            ),
          );

  final Dio _client;

  Future<List<Project>> fetchProjects() async {
    try {
      final response = await _client.get<List<dynamic>>('/projects');
      return (response.data ?? [])
          .map((item) => Project.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Project> createProject(ProjectInput input) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/projects',
        data: input.toJson(),
      );
      return Project.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<Task>> fetchTasks(int projectId) async {
    try {
      final response = await _client.get<List<dynamic>>(
        '/tasks',
        queryParameters: {'projectId': projectId},
      );
      return (response.data ?? [])
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Task> createTask(TaskInput input) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/tasks',
        data: input.toJson(),
      );
      return Task.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Task> updateTaskStatus({
    required int taskId,
    required TaskStatus status,
  }) async {
    try {
      final response = await _client.patch<Map<String, dynamic>>(
        '/tasks/$taskId/status',
        data: {'status': status.label},
      );
      return Task.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<Task>> fetchTasksByUser(int userId) async {
    try {
      final response = await _client.get<List<dynamic>>('/tasks/user/$userId');
      return (response.data ?? [])
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<AppUser>> fetchUsers() async {
    try {
      final response = await _client.get<List<dynamic>>('/users');
      return (response.data ?? [])
          .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<Team>> fetchTeams() async {
    try {
      final response = await _client.get<List<dynamic>>('/teams');
      return (response.data ?? [])
          .map((item) => Team.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<SearchResults> search(String query) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/search',
        queryParameters: {'query': query},
      );
      return SearchResults.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final message = exception.response?.data is Map<String, dynamic>
        ? (exception.response?.data['message'] as String?) ??
              exception.message ??
              'Unknown error'
        : exception.message ?? 'Unknown error';
    return ApiException(message, statusCode: statusCode);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
