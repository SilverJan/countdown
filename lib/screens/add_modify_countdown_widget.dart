import 'dart:ui';

import 'package:ios_countdown/common/config.dart';
import 'package:ios_countdown/models/countdown_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

enum CountdownWidgetModes { add, modify }

class AddModifyCountdownWidget extends StatefulWidget {
  final CountdownWidgetModes mode;
  final CountdownItem selectedItem;
  const AddModifyCountdownWidget(
      {Key key, this.mode = CountdownWidgetModes.add, this.selectedItem})
      : super(key: key);

  @override
  _AddModifyCountdownWidgetState createState() =>
      _AddModifyCountdownWidgetState();
}

class _AddModifyCountdownWidgetState extends State<AddModifyCountdownWidget> {
  final TextEditingController _labelInput = new TextEditingController();
  final TextEditingController _dateInput = new TextEditingController();
  final TextEditingController _timeInput = new TextEditingController();
  IconData _dropdownValue;
  bool _dateInputHasValue = false;

  DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  DateFormat _timeFormatter = DateFormat.Hm();

  @override
  void initState() {
    // Set values if selectedItem is not null (i.e. modify operation)
    if (widget.selectedItem != null) {
      _labelInput.text = widget.selectedItem.label;
      _dateInput.text = _dateFormatter.format(widget.selectedItem.time);
      _timeInput.text = _timeFormatter.format(widget.selectedItem.time);
      _dropdownValue = widget.selectedItem.icon;
      _dateInputHasValue = true;
    }

    // Start listening to changes
    _dateInput.addListener(() {
      setState(() {
        _dateInput.text == ""
            ? _dateInputHasValue = false
            : _dateInputHasValue = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _labelInput.dispose();
    _dateInput.dispose();
    _timeInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _title = widget.mode == CountdownWidgetModes.add
        ? "Add countdown"
        : "Modify countdown";

    final _buttonSubmitText =
        widget.mode == CountdownWidgetModes.add ? "Add" : "Update";

    final _countdownList = Provider.of<CountdownModel>(context);
    final _formKey = GlobalKey<FormState>();

    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: Text(_title),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _labelInput,
                      decoration: const InputDecoration(
                          hintText: "Enter label, e.g. 'Christmas'",
                          focusedBorder: Config.BORDER),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _dateInput,
                      decoration: const InputDecoration(
                          hintText: "Enter date", focusedBorder: Config.BORDER),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a date';
                        }
                        return null;
                      },
                      onTap: () async {
                        DateTime date = DateTime(1900);

                        date = await showDatePicker(
                          context: context,
                          // set initialTime depending on add or modify mode
                          initialDate: widget.mode == CountdownWidgetModes.add
                              ? DateTime.now().add(new Duration(days: 1))
                              : widget.selectedItem.time,

                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );

                        if (date != null) {
                          _dateInput.text = _dateFormatter.format(date);
                        }
                      },
                    ),
                    if (_dateInputHasValue)
                      TextFormField(
                        controller: _timeInput,
                        decoration: const InputDecoration(
                            hintText: "Enter time",
                            focusedBorder: Config.BORDER),
                        onTap: () async {
                          TimeOfDay time = TimeOfDay.now();

                          time = await showTimePicker(
                            context: context,
                            // set initialTime depending on add or modify mode
                            initialTime: widget.mode == CountdownWidgetModes.add
                                ? TimeOfDay.now()
                                : TimeOfDay.fromDateTime(
                                    widget.selectedItem.time),
                            // builder to enforce 24h format
                            builder: (BuildContext context, Widget child) {
                              return MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(alwaysUse24HourFormat: true),
                                child: child,
                              );
                            },
                          );
                          if (time != null) {
                            DateTime date = DateTime.parse(_dateInput.text);
                            DateTime mergedDate = new DateTime(date.year,
                                date.month, date.day, time.hour, time.minute);
                            _dateInput.text = _dateFormatter.format(mergedDate);
                            _timeInput.text = _timeFormatter.format(mergedDate);
                          }
                        },
                      ),
                    DropdownButtonFormField<IconData>(
                      value: _dropdownValue,
                      onChanged: (value) => _dropdownValue = value,
                      items: [
                        DropdownMenuItem(
                          child: Text("None"),
                          value: null,
                        ),
                        DropdownMenuItem(
                          child: Icon(Icons.ac_unit),
                          value: Icons.ac_unit,
                        ),
                        DropdownMenuItem(
                          child: Icon(Icons.alarm),
                          value: Icons.alarm,
                        ),
                        DropdownMenuItem(
                          child: Icon(Icons.airplanemode_active),
                          value: Icons.airplanemode_active,
                        ),
                        DropdownMenuItem(
                          child: Icon(Icons.tag_faces),
                          value: Icons.tag_faces,
                        ),
                        DropdownMenuItem(
                          child: Icon(Icons.attach_money),
                          value: Icons.attach_money,
                        ),
                        DropdownMenuItem(
                          child: Icon(Icons.favorite),
                          value: Icons.favorite,
                        )
                      ],
                      decoration: const InputDecoration(
                          helperText: "Choose icon",
                          focusedBorder: Config.BORDER),
                    )
                  ],
                ),
              ),
            )
          ]),
          actions: <Widget>[
            new FlatButton(
              child: Text(_buttonSubmitText),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  // manually craft new DateTime based on _dateInput and _timeInput
                  // necessary because user output looks bad
                  DateTime mergedDateTime = DateTime.parse(
                      "${_dateInput.text} ${_timeInput.text}".trim());

                  if (widget.mode == CountdownWidgetModes.add) {
                    // add a new countdown item
                    _countdownList.addCountdown(new CountdownItem(
                        mergedDateTime,
                        _labelInput.value.text,
                        _dropdownValue));
                  } else {
                    // modify the values on the actual item
                    widget.selectedItem.label = _labelInput.value.text;
                    widget.selectedItem.time = mergedDateTime;
                    widget.selectedItem.icon = _dropdownValue;
                    _countdownList.persistCountdownsInFile();
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
            new FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}
