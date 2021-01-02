import 'package:countdown/screens/secondary/dev_settings.dart';
import 'package:countdown/screens/secondary/pending_notifications_widget.dart';
import 'package:countdown/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'mock_utils.dart';

NotificationService _mockNotificationService;

/// Tests for the secondary widget bar and all of its children widgets
void main() {
  setUp(() {
    _mockNotificationService = getMockNotificationService();
  });

  group("DevTools widget", () {
    Widget getTestWidget() {
      return MultiProvider(providers: [
        ChangeNotifierProvider<NotificationService>.value(
            value: _mockNotificationService),
      ], child: MaterialApp(home: DevSettingsWidget()));
    }

    testWidgets('has loaded all elements', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        expect(find.byType(RaisedButton), findsNWidgets(4));
      });
    });
  });

  group("PendingNotifications widget", () {
    Widget getTestWidget() {
      return MultiProvider(providers: [
        ChangeNotifierProvider<NotificationService>.value(
            value: _mockNotificationService),
      ], child: MaterialApp(home: PendingNotificationWidget()));
    }

    testWidgets('has loaded all elements', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        expect(find.byType(ListTile), findsNWidgets(1));
      });
    });
  });
}
