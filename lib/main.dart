import 'package:flutter/material.dart';
import 'package:github_repo_explorer/screens/home_screen.dart';
import 'package:github_repo_explorer/theme.dart';

void main() {
  runApp(const GithubRepoExplorerApp());
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
