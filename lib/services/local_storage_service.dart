import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/repository.dart';

class LocalStorageService {
  static const String _favouritesKey = 'favourite_repositories';
  static const String _lastSearchKey = 'last_search_results';

  Future<void> saveFavourites(
    List<Repository> repositories,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    final data = repositories
        .map((repository) => repository.toJson())
        .toList();

    await preferences.setString(
      _favouritesKey,
      jsonEncode(data),
    );
  }

  Future<List<Repository>> loadFavourites() async {
    final preferences = await SharedPreferences.getInstance();

    final storedData = preferences.getString(_favouritesKey);

    if (storedData == null) {
      return [];
    }

    final decoded = jsonDecode(storedData) as List<dynamic>;

    return decoded
        .map(
          (item) => Repository.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> saveLastSearchResults(
  List<Repository> repositories,
    ) async {
      final preferences = await SharedPreferences.getInstance();

      final data = repositories
          .map((repository) => repository.toJson())
          .toList();

      await preferences.setString(
        _lastSearchKey,
        jsonEncode(data),
      );
    }

  Future<List<Repository>> loadLastSearchResults() async {
    final preferences = await SharedPreferences.getInstance();

    final storedData = preferences.getString(_lastSearchKey);

    if (storedData == null) {
      return [];
    }

    final decoded = jsonDecode(storedData) as List<dynamic>;

    return decoded
        .map(
          (item) => Repository.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}