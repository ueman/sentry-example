import 'dart:convert';
import 'dart:typed_data';

import 'package:example/github/comment.dart';
import 'package:example/github/issue.dart';
import 'package:http/http.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Service to load issues + comments from Sentry
class GitHubService {
  /// SentryHttpClient adds support for tracing the duration of the request,
  /// as well as setting the span status from the http code.
  /// If the backend also uses Sentry, this connects performance traces
  /// from the backend with the app.
  /// This also adds web requests as breadcrumbs.
  /// Any request with `failedRequestStatusCodes` will be reported
  /// with the request data itself.
  ///
  /// For Dio support see https://pub.dev/packages/sentry_dio
  final Client _client = SentryHttpClient(
    networkTracing: true,
    failedRequestStatusCodes: [SentryStatusCode.range(400, 599)],
  );

  static final _flutterRepoUrl =
      Uri.parse('https://api.github.com/repos/flutter/flutter/issues');

  Future<List<Issue>> getFlutterIssues() async {
    final response = await _client.get(_flutterRepoUrl);
    return await _deserialize(response.bodyBytes, Issue.fromJson);
  }

  Future<List<Comment>> getComments(Issue issue) async {
    final url = Uri.parse(
      'https://api.github.com/repos/flutter/flutter/issues/${issue.number}/comments',
    );
    final response = await _client.get(url);
    return await _deserialize(response.bodyBytes, Comment.fromJson);
  }

  Future<List<T>> _deserialize<T>(
    Uint8List data,
    T Function(Map<String, dynamic> e) toElement,
  ) async {
    final span = Sentry.getSpan()?.startChild('deserialization');
    List<T> list;
    try {
      final json = jsonDecode(utf8.decode(data)) as List;
      list = json.cast<Map<String, dynamic>>().map(toElement).toList();
      span?.status = const SpanStatus.ok();
    } catch (e) {
      span?.throwable = e;
      span?.status = const SpanStatus.internalError();
      rethrow;
    } finally {
      await span?.finish();
    }
    return list;
  }
}
