import 'package:flutter_test/flutter_test.dart';
import 'package:github_repo_explorer/models/repository.dart';

void main() {
  test('creates a Repository from GitHub JSON', () {
    final json = {
      'id': 123,
      'name': 'flutter',
      'full_name': 'flutter/flutter',
      'description': 'Flutter makes it easy to build beautiful apps.',
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
    };

    final repository = Repository.fromJson(json);

    expect(repository.id, 123);
    expect(repository.name, 'flutter');
    expect(repository.ownerLogin, 'flutter');
    expect(repository.stars, 100000);
    expect(repository.language, 'Dart');
  });
}