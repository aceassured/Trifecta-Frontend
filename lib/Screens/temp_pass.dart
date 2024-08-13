import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:trifecta/Screens/create_temp_password.dart';

class TemporaryPasswordScreen extends StatefulWidget {
  final String deviceId;

  const TemporaryPasswordScreen({Key? key, required this.deviceId})
      : super(key: key);

  @override
  _TemporaryPasswordScreenState createState() =>
      _TemporaryPasswordScreenState();
}

class _TemporaryPasswordScreenState extends State<TemporaryPasswordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> tempPasswords = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTemporaryPasswords();
  }

  Future<void> _fetchTemporaryPasswords() async {
    setState(() {
      isLoading = true;
    });

    // final String apiUrl =
    //     'http://192.168.0.106:3000/api/get-temp-passwords?deviceId=${widget.deviceId}';
    final String apiUrl =
        'http://192.168.0.106:3000/api/get-temp-passwords?deviceId=${widget.deviceId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        setState(() {
          tempPasswords = resBody as List<dynamic>;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load temporary passwords');
      }
    } catch (e) {
      print('Error fetching temporary passwords: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _createTemporaryPassword() async {
    // final String apiUrl =
    //     'http://192.168.0.106:3000/api/device/create_temp_password';
    final String apiUrl =
        'http://192.168.0.106:3000/api/device/create_temp_password';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization':
            'Bearer YOUR_ACCESS_TOKEN', // Replace with actual token
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_id': widget.deviceId,
      }),
    );

    if (response.statusCode == 200) {
      final resBody = jsonDecode(response.body);
      final newTempPassword = resBody['result']['password'];
      setState(() {
        tempPasswords.add(newTempPassword);
      });
      _showTempPasswordDialog(newTempPassword);
    } else {
      print('Failed to create temporary password: ${response.reasonPhrase}');
    }
  }

  void _showTempPasswordDialog(String tempPassword) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title:
              Text('Temporary Password', style: TextStyle(color: Colors.white)),
          content: Text('Your temporary password is $tempPassword',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        title: Text(
          'Temporary Passwords',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // You can use a custom font here
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Active tab text color
          unselectedLabelColor: Colors.white70, // Inactive tab text color
          indicatorColor: Colors.blue,
          tabs: [
            Tab(
              text: 'Create Password',
            ),
            Tab(text: 'View Passwords'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // _buildCreatePasswordTab(),
          CreatePasswordForm(
            deviceId: widget.deviceId,
          ),
          _buildViewPasswordsTab(),
        ],
      ),
    );
  }

  Widget _buildCreatePasswordTab() {
    return Center(
      child: ElevatedButton(
        onPressed: _createTemporaryPassword,
        child: Text('Create Temporary Password'),
      ),
    );
  }

  // Widget _buildViewPasswordsTab() {
  //   if (isLoading) {
  //     return Center(
  //         child: CircularProgressIndicator(
  //       color: Colors.red,
  //     ));
  //   }

  //   if (tempPasswords.isEmpty) {
  //     // return Center(
  //     //   child: Text('No temporary passwords found',
  //     //       style: TextStyle(color: Colors.red)),
  //     // );
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.lock_open, // Choose an appropriate icon for "no passwords"
  //             size: 50,
  //             color: Colors.black, // Icon color
  //           ),
  //           SizedBox(height: 16), // Space between icon and text
  //           Text(
  //             'Temporary Passwords Not Found',
  //             style: TextStyle(
  //               color: Colors.black,
  //               fontSize: 18, // Font size
  //               fontWeight: FontWeight.bold, // Font weight
  //               fontFamily: 'Arial', // Replace with your preferred font family
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   return ListView.builder(
  //     itemCount: tempPasswords.length,
  //     itemBuilder: (context, index) {
  //       final password = tempPasswords[index];
  //       return ListTile(
  //         title: Text(password, style: TextStyle(color: Colors.white)),
  //         subtitle: Text('Temporary Password',
  //             style: TextStyle(color: Colors.white70)),
  //       );
  //     },
  //   );
  // }
  Widget _buildViewPasswordsTab() {
    if (isLoading) {
      return Center(
          child: CircularProgressIndicator(
        color: Colors.red,
      ));
    }

    if (tempPasswords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_open, // Choose an appropriate icon for "no passwords"
              size: 50,
              color: Colors.black, // Icon color
            ),
            SizedBox(height: 16), // Space between icon and text
            Text(
              'Temporary Passwords Not Found',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18, // Font size
                fontWeight: FontWeight.bold, // Font weight
                fontFamily: 'Arial', // Replace with your preferred font family
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tempPasswords.length,
      itemBuilder: (context, index) {
        final password = tempPasswords[index];
        final effectiveTime = DateTime.fromMillisecondsSinceEpoch(
            password['effective_time'] * 1000);
        final invalidTime = DateTime.fromMillisecondsSinceEpoch(
            password['invalid_time'] * 1000);

        return Card(
          margin: EdgeInsets.all(10),
          color: Colors.blueGrey[800],
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title:
                Text(password['name'], style: TextStyle(color: Colors.white)),
            subtitle: Text(
              'Effective: ${DateFormat('MMM dd, yyyy hh:mm a').format(effectiveTime)}  '
              'Invalid: ${DateFormat('MMM dd, yyyy hh:mm a').format(invalidTime)}',
              style: TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: Icon(Icons.visibility, color: Colors.white),
              onPressed: () {
                // Handle view password action here
              },
            ),
          ),
        );
      },
    );
  }
}
