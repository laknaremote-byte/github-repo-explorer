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
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _search() {
    context.read<SearchProvider>().search(
          _searchController.text,
        );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<SearchProvider>().loadMore();
    }
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Search GitHub repositories',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );

                  case SearchStatus.loading:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );

                  case SearchStatus.empty:
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No repositories found',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );

                  case SearchStatus.error:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage ?? 'Something went wrong',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              provider.search(provider.query);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );

                  case SearchStatus.loaded:
                    return Column(
                      children: [
                        if (provider.isOffline)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: const Text(
                              'You are offline. Showing cached results.',
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            // Load the next page before reaching the end.
                            itemCount: provider.repositories.length +
                                (provider.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == provider.repositories.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final repository = provider.repositories[index];

                              return RepositoryCard(
                                repository: repository,
                              );
                            },
                          ),
                        ),
                      ],
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