import 'dart:io';

import 'package:example/overview_page.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

Future<void> main() {
  return SentryFlutter.init(
    (options) {
      // Get your DSN from sentry.io
      options.dsn =
          '<put your dsn here>';

      // Add integration for `logging` package - https://pub.dev/packages/logging
      options.addIntegration(LoggingIntegration());

      // Enable performance tracing
      // Any value above 0 enables it.
      // 0 = 0% and 1 = 100%, so the value decides how much
      // traces are getting reported.
      options.tracesSampleRate = 1;

      // Due to missing reflection, Sentry can't figure out the package name
      // by it's own. Therefore, it's done manually
      //
      // Mark stackframes from package `example` as in-app
      options.addInAppInclude('example');
      // Consider frames as not-in-app by default
      options.considerInAppFramesByDefault = false;

      // beforeSend is called before an event is send.
      // It can be used to drop unwanted events.
      // Works for crashes and performance traces
      options.beforeSend = (event, {hint}) {
        if (event.throwable is SocketException) {
          return null;
        }
        return event;
      };
    },
    appRunner: appRunner,
  );
}

void appRunner() {
  // Sentry.configureScope((scope) {
  //  scope.user = SentryUser(username: 'anonymous');
  // });
  runApp(
    DefaultAssetBundle(
      // Add performance tracing for asset loading
      bundle: SentryAssetBundle(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentry Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        // This
        // - adds breadcrumbs for navigation events
        // - starts performance traces on navigation
        SentryNavigatorObserver(),
      ],
      home: const OverviewPage(),
    );
  }
}
