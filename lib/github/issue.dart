class Issue {
  Issue({
    required this.url,
    required this.repositoryUrl,
    required this.labelsUrl,
    required this.commentsUrl,
    required this.number,
    required this.title,
    required this.state,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
    required this.body,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      url: json['url'],
      repositoryUrl: json['repository_url'],
      labelsUrl: json['labels_url'],
      commentsUrl: json['comments_url'],
      number: json['number'],
      title: json['title'],
      state: json['state'],
      comments: json['comments'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      body: json['body'],
    );
  }

  final String url;
  final String? repositoryUrl;
  final String? labelsUrl;
  final String? commentsUrl;
  final int number;
  final String title;
  final String? state;
  final int comments;
  final String createdAt;
  final String? updatedAt;
  final String? body;
}
