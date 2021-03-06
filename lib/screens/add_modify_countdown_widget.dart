import 'dart:io';
import 'dart:ui';

import 'package:countdown/common/config.dart';
import 'package:countdown/models/countdown_model.dart';
import 'package:flutter/cupertino.dart';
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

  bool _hasAlarm = false;

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
      _hasAlarm = widget.selectedItem.hasAlarm;
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

  /// Returns true if the notification checkbox should be enabled
  bool _isNotificationCheckboxEnabled() {
    bool enabled = true;
    // only if there is a date, start to dig deeper
    if (_dateInput.text != null && _dateInput.text != "") {
      DateTime date = _dateFormatter.parse(_dateInput.text);
      DateTime time;
      // add time value if available (not the case while creating a new countdown)
      if (_timeInput.text != null && _timeInput.text != "") {
        time = _timeFormatter.parse(_timeInput.text);
      }
      DateTime merged = time != null
          ? DateTime(date.year, date.month, date.day, time.hour, time.minute)
          : date;
      if (merged.isBefore(DateTime.now())) {
        enabled = false;
      }
    }

    return enabled;
  }

  Widget _buildBottomCupertinoPicker(Widget picker) {
    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.darkBackgroundGray,
      child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Brightness.dark,
              ),
              child: picker,
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _title = widget.mode == CountdownWidgetModes.add
        ? "Add countdown"
        : "Modify countdown";

    final _buttonSubmitText =
        widget.mode == CountdownWidgetModes.add ? "Add" : "Update";

    final _countdownModel = Provider.of<CountdownModel>(context);
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
                    // Step 1: Enter label
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
                    // Step 2: Enter date
                    TextFormField(
                      controller: _dateInput,
                      decoration: const InputDecoration(
                          hintText: "Select date",
                          focusedBorder: Config.BORDER),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                      onTap: () async {
                        // show cupertino style selection, if iOS detected
                        if (Platform.isIOS) {
                          showCupertinoModalPopup<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return _buildBottomCupertinoPicker(
                                CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  // set initialDateTime depending on add or modify mode
                                  initialDateTime:
                                      widget.mode == CountdownWidgetModes.add
                                          ? DateTime.now()
                                              .add(new Duration(days: 1))
                                          : widget.selectedItem.time,
                                  onDateTimeChanged: (DateTime newDateTime) {
                                    setState(() {
                                      _dateInput.text =
                                          _dateFormatter.format(newDateTime);
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        } else {
                          DateTime date = await showDatePicker(
                            context: context,
                            // set initialTime depending on add or modify mode
                            initialDate: widget.mode == CountdownWidgetModes.add
                                ? DateTime.now().add(new Duration(days: 1))
                                : widget.selectedItem.time,

                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _dateInput.text = _dateFormatter.format(date);
                            });
                          }
                        }
                      },
                    ),
                    // Step 3: Enter time (if there is a date)
                    if (_dateInputHasValue)
                      TextFormField(
                        controller: _timeInput,
                        decoration: const InputDecoration(
                            hintText: "Select time",
                            focusedBorder: Config.BORDER),
                        onTap: () async {
                          DateTime confirmedDate =
                              DateTime.parse(_dateInput.text);

                          // show cupertino style selection, if iOS detected
                          if (Platform.isIOS) {
                            showCupertinoModalPopup<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return _buildBottomCupertinoPicker(
                                  CupertinoDatePicker(
                                    use24hFormat: true,
                                    mode: CupertinoDatePickerMode.time,
                                    // set initialTime depending on add or modify mode
                                    initialDateTime:
                                        widget.mode == CountdownWidgetModes.add
                                            ? DateTime.now()
                                            : widget.selectedItem.time,
                                    onDateTimeChanged: (DateTime newDateTime) {
                                      DateTime mergedDate = new DateTime(
                                          confirmedDate.year,
                                          confirmedDate.month,
                                          confirmedDate.day,
                                          newDateTime.hour,
                                          newDateTime.minute);
                                      setState(() {
                                        _dateInput.text =
                                            _dateFormatter.format(mergedDate);
                                        _timeInput.text =
                                            _timeFormatter.format(mergedDate);
                                      });
                                    },
                                  ),
                                );
                              },
                            );
                          } else {
                            TimeOfDay time = await showTimePicker(
                              context: context,
                              // set initialTime depending on add or modify mode
                              initialTime:
                                  widget.mode == CountdownWidgetModes.add
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
                              DateTime mergedDate = new DateTime(
                                  confirmedDate.year,
                                  confirmedDate.month,
                                  confirmedDate.day,
                                  time.hour,
                                  time.minute);
                              setState(() {
                                _dateInput.text =
                                    _dateFormatter.format(mergedDate);
                                _timeInput.text =
                                    _timeFormatter.format(mergedDate);
                              });
                            }
                          }
                        },
                      ),
                    // Step 4: Select icon
                    DropdownButtonFormField<IconData>(
                      value: _dropdownValue,
                      onChanged: (value) {
                        setState(() {
                          _dropdownValue = value;
                        });
                      },
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
                    ),
                    // Step 5: Set alarm
                    CheckboxListTile(
                        title: Text("Notification enabled?"),
                        subtitle: Text(
                          "will appear at the time of the event",
                          style: TextStyle(fontSize: 14),
                        ),
                        contentPadding: EdgeInsets.only(top: 10),
                        value: _hasAlarm,
                        activeColor: Config.PRIMARY_COLOR,
                        onChanged: _isNotificationCheckboxEnabled()
                            ? (newValue) {
                                setState(() {
                                  _hasAlarm = newValue;
                                });
                              }
                            : null)
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
                    _countdownModel.addCountdown(new CountdownItem(
                        mergedDateTime,
                        _labelInput.value.text,
                        _dropdownValue,
                        _hasAlarm));
                  } else {
                    // modify the values on the actual item
                    widget.selectedItem.label = _labelInput.value.text;
                    widget.selectedItem.time = mergedDateTime;
                    widget.selectedItem.icon = _dropdownValue;
                    widget.selectedItem.hasAlarm = _hasAlarm;
                    _countdownModel.updateCountdown(widget.selectedItem);
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
