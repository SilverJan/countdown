import 'package:countdown/models/countdown_model.dart';
import 'package:countdown/screens/dashboard_widget.dart';
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

  group("Dashboard widget", () {
    Widget getTestWidget() {
      return MultiProvider(providers: [
        ChangeNotifierProvider<NotificationService>.value(
            value: _mockNotificationService),
        ChangeNotifierProvider<CountdownModel>.value(value: _countdownModel),
      ], child: MaterialApp(home: DashboardWidget()));
    }

    testWidgets('has loaded all elements', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();
        await tester.pumpAndSettle();

        // show ListView for upcoming and past countdowns
        expect(find.byType(ListView), findsNWidgets(2));
        expect(find.byType(Card), findsNWidgets(3));
      });
    });
  });
}
