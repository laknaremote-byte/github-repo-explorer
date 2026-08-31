enum GithubErrorType {
  network,
  rateLimit,
  unexpected,
}

class GithubException implements Exception {
  const GithubException({
    required this.type,
    required this.message,
  });

  final GithubErrorType type;
  final String message;
}