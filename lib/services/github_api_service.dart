import 'package:dio/dio.dart';
import 'package:github_repo_explorer/models/issue.dart';

import '../models/repository.dart';

class GithubApiService {
  GithubApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _baseUrl = 'https://api.github.com';

  Future<List<Repository>> searchRepositories({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/search/repositories',
      queryParameters: {
        'q': query,
        'page': page,
        'per_page': perPage,
      },
    );

    final items = response.data['items'] as List<dynamic>;

    return items
        .map(
          (item) => Repository.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<Issue>> getOpenIssues({
  required String owner,
  required String repository,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/repos/$owner/$repository/issues',
      queryParameters: {
        'state': 'open',
        'sort': 'updated',
        'per_page': 5,
      },
    );

    final items = response.data as List<dynamic>;

    return items
        .where(
          (item) => !(item as Map<String, dynamic>).containsKey('pull_request'),
        )
        .map(
          (item) => Issue.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
      }
}