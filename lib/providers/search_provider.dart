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
  static const int _pageSize = 10;

  List<Repository> _repositories = [];
  String _query = '';
  SearchStatus _status = SearchStatus.idle;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<Repository> get repositories => _repositories;
  String get query => _query;
  SearchStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;


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
    _repositories = [];
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
      _hasMore = results.length == _pageSize;
      _status = results.isEmpty
          ? SearchStatus.empty
          : SearchStatus.loaded;
    } catch (error) {
      _status = SearchStatus.error;
      _errorMessage = 'Unable to search GitHub repositories.';
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _query.isEmpty) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;

      final results = await _apiService.searchRepositories(
        query: _query,
        page: nextPage,
      );

      _repositories.addAll(results);
      _currentPage = nextPage;
      _hasMore = results.length == _pageSize;
    } catch (error) {
      // Keep the existing results if loading the next page fails.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}