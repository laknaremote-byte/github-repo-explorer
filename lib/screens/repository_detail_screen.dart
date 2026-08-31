import 'package:flutter/material.dart';
import 'package:github_repo_explorer/models/issue.dart';
import 'package:github_repo_explorer/services/github_api_service.dart';

import '../models/repository.dart';

class RepositoryDetailScreen extends StatefulWidget {
  const RepositoryDetailScreen({
    super.key,
    required this.repository,
  });

  final Repository repository;

  @override
  State<StatefulWidget> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState
    extends State<RepositoryDetailScreen> {

  late final GithubApiService _apiService;
  late final Future<List<Issue>> _issuesFuture;

  @override
  void initState() {
    super.initState();

    _apiService = GithubApiService();

    _issuesFuture = _apiService.getOpenIssues(
      owner: widget.repository.ownerLogin,
      repository: widget.repository.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                    widget.repository.ownerAvatarUrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.repository.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                      Text(
                        '@${widget.repository.ownerLogin}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              widget.repository.description ?? 'No description available.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Text('★ ${widget.repository.stars}'),
                const SizedBox(width: 20),
                Text('Forks ${widget.repository.forks}'),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Language: ${widget.repository.language ?? 'Not specified'}',
            ),
            const SizedBox(height: 8),
            Text(
              'License: ${widget.repository.licenseName ?? 'Not specified'}',
            ),
            const SizedBox(height: 8),
            Text(
              'Updated: ${_formatDate(widget.repository.updatedAt)}',
            ),

            const SizedBox(height: 28),

            Text(
              'Open Issues',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            _buildIssuesSection()
          ],
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildIssuesSection() {
    return FutureBuilder<List<Issue>>(
      future: _issuesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Unable to load open issues.',
            ),
          );
        }

        final issues = snapshot.data ?? [];

        if (issues.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No open issues.',
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: issues
              .map(
                (issue) => _IssueCard(issue: issue),
              )
              .toList(),
        );
      },
    );
  }
    
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.issue,
  });

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '@${issue.authorLogin} · ${_relativeTime(issue.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (issue.labels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: issue.labels
                    .map(
                      (label) => Chip(
                        label: Text(label),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    }

    if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    }

    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    }

    return 'just now';
  }
}