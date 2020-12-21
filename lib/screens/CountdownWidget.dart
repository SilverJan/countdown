import 'dart:async';

import 'package:ios_countdown/common/Config.dart';
import 'package:ios_countdown/common/Common.dart';
import 'package:ios_countdown/models/CountdownModel.dart';
import 'package:ios_countdown/screens/AddModifyCountdownWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CountdownWidget extends StatefulWidget {
  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  CountdownModel _countdownModel;

  Timer timer;

  @override
  void initState() {
    super.initState();
  }

  void refresh() {
    this.setState(() {});
    // if (_countdownModel.hasCountdownsInPast()) {
    //   publishNotification(
    //       title: "Expired countdowns", msg: "You have expired countdowns!");
    // }
  }

  @override
  Widget build(BuildContext context) {
    _countdownModel = Provider.of<CountdownModel>(context);
    timer = Timer.periodic(Duration(minutes: 1), (Timer t) => refresh());
    return Scaffold(
      appBar: AppBar(
          title: Text(Config.APP_NAME),
          leading: Icon(Icons.calendar_today),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.info),
              tooltip: 'Show app info',
              onPressed: () {
                showAboutDialog(
                    context: context,
                    applicationName: Config.APP_NAME,
                    applicationIcon: Icon(Icons.calendar_today),
                    applicationVersion: Config.VERSION,
                    children: [
                      Text(
                          "This is an amazing countdown tracker.\n\nCreated with Flutter.")
                    ]);
              },
            ),
          ]),
      body: _countdownModel.length > 0
          ? _buildCountdownView()
          : _buildEmptyListInfo(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, child: AddModifyCountdownWidget());
        },
        tooltip: 'Add countdown',
        child: const Icon(Icons.add),
        backgroundColor: Config.PRIMARY_COLOR,
      ),
    );
  }

  Widget _buildEmptyListInfo() {
    return Center(
        child: Text("Create countdowns by clicking on the + button."));
  }

  Widget _buildCountdownView() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(child: _buildCountdownListView(inPast: false)),
        Container(
            child: _countdownModel.hasCountdownsInPast()
                ? SizedBox(
                    height: 200, child: _buildCountdownListView(inPast: true))
                : null),
      ],
    );
  }

  Widget _buildCountdownListView({bool inPast = false}) {
    List<CountdownItem> filteredList = _countdownModel.countdownList
        .where((CountdownItem element) =>
            inPast ? element.isInPast() : !element.isInPast())
        .toList();

    ListView filteredListView = ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        return _buildRow(filteredList[i]);
      },
      itemCount: filteredList.length,
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(inPast ? "Past countdowns" : "Upcoming countdowns")),
        Flexible(child: Scrollbar(child: filteredListView))
      ],
    );
  }

  Card _buildRow(CountdownItem countdown) {
    Duration delta = getDelta(DateTime.now(), countdown.time);
    DateFormat formatter = DateFormat('EEE, yyyy-MM-dd hh:mm a');

    /// Prints a string of the time left, e.g. "6 days | 2 hours | 30 minutes"
    String _printDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitHours = twoDigits(duration.inHours.remainder(24));
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      // String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${(delta.inHours / 24).truncate()} days | $twoDigitHours hours | $twoDigitMinutes minutes";
    }

    return Card(
      child: Dismissible(
          key: ValueKey(countdown.id),
          direction: DismissDirection.horizontal,
          background: Container(
            color: Config.PRIMARY_COLOR,
            child: Icon(Icons.mode_edit),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10.0),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            child: Icon(Icons.delete),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 10.0),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              _countdownModel.removeCountdown(countdown.id);
              return true;
            } else {
              showDialog(
                  context: context,
                  child: AddModifyCountdownWidget(
                    mode: CountdownWidgetModes.modify,
                    selectedItem: countdown,
                  ));
              return false;
            }
          },
          child: ListTile(
            leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(countdown.icon)]),
            title: Text(
              "${_printDuration(delta)}",
              // style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
                "${countdown.label} (${formatter.format(countdown.time)})"),
            // contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            enabled: !delta.isNegative,
          )),
      // color: Colors.black45,
      // shadowColor: Colors.gr,
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 5.0),
    );
  }
}
