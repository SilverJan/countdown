import 'package:countdown/common/common.dart';
import 'package:countdown/common/config.dart';
import 'package:countdown/screens/add_modify_countdown_widget.dart';
import 'package:countdown/screens/dashboard_widget.dart';
import 'package:countdown/screens/secondary/dev_settings.dart';
import 'package:flutter/material.dart';

class Frame extends StatefulWidget {
  @override
  _FrameState createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  bool _showDevSettings = false;
  int _devSettingsCounter = 0;
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  void _getAppVersion() async {
    if (mounted) {
      var res = await getAppVersion();
      setState(() {
        _appVersion = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(Config.APP_NAME),
          leading: IconButton(
            icon: Icon(Icons.calendar_today),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onPressed: () {
              if (_devSettingsCounter >= 5) {
                setState(() {
                  _showDevSettings = true;
                });
              } else {
                _devSettingsCounter++;
              }
            },
          ),
          actions: <Widget>[
            _showDevSettings
                ? IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Open developer settings',
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => DevSettingsWidget());
                    },
                  )
                : Container(),
            IconButton(
              icon: const Icon(Icons.info),
              tooltip: 'Show app info',
              onPressed: () {
                showAboutDialog(
                    context: context,
                    applicationName: Config.APP_NAME,
                    applicationIcon: Icon(Icons.calendar_today),
                    applicationVersion: _appVersion,
                    children: [
                      Text(
                          "This countdown tracker allows you to create, modify and delete future & past events.")
                    ]);
              },
            ),
          ]),
      body: DashboardWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context, builder: (ctx) => AddModifyCountdownWidget());
        },
        tooltip: 'Add countdown',
        child: const Icon(Icons.add),
        backgroundColor: Config.PRIMARY_COLOR,
      ),
    );
  }
}
