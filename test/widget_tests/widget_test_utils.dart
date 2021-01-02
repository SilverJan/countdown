import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies truth of [matcher] for every [widgetTypes]
void expectWidgetTypes(List<dynamic> widgetTypes, Matcher matcher) {
  for (dynamic type in widgetTypes) {
    expect(find.byType(type), matcher,
        reason: "type $type did not meet expectation of $matcher");
  }
}

/// Verifies truth of [matcher] of [widgetType] for given [icons]
void expectWidgetsWithIcons(
    dynamic widgetType, List<IconData> icons, Matcher matcher) {
  for (IconData icon in icons) {
    expect(find.widgetWithIcon(widgetType, icon), matcher,
        reason:
            "icon $icon (in parent widget $widgetType) did not meet expectation of $matcher");
  }
}

/// Resets window size to a given [width] and [height]
///
/// this is useful for testing of windows size dynamic UI elements
void resetWindowSize({double width = 2000, double height = 2000}) {
  // binding can be used for resizing window
  TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  binding.window.physicalSizeTestValue = Size(width, height);
  binding.window.devicePixelRatioTestValue = 1.0;
}
