import 'package:countdown/common/file_access.dart';
import 'package:countdown/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CountdownModel extends ChangeNotifier {
  List<CountdownItem> countdowns = [];
  FileAccess storage = new FileAccess();
  NotificationService _notificationService;

  CountdownModel(this._notificationService) {
    storage.readCountdowns().then((List<CountdownItem> countdownItems) {
      countdowns = countdownItems;
      sortCountdowns();
      notifyListeners();
    });
  }

  void persistCountdownsInFile() {
    storage.writeCountdowns(countdowns);
    notifyListeners();
  }

  List<CountdownItem> get countdownList => countdowns;

  int get length => countdowns.length;

  /// Get item by [id].
  CountdownItem getById(String id) =>
      countdowns.firstWhere((element) => element.id == id, orElse: () => null);

  /// Update countdown, persist the list and schedule / cancel notification
  void updateCountdown(CountdownItem countdownItem) {
    persistCountdownsInFile();

    if (countdownItem.hasAlarm) {
      _notificationService.triggerScheduledCountdownNotification(countdownItem);
    } else {
      _notificationService.clearScheduledNotification(countdownItem);
    }
  }

  /// Add countdownItem to list of countdowns, sort, persist the list
  /// and schedule notification
  void addCountdown(CountdownItem countdownItem) {
    countdowns.add(countdownItem);
    sortCountdowns();
    persistCountdownsInFile();

    if (countdownItem.hasAlarm) {
      _notificationService.triggerScheduledCountdownNotification(countdownItem);
    }
  }

  /// Remove countdownItem from list of countdowns, sort and persist the list
  void removeCountdown(String id) {
    CountdownItem countdownItem = getById(id);
    countdowns.remove(countdownItem);
    sortCountdowns();
    persistCountdownsInFile();

    if (countdownItem.hasAlarm) {
      _notificationService.clearScheduledNotification(countdownItem);
    }
  }

  /// Sort countdowns based on DateTime
  void sortCountdowns() {
    countdowns.sort((a, b) => a.compareTo(b));
  }

  bool hasCountdownsInPast() {
    return countdownList.any((CountdownItem element) => element.isInPast());
  }
}

class CountdownItem extends Comparable {
  final String id;
  DateTime time;
  String label;
  IconData icon;
  bool hasAlarm;

  CountdownItem(this.time, this.label, this.icon, this.hasAlarm)
      : id = Uuid().v1();

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is CountdownItem && other.id == id;

  @override
  int compareTo(other) {
    return time.compareTo(other.time);
  }

  bool isInPast() {
    return time.isBefore(DateTime.now());
  }

  CountdownItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        time = DateTime.parse(json['time']),
        label = json['label'],
        icon = json['icon'].toString() != "null"
            ? IconData(int.parse(json['icon'].toString()),
                fontFamily: 'MaterialIcons')
            : null,
        hasAlarm =
            json.containsKey('hasAlarm') ? json['hasAlarm'] == 'true' : false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time.toIso8601String(),
        'label': label,
        'icon': icon != null ? icon.codePoint : "null",
        'hasAlarm': hasAlarm
      };
}
