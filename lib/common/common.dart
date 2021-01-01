import 'package:package_info/package_info.dart';

Duration getDelta(DateTime from, DateTime to) {
  return to.difference(from);
}

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
