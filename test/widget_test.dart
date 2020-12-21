import 'package:flutter_test/flutter_test.dart';

import 'package:ios_countdown/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(CountdownApp());
  });
}
