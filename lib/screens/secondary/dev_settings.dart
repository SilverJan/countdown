import 'package:countdown/screens/secondary/pending_notifications_widget.dart';
import 'package:countdown/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class DevSettingsWidget extends StatefulWidget {
  @override
  _DevSettingsWidgetState createState() => _DevSettingsWidgetState();
}

class _DevSettingsWidgetState extends State<DevSettingsWidget> {
  bool _notificationsEnabled = true;
  NotificationService _notificationService;

  @override
  void initState() {
    super.initState();

    _notificationService =
        Provider.of<NotificationService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Developer Settings"),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notification Settings",
                      textAlign: TextAlign.start,
                    ),
                    ButtonBar(alignment: MainAxisAlignment.start, children: [
                      RaisedButton(
                        onPressed: () async {
                          _notificationService
                              .triggerInstantNotification("Test notification");
                        },
                        child: Text("Test notification"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          _notificationService.triggerScheduledNotification(
                              0,
                              "Test scheduled notification",
                              "Countdown Test",
                              TZDateTime.now(local)
                                  .add(const Duration(seconds: 10)));
                        },
                        child: Text("Test scheduled notification (in 10s)"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          _notificationService.clearAllScheduledNotifications();
                        },
                        child: Text("Clear all notifications"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PendingNotificationWidget()),
                          );
                        },
                        child: Text("Show pending notifications"),
                      ),
                    ])
                  ]),
            )
          ]),
      actions: <Widget>[
        new FlatButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
