import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_repo_explorer/services/github_api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  test('searchRepositories returns repositories from API response', () async {
    final dio = MockDio();

    when(
      () => dio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        data: {
          'items': [
            {
              'id': 1,
              'name': 'flutter',
              'full_name': 'flutter/flutter',
              'description': 'Flutter framework',
              'stargazers_count': 100000,
              'forks_count': 20000,
              'language': 'Dart',
              'html_url': 'https://github.com/flutter/flutter',
              'updated_at': '2026-08-30T10:00:00Z',
              'owner': {
                'login': 'flutter',
                'avatar_url': 'https://example.com/avatar.png',
              },
              'license': {
                'name': 'BSD-3-Clause',
              },
            },
          ],
        },
        statusCode: 200,
      ),
    );

    final service = GithubApiService(dio: dio);

    final repositories = await service.searchRepositories(
      query: 'flutter',
    );

    expect(repositories.length, 1);
    expect(repositories.first.name, 'flutter');
    expect(repositories.first.ownerLogin, 'flutter');
    expect(repositories.first.stars, 100000);
  });
}