import 'package:ios_countdown/common/FileAccess.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CountdownModel extends ChangeNotifier {
  List<CountdownItem> countdowns = [];
  FileAccess storage = new FileAccess();

  CountdownModel() {
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

  /// Add countdownItem to list of countdowns, sort and persist the list
  void addCountdown(CountdownItem countdownItem) {
    countdowns.add(countdownItem);
    sortCountdowns();
    persistCountdownsInFile();
  }

  /// Remove countdownItem from list of countdowns, sort and persist the list
  void removeCountdown(String id) {
    countdowns.remove(getById(id));
    sortCountdowns();
    persistCountdownsInFile();
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

  CountdownItem(this.time, this.label, this.icon) : id = Uuid().v1();

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
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time.toIso8601String(),
        'label': label,
        'icon': icon != null ? icon.codePoint : "null"
      };
}
