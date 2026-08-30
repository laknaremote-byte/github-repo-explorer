class Repository {
  const Repository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.ownerLogin,
    required this.ownerAvatarUrl,
    this.description,
    required this.stars,
    required this.forks,
    required this.watchers,
    required this.openIssuesCount,
    this.language,
    this.licenseName,
    required this.updatedAt,
    required this.htmlUrl,
  });

  final int id;
  final String name;
  final String fullName;
  final String ownerLogin;
  final String ownerAvatarUrl;
  final String? description;
  final int stars;
  final int forks;
  final int watchers;
  final int openIssuesCount;
  final String? language;
  final String? licenseName;
  final DateTime updatedAt;
  final String htmlUrl;

  factory Repository.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;

    final license = json['license'] as Map<String, dynamic>?;

    return Repository(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      ownerLogin: owner?['login'] as String? ?? '',
      ownerAvatarUrl: owner?['avatar_url'] as String? ?? '',
      description: json['description'] as String?,
      stars: json['stargazers_count'] as int? ?? 0,
      forks: json['forks_count'] as int? ?? 0,
      watchers: json['watchers_count'] as int? ?? 0,
      openIssuesCount: json['open_issues_count'] as int? ?? 0,
      language: json['language'] as String?,
      licenseName: license?['spdx_id'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      htmlUrl: json['html_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'owner': {
        'login': ownerLogin,
        'avatar_url': ownerAvatarUrl,
      },
      'description': description,
      'stargazers_count': stars,
      'forks_count': forks,
      'watchers_count': watchers,
      'open_issues_count': openIssuesCount,
      'language': language,
      'license': licenseName == null
          ? null
          : {
              'spdx_id': licenseName,
            },
      'updated_at': updatedAt.toIso8601String(),
      'html_url': htmlUrl,
    };
  }
}