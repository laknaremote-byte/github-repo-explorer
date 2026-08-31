import 'package:flutter/foundation.dart';

import '../models/repository.dart';
import '../services/local_storage_service.dart';

class FavouritesProvider extends ChangeNotifier {
  FavouritesProvider(this._storageService);

  final LocalStorageService _storageService;

  List<Repository> _favourites = [];
  bool _isLoading = true;

  List<Repository> get favourites => List.unmodifiable(_favourites);
  bool get isLoading => _isLoading;

  /// Loads saved favourites from local storage.
  Future<void> loadFavourites() async {
    _isLoading = true;
    notifyListeners();

    _favourites = await _storageService.loadFavourites();

    _isLoading = false;
    notifyListeners();
  }

  /// Checks whether a repository is currently favourited.
  bool isFavourite(Repository repository) {
    return _favourites.any(
      (item) => item.id == repository.id,
    );
  }

  /// Adds or removes a repository from favourites.
  Future<void> toggleFavourite(Repository repository) async {
    if (isFavourite(repository)) {
      _favourites.removeWhere(
        (item) => item.id == repository.id,
      );
    } else {
      _favourites.add(repository);
    }

    notifyListeners();

    await _storageService.saveFavourites(_favourites);
  }
}