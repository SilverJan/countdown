import 'dart:async';

import 'package:countdown/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class PendingNotificationWidget extends StatefulWidget {
  @override
  _PendingNotificationWidgetState createState() =>
      _PendingNotificationWidgetState();
}

class _PendingNotificationWidgetState extends State<PendingNotificationWidget> {
  NotificationService _notificationService;
  List<PendingNotificationRequest> pendingRequests = [];

  @override
  void initState() {
    super.initState();

    _notificationService =
        Provider.of<NotificationService>(context, listen: false);

    getScheduledNotificationRequests();
  }

  void getScheduledNotificationRequests() async {
    if (mounted) {
      var res = await _notificationService.getScheduledNotificationRequests();
      setState(() {
        pendingRequests = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(
        Duration(seconds: 5), (Timer t) => getScheduledNotificationRequests());

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Pending Notifications"),
              actions: [
                IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      getScheduledNotificationRequests();
                    })
              ],
            ),
            body: pendingRequests.length > 0
                ? ListView.builder(
                    itemCount: pendingRequests.length,
                    itemBuilder: (BuildContext context, int index) {
                      var request = pendingRequests[index];
                      return ListTile(
                        title: Text("ID: ${request.id.toString()}"),
                        subtitle: Text("Body: ${request.body}"),
                      );
                    },
                  )
                : Center(
                    child: Text(
                        "There are no pending requests at this moment."))));
  }
}
