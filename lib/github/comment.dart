import 'package:example/github/user.dart';

class Comment {
  Comment({
    this.url,
    this.htmlUrl,
    this.issueUrl,
    this.id,
    this.nodeId,
    required this.user,
    this.createdAt,
    this.updatedAt,
    this.authorAssociation,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      url: json['url'],
      issueUrl: json['issue_url'],
      id: json['id'],
      nodeId: json['node_id'],
      user: User.fromJson(json['user']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      authorAssociation: json['author_association'],
      body: json['body'],
    );
  }

  final String? url;
  final String? htmlUrl;
  final String? issueUrl;
  final int? id;
  final String? nodeId;
  final User user;
  final String? createdAt;
  final String? updatedAt;
  final String? authorAssociation;
  final String body;
}
