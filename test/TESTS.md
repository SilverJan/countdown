# Tests

This document shall give an overview about the different types of tests for the app and best practices.

## Types of tests

There are several types of tests:

* Unit testing
* Widget testing
* Integration testing

For more information read the [flutter testing documentation](https://flutter.dev/docs/testing).

### Unit testing

Unit tests are located in `tests/unit_tests`. They are used for testing non-widgets, like providers / models / utility classes.

### Widget testing

Widget tests are located in `tests/widget_tests`. They are used for testing of widgets (typically stored in `lib/screens`).

#### Template widget tests

Here is an example for a new widget test:

```dart
  group("ToBeTestedWidget widget", () {
    Widget getTestWidget() {
      return MultiProvider(providers: [
          ChangeNotifierProvider(
            create: (BuildContext context) => NotificationService(),
          ),
          ChangeNotifierProxyProvider<NotificationService, CountdownModel>(
              update: (context, notificationService, previousMessages) =>
                  CountdownModel(notificationService),
              create: (BuildContext context) => CountdownModel(null)),
      ], child: MaterialApp(home: ToBeTestedWidget()));
    }

    testWidgets('has loaded all elements', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // per default, TargetPlatform is set to null
        // hence, if one wants to test OS specific widgets, add this
        // hint: moving this to setUp does not work for random reasons
        debugDefaultTargetPlatformOverride = TargetPlatform.ios;

        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        expect(find.text("abc"), findsOneWidget);

        // this is necessary for tests to complete
        debugDefaultTargetPlatformOverride = null;
      });
    });

    testWidgets('can call mock', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(getTestWidget());
        await tester.pump();

        await tester.tap(find.text("abc"));
        await tester.pump();
        verify(_mockCmdExecutor.openFile(any)).called(1);
      });
    });
```

### Integration testing

TBD

## Best Practices

Here are some best practicses when writing tests.

### Using mockito

General documentation can be found here: https://pub.dev/packages/mockito

Learnings made with mockito:

* it is required to create Mock classes which have to be injected in the constructor of the class that should be tested. There is a file `test/widget_tests/mock_utils.dart` which is used for creating such classes.

* when using a `verify()` assertion: the counter is being reset every time you call the `verify()` function. See https://stackoverflow.com/a/62182025/4977476

### Using test (widget testing framework)

General documentation can be found here: https://pub.dev/packages/test

Learnings made with test:

* use `group` functionality to logically bind test cases together

* use `setUp()`, `setUpAll()` and `tearDown()`, `tearDownAll()` as it is very useful

* always verify tests in VS code, and by running `flutter test`

### Mocking platform (linux/macOS) in tests

It has shown that using the `Platform.isIOS` functions are not mockable, hence they are bad for testing.

Instead, we are now using `Theme.of(context).platform == TargetPlatform.ios`, which can be mocked by adding the follwing lines in a widget test case:

```dart
// first line in testWidgets() function, before pumpWidget()
debugDefaultTargetPlatformOverride = TargetPlatform.ios;

// at the end of testWidgets() function
debugDefaultTargetPlatformOverride = null;
```

See also the template widget test above for a full example.

### Accessing / Creating files

TBD

TODO: Use mock of pathProvider as specified in https://flutter.dev/docs/cookbook/persistence/reading-writing-files

### Accessing assets

Accessing assets can be achieved via

```dart
String mockFileContent = await rootBundle.loadString('assets/test_data.xml');
```

Before that, the assets have to be created and also specified in `pubspec.yml`:

```yml
flutter:
  assets:
    - assets/test_data.xml
```

It is also important to note that the following line must be executed in `setUpAll()` before access to the asset works:

```dart
setUpAll(() {
  TestWidgetsFlutterBinding.ensureInitialized();
});
```

Refer to:

* https://stackoverflow.com/questions/44816042/flutter-read-text-file-from-assets
* https://stackoverflow.com/questions/60671728/unable-to-load-assets-in-flutter-tests

### Envionments (debug/productive/test)

Some learnings here:

* use the `kReleaseMode` variable to get information about the current application mode
