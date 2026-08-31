import 'package:flutter/material.dart';
import 'package:github_repo_explorer/providers/favourites_provider.dart';
import 'package:github_repo_explorer/providers/search_provider.dart';
import 'package:github_repo_explorer/screens/home_screen.dart';
import 'package:github_repo_explorer/services/github_api_service.dart';
import 'package:github_repo_explorer/services/local_storage_service.dart';
import 'package:github_repo_explorer/theme.dart';
import 'package:provider/provider.dart';

void main() {
  final githubApiService = GithubApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SearchProvider(
            apiService: githubApiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FavouritesProvider(
            LocalStorageService(),
          )..loadFavourites(),
        ),
      ],
      child: const GithubRepoExplorerApp(),
    ),
  );
}

class GithubRepoExplorerApp extends StatelessWidget {
  const GithubRepoExplorerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Repo Explorer',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
