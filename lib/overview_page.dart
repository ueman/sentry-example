import 'dart:async';
import 'dart:convert';

import 'package:example/detail_page.dart';
import 'package:example/exceptions.dart';
import 'package:example/github/github_service.dart';
import 'package:example/github/issue.dart';
import 'package:example/user_feedback_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final log = Logger((OverviewPage).toString());
  final GitHubService service = GitHubService();
  List<Issue>? issues;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final issues = this.issues;
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset('assets/flutter.svg', height: 30),
        actions: [
          IconButton(
            onPressed: () {
              _reload();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _sendBugReport,
            icon: const Icon(Icons.bug_report),
          ),
        ],
      ),
      body: issues == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (context, index) {
                final item = issues[index];
                return ListTile(
                  title: Text(item.title),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'DetailPage'),
                      builder: (context) => DetailPage(issue: item),
                    ));
                  },
                );
              },
              itemCount: issues.length,
            ),
    );
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(seconds: 1));
    final issues = await service.getFlutterIssues();
    log.info('loaded issues');
    setState(() {
      this.issues = issues;
    });
  }

  Future<void> _reload() async {
    setState(() {
      issues = null;
    });
    final transaction = Sentry.startTransaction(
      'refresh-issues',
      'load',
      // make transaction globally available for Sentry.getSpan();
      bindToScope: true,
    );
    try {
      await _load();
      transaction.status = const SpanStatus.ok();
    } catch (e) {
      transaction.throwable = e;
      transaction.status = const SpanStatus.internalError();
    } finally {
      await transaction.finish();
    }
  }

  Future<void> _sendBugReport() async {
    /*
    try {
      throw ManuallyCaughtException('A really bad exception');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
    */

    try {
      throw ManuallyCaughtException('A really bad exception');
    } catch (e, stackTrace) {
      final id = await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          const txt = 'Lorem Ipsum dolar sit amet';
          scope.addAttachment(
            SentryAttachment.fromIntList(
              utf8.encode(txt),
              'foobar.txt',
              contentType: 'text/plain',
            ),
          );
        },
      );
      // Sentry.captureUserFeedback(SentryUserFeedback());
      await UserFeedbackDialog.show(context: context, id: id);
      //*/
    }
  }
}
