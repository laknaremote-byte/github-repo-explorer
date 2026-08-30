import 'package:flutter/material.dart';

import '../models/repository.dart';

class RepositoryCard extends StatelessWidget {
  const RepositoryCard({
    super.key,
    required this.repository,
  });

  final Repository repository;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                repository.ownerAvatarUrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repository.fullName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    repository.description ??
                        'No description available.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_border,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text('${repository.stars}'),
                      const SizedBox(width: 16),
                      if (repository.language != null) ...[
                        const SizedBox(width: 16),
                        Text(repository.language!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}