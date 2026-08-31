import 'package:dio/dio.dart';
import 'package:github_repo_explorer/models/issue.dart';
import 'package:github_repo_explorer/services/github_exception.dart';

import '../models/repository.dart';

class GithubApiService {
  GithubApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _baseUrl = 'https://api.github.com';

  /// Searches GitHub repositories with pagination support.
  Future<List<Repository>> searchRepositories({
  required String query,
  int page = 1,
  int perPage = 20,
}) async {
  try {
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
  } on DioException catch (error) {
    // Handle GitHub rate limits separately
    if (error.response?.statusCode == 403 &&
        error.response?.headers.value('x-ratelimit-remaining') == '0') {
      throw const GithubException(
        type: GithubErrorType.rateLimit,
        message: 'GitHub API rate limit reached.',
      );
    }

    // Convert connection failures into a network error.
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      throw const GithubException(
        type: GithubErrorType.network,
        message: 'Unable to connect to GitHub.',
      );
    }

    throw const GithubException(
      type: GithubErrorType.unexpected,
      message: 'Something went wrong. Please try again.',
    );
  } catch (_) {
    throw const GithubException(
      type: GithubErrorType.unexpected,
      message: 'Something went wrong. Please try again.',
    );
  }
}


  /// Loads the first five open issues for a repository.
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