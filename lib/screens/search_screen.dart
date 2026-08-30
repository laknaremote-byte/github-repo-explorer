import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';
import '../widgets/repository_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    context.read<SearchProvider>().search(
          _searchController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repo Explorer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search repositories',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, child) {
                switch (provider.status) {
                  case SearchStatus.idle:
                    return const Center(
                      child: Text('Search for a GitHub repository'),
                    );

                  case SearchStatus.loading:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );

                  case SearchStatus.empty:
                    return const Center(
                      child: Text('No repositories found'),
                    );

                  case SearchStatus.error:
                    return Center(
                      child: Text(
                        provider.errorMessage ??
                            'Something went wrong.',
                      ),
                    );

                  case SearchStatus.loaded:
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      itemCount: provider.repositories.length,
                      itemBuilder: (context, index) {
                        return RepositoryCard(
                          repository: provider.repositories[index],
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}