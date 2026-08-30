import 'dart:async';

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
  Timer? _debounceTimer;
  
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

  void search(String query) {
    final trimmedQuery = query.trim();

    _debounceTimer?.cancel();

    if (trimmedQuery.isEmpty) {
      _repositories = [];
      _query = '';
      _status = SearchStatus.idle;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _query = trimmedQuery;
    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _debounceTimer = Timer(
      const Duration(milliseconds: 400),
      () => _performSearch(trimmedQuery),
    );
  }

  Future<void> _performSearch(String query) async {
    _currentPage = 1;
    _hasMore = true;

    try {
      final results = await _apiService.searchRepositories(
        query: query,
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}