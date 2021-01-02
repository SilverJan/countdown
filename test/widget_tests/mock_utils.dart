import 'package:countdown/models/countdown_model.dart';
import 'package:countdown/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';

class MockCountdownModel extends Mock implements CountdownModel {}

/// Returns a CountdownModel mock file with default (positive) return values
MockCountdownModel getMockCountdownModel() {
  MockCountdownModel mockCountdownModel = MockCountdownModel();

  List<CountdownItem> mockList = [
    CountdownItem(DateTime.now(), "Today - no alarm", Icons.ac_unit, false),
    CountdownItem(DateTime.now().add(Duration(days: 1)), "Tomorrow - alarm",
        Icons.access_alarm, true),
    CountdownItem(DateTime.now().subtract(Duration(days: 1)),
        "Yesterday - alarm", Icons.access_time, true)
  ];

  when(mockCountdownModel.countdowns).thenReturn(mockList);

  when(mockCountdownModel.hasCountdownsInPast()).thenReturn(true);

  return mockCountdownModel;
}

class MockNotificationService extends Mock implements NotificationService {}

/// Returns a NotificationService mock file with default (positive) return values
MockNotificationService getMockNotificationService() {
  MockNotificationService mockNotificationService = MockNotificationService();

  List<PendingNotificationRequest> mockList = [
    PendingNotificationRequest(0, "title", "body", "payload")
  ];

  when(mockNotificationService.getScheduledNotificationRequests())
      .thenAnswer((realInvocation) => Future.value(mockList));

  return mockNotificationService;
}
