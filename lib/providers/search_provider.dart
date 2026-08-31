import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:github_repo_explorer/services/github_exception.dart';
import 'package:github_repo_explorer/services/local_storage_service.dart';

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
    required LocalStorageService storageService
  }) : _apiService = apiService,
      _storageService = storageService;

  final GithubApiService _apiService;
  final LocalStorageService _storageService;
  final Connectivity _connectivity = Connectivity();

  static const int _pageSize = 20;

  List<Repository> _repositories = [];
  String _query = '';
  SearchStatus _status = SearchStatus.idle;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isOffline = false;

  List<Repository> get repositories => _repositories;
  String get query => _query;
  SearchStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isOffline => _isOffline;


  /// Searches repositories with a short debounce.
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
    _isOffline = false;
    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Debounce to avoid an API call for every keystroke.
    _debounceTimer = Timer(
      const Duration(milliseconds: 400),
      () => _performSearch(trimmedQuery),
    );
  }

  /// Performs the repository search and handles offline fallback.
  Future<void> _performSearch(String query) async {
    _currentPage = 1;
    _hasMore = true;

    try {
      final results = await _apiService.searchRepositories(
        query: query,
        page: _currentPage,
      );

      _repositories = results;

      // Cache only successful search results for offline use.
      await _storageService.saveLastSearchResults(results);

      _isOffline = false;
      _hasMore = results.length == _pageSize;
      _status = results.isEmpty
          ? SearchStatus.empty
          : SearchStatus.loaded;
    } on GithubException catch (error) {
        if (error.type == GithubErrorType.network) {
          // Fall back to cached results when the network is unavailable.
          final cachedResults =
              await _storageService.loadLastSearchResults();

          if (cachedResults.isNotEmpty) {
            _repositories = cachedResults;
            _isOffline = true;
            _status = SearchStatus.loaded;
          } else {
            _status = SearchStatus.error;
            _errorMessage = error.message;
          }
        } else {
          _status = SearchStatus.error;
          _errorMessage = error.message;
        }
      } catch (_) {
        _status = SearchStatus.error;
        _errorMessage = 'Something went wrong. Please try again.';
      }

    notifyListeners();
  }

  /// Loads the next page and appends it to the current results.
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

      // Append the next page to the existing results.
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

  /// Loads cached results when the app starts offline.
  Future<void> loadCachedResultsIfOffline() async {
    final connectivityResults =
        await _connectivity.checkConnectivity();

    final isOffline = connectivityResults.every(
      (result) => result == ConnectivityResult.none,
    );

    if (!isOffline) {
      return;
    }

    // Show the last successful search when starting offline.
    final cachedResults =
        await _storageService.loadLastSearchResults();

    if (cachedResults.isNotEmpty) {
      _repositories = cachedResults;
      _isOffline = true;
      _status = SearchStatus.loaded;
      notifyListeners();
    }
  }
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}