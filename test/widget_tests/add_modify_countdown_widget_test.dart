import 'package:countdown/models/countdown_model.dart';
import 'package:countdown/screens/add_modify_countdown_widget.dart';
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

  group("AddModifyCountdown widget", () {
    Widget getTestWidget(
        {CountdownWidgetModes mode = CountdownWidgetModes.add,
        CountdownItem selectedItem}) {
      return MultiProvider(
          providers: [
            ChangeNotifierProvider<NotificationService>.value(
                value: _mockNotificationService),
            ChangeNotifierProvider<CountdownModel>.value(
                value: _countdownModel),
          ],
          child: MaterialApp(
              home: AddModifyCountdownWidget(
                  mode: mode, selectedItem: selectedItem)));
    }

    testWidgets('has loaded all elements', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        expect(find.byType(AlertDialog), findsNWidgets(1));
      });
    });

    testWidgets('can run in "add" mode', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        expect(find.text("Add countdown"), findsNWidgets(1));
      });
    });

    testWidgets('can run in "modify" mode', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget(
            mode: CountdownWidgetModes.modify,
            selectedItem: CountdownItem(
                DateTime(2020, 1, 1, 13, 15), "test", Icons.ac_unit, false)));
        await tester.pump();

        expect(find.text("Modify countdown"), findsNWidgets(1));
      });
    });

    testWidgets('shows hint texts', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        expect(find.textContaining("Enter label"), findsNWidgets(1));
        expect(find.textContaining("Select date"), findsNWidgets(1));
      });
    });

    testWidgets('shows time only if date is filled',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        // TODO
      });
    });

    testWidgets('shows date picker', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        // TODO
      });
    });

    testWidgets('shows time picker', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        // TODO
      });
    });

    testWidgets('shows notification option only if date and time in future',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        // TODO
      });
    });

    testWidgets('can validate form', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        // TODO
      });
    });

    testWidgets('can create countdown item', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        // TODO
      });
    });

    testWidgets('can update countdown item', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        // TODO
      });
    });
  });
}
