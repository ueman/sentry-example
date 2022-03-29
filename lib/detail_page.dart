import 'dart:async';

import 'package:example/github/comment.dart';
import 'package:example/github/github_service.dart';
import 'package:example/github/issue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.issue}) : super(key: key);

  final Issue issue;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final log = Logger((DetailPage).toString());
  final GitHubService service = GitHubService();
  List<Comment>? comments;

  @override
  void initState() {
    super.initState();
    unawaited(load());
  }

  Future<void> load() async {
    final comments = await service.getComments(widget.issue);
    log.info('loaded comments');
    setState(() {
      this.comments = comments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = this.comments;
    return Scaffold(
      appBar: AppBar(title: Text(widget.issue.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MarkdownBody(
              data: widget.issue.body ?? '',
              shrinkWrap: true,
            ),
            const Divider(),
            if (comments == null) const CircularProgressIndicator(),
            if (comments != null && comments.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    title: Text(comment.user.login),
                    subtitle: Text(comment.body),
                  );
                },
              ),
            if (comments != null && comments.isEmpty)
              const ListTile(title: Text('No comments yet')),
          ],
        ),
      ),
    );
  }
}
