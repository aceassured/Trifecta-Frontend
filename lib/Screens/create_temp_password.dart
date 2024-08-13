import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trifecta/Screens/auth/token_manager.dart';

class CreatePasswordForm extends StatefulWidget {
  final String deviceId;

  CreatePasswordForm({required this.deviceId});

  @override
  _CreatePasswordFormState createState() => _CreatePasswordFormState();
}

class _CreatePasswordFormState extends State<CreatePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _password;
  DateTime? _effectiveTime;
  DateTime? _invalidTime;
  Set<int> _workingDays = {};
  List<bool> _selectedDays = List.filled(7, false);
  int workingDaysNumber = 0;

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      print("First step");
      final effectiveTimestamp = _effectiveTime!.millisecondsSinceEpoch ~/ 1000;
      final invalidTimestamp = _invalidTime!.millisecondsSinceEpoch ~/ 1000;
      final effectiveTimeInMinutes =
          (_effectiveTime!.hour * 60) + _effectiveTime!.minute;
      final invalidTimeInMinutes =
          (_invalidTime!.hour * 60) + _invalidTime!.minute;
      print("Printing till here");
      // final workingDayBinary = _workingDays.fold(0, (previousValue, day) {
      //   return previousValue | (1 << (day - 1));
      // });
      print("FORMM DATA:--");
      print("DEVICE_ID:- " + widget.deviceId);
      print("Name:- " + _name.toString());
      print("Password:- " + _password.toString());
      print("effective_time:- " + effectiveTimestamp.toString());
      print("Invalid_Time:- " + invalidTimestamp.toString());
      print("Effective time in minutes:- " + effectiveTimeInMinutes.toString());
      print("Invalid time in minutes:- " + invalidTimeInMinutes.toString());

      final response = await http.post(
        // Uri.parse('http://192.168.0.106:3000/api/CreateTempPass'),
        Uri.parse('http://192.168.0.106:3000/api/CreateTempPass'),
        headers: {
          'Authorization': 'Bearer ${await getToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'deviceId': widget.deviceId,
          'name': _name,
          'password': _password,
          'startTime': effectiveTimestamp,
          'endTime': invalidTimestamp,
          'working_day': workingDaysNumber,
          'startTimediff': effectiveTimeInMinutes,
          'endTimediff': invalidTimeInMinutes
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(result);
        _showSuccessDialog("Temporary Password Created Successfully");
      } else {
        _showErrorDialog('Failed to create password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.blueGrey[900]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildTextField(
              labelText: 'Name of Temporary Password',
              onSaved: (value) => _name = value,
            ),
            SizedBox(height: 16),
            _buildTextField(
              labelText: 'Password',
              onSaved: (value) => _password = value,
              obscureText: true,
            ),
            SizedBox(height: 16),
            _buildDateTimePicker(
              labelText: 'Select Effective Time',
              onPressed: () async {
                final selectedDateTime = await _selectDateTime(context);
                if (selectedDateTime != null) {
                  setState(() {
                    _effectiveTime = selectedDateTime;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            _buildDateTimePicker(
              labelText: 'Select Invalid Time',
              onPressed: () async {
                final selectedDateTime = await _selectDateTime(context);
                if (selectedDateTime != null) {
                  setState(() {
                    _invalidTime = selectedDateTime;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            _buildButton(
              labelText: 'Select Working Days',
              onPressed: () {
                _selectWorkingDays();
              },
            ),
            SizedBox(height: 32),
            _buildButton(
              labelText: 'Create Password',
              onPressed: _submitForm,
              backgroundColor: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required Function(String?) onSaved,
    bool obscureText = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
      style: TextStyle(color: Colors.white),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }

  Widget _buildDateTimePicker({
    required String labelText,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        labelText,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildButton({
    required String labelText,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.blue,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        labelText,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  int _calculateWorkingDays() {
    int workingDayBinary = 0;

    // Iterate through the selected days and update the binary value
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        // Shift 1 to the corresponding bit position (Sunday is bit0, Saturday is bit6)
        workingDayBinary |= (1 << i);
      }
    }

    // Call the provided callback with the calculated value
    return workingDayBinary;
  }

  Future<DateTime?> _selectDateTime(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
    if (selectedDate == null) return null;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
    if (selectedTime == null) return null;

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  void _selectWorkingDays() async {
    final daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    final selectedDays = await showDialog<Set<int>>(
      context: context,
      builder: (context) {
        Set<int> selectedDays = Set.from(_workingDays);

        return AlertDialog(
          title: Text('Select Working Days'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: daysOfWeek.asMap().entries.map((entry) {
                  int index = entry.key;
                  String day = entry.value;

                  return CheckboxListTile(
                    title: Text(day),
                    value: selectedDays.contains(index),
                    onChanged: (isSelected) {
                      // _selectedDays[index] = !_selectedDays[index];
                      setState(() {
                        if (isSelected == true) {
                          selectedDays.add(index);
                          _selectedDays[index] = true;
                        } else {
                          selectedDays.remove(index);
                          _selectedDays[index] = false;
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(selectedDays);
              },
            ),
          ],
        );
      },
    );

    if (selectedDays != null) {
      setState(() {
        _workingDays = selectedDays;
        workingDaysNumber = _calculateWorkingDays();
      });
    }
  }

  void _showSuccessDialog(String password) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Temporary Password Created'),
          content: Text('Your temporary password is $password'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
