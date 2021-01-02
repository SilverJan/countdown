import 'dart:developer';
import 'dart:io';

import 'package:package_info/package_info.dart';

Duration getDelta(DateTime from, DateTime to) {
  return to.difference(from);
}

Future<String> getAppVersion() async {
  if (Platform.isIOS || Platform.isAndroid) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  } else {
    log("Platform not fully supported!");
    return Future.value("unknown");
  }
}
