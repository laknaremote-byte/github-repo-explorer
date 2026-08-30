import 'package:flutter/foundation.dart';

import '../models/repository.dart';
import '../services/github_api_service.dart';

enum SearchStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
}

class SearchProvider extends ChangeNotifier {
  SearchProvider({
    required GithubApiService apiService,
  }) : _apiService = apiService;

  final GithubApiService _apiService;

  List<Repository> _repositories = [];
  String _query = '';
  SearchStatus _status = SearchStatus.idle;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMore = true;

  List<Repository> get repositories => _repositories;
  String get query => _query;
  SearchStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      _repositories = [];
      _query = '';
      _status = SearchStatus.idle;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _query = trimmedQuery;
    _currentPage = 1;
    _hasMore = true;
    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.searchRepositories(
        query: _query,
        page: _currentPage,
      );

      _repositories = results;
      _hasMore = results.length == 20;
      _status = results.isEmpty
          ? SearchStatus.empty
          : SearchStatus.loaded;
    } catch (error) {
      _status = SearchStatus.error;
      _errorMessage = 'Unable to search GitHub repositories.';
    }

    notifyListeners();
  }
}