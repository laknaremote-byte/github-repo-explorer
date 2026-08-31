class Issue {
  const Issue({
    required this.id,
    required this.title,
    required this.authorLogin,
    required this.authorAvatarUrl,
    required this.labels,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String authorLogin;
  final String authorAvatarUrl;
  final List<String> labels;
  final DateTime updatedAt;

  factory Issue.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    final labelsJson = json['labels'] as List<dynamic>? ?? [];

    return Issue(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      authorLogin: user?['login'] as String? ?? 'Unknown',
      authorAvatarUrl: user?['avatar_url'] as String? ?? '',
      labels: labelsJson
          .map(
            (label) =>
                (label as Map<String, dynamic>)['name'] as String? ?? '',
          )
          .where((label) => label.isNotEmpty)
          .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}