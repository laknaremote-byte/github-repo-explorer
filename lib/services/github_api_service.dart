import 'package:dio/dio.dart';

import '../models/repository.dart';

class GithubApiService {
  GithubApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _baseUrl = 'https://api.github.com';

  Future<List<Repository>> searchRepositories({
    required String query,
    int page = 1,
    int perPage = 10,
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
}