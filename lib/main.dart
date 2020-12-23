import 'package:flutter/material.dart';
import 'package:countdown/models/countdown_model.dart';
import 'package:countdown/screens/countdown_widget.dart';
import 'package:provider/provider.dart';

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
