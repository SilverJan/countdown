import 'package:countdown/models/countdown_model.dart';
import 'package:countdown/screens/frame.dart';
import 'package:countdown/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(CountdownApp());

class CountdownApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (BuildContext context) => NotificationService(),
          ),
          ChangeNotifierProxyProvider<NotificationService, CountdownModel>(
              update: (context, notificationService, previousMessages) =>
                  CountdownModel(notificationService),
              create: (BuildContext context) => CountdownModel(null)),
        ],
        child: MaterialApp(
          home: Frame(),
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
