import 'package:ios_countdown/models/CountdownModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/CountdownWidget.dart';

void main() => runApp(CountdownApp());

class CountdownApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<CountdownModel>.value(value: CountdownModel())
        ],
        child: MaterialApp(
          home: CountdownWidget(),
          themeMode: ThemeMode.dark,
          theme: ThemeData(
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
        ));
  }
}
