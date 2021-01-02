import 'package:countdown/models/countdown_model.dart';
import 'package:countdown/screens/dashboard_widget.dart';
import 'package:countdown/screens/frame.dart';
import 'package:countdown/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'mock_utils.dart';

NotificationService _mockNotificationService;
CountdownModel _countdownModel;

void main() {
  setUp(() {
    _mockNotificationService = getMockNotificationService();
    _countdownModel = getMockCountdownModel();
  });

  group("Frame widget", () {
    Widget getTestWidget() {
      return MultiProvider(providers: [
        ChangeNotifierProvider<NotificationService>.value(
            value: _mockNotificationService),
        ChangeNotifierProvider<CountdownModel>.value(value: _countdownModel),
      ], child: MaterialApp(home: Frame()));
    }

    testWidgets('has loaded all elements', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(DashboardWidget), findsOneWidget);
        expect(find.byType(IconButton), findsNWidgets(2));
      });
    });

    testWidgets('can add new countdown', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    testWidgets('can enable developer mode', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(IconButton), findsNWidgets(2));
        expect(find.byIcon(Icons.settings), findsNothing);
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();
        expect(find.byType(IconButton), findsNWidgets(3));
        expect(find.byIcon(Icons.settings), findsOneWidget);
      });
    });
  });
}
