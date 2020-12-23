import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:countdown/models/countdown_model.dart';
import 'package:path_provider/path_provider.dart';

class FileAccess {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/.countdowns.json');
  }

  Future<List<CountdownItem>> readCountdowns() async {
    try {
      final file = await _localFile;

      // Read the file
      String content = await file.readAsString();
      List countdownItemMapList = jsonDecode(content);
      List<CountdownItem> countdownItemList = [];
      for (Map countdownItemMap in countdownItemMapList) {
        countdownItemList.add(CountdownItem.fromJson(countdownItemMap));
      }
      return countdownItemList;
    } catch (e) {
      // If encountering an error, return empty array
      print("An error occured! " + e.toString());
      return [];
    }
  }

  Future<File> writeCountdowns(List<CountdownItem> countdownItems) async {
    final file = await _localFile;

    // Create JSON out of all countdownItems
    var completeJson = "[";

    for (var i = 0; i < countdownItems.length; i++) {
      String json = jsonEncode(countdownItems[i]);
      completeJson += "${json},";

      if (i == countdownItems.length - 1) {
        completeJson = completeJson.substring(0, completeJson.length - 1);
      }
    }

    completeJson += "]";

    // Write the file
    return file.writeAsString(completeJson);
  }
}
