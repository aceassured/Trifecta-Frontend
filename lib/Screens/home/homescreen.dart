import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:trifecta/Screens/auth/token_manager.dart';
import 'package:trifecta/Screens/qrcodescreen.dart';
import 'package:trifecta/Screens/temp_pass.dart';
import 'package:trifecta/UserModel/user.dart';
import 'package:trifecta/UserModel/user_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> devices = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _fetchDevices();
  }

  Future<void> _initializeUser() async {
    final userID = await getUserId();
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where("userId", isEqualTo: userID)
        .get();
    if (userDoc.docs.isNotEmpty) {
      final userData = userDoc.docs[0].data();
      if (userData != null) {
        final user = UserModel(
          userId: userData['userId'],
          userName: userData['username'],
          countryCode: userData['country_code'],
          space: userData['space'].toString(),
        );
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      }
    }
  }

  Future<void> _fetchDevices() async {
    setState(() {
      isLoading = true;
    });
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final spaceId = user?.space;

      final response = await http.get(
        // Uri.parse('http://192.168.0.106:3000/api/space/list/$spaceId'),
        Uri.parse('http://192.168.0.106:3000/api/space/list/$spaceId'),
      );

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        final data = resBody['result']['data'] as List<dynamic>;
        final List<String> resIds =
            data.map((item) => item['res_id'] as String).toList();

        // Fetch details for each device
        await fetchDeviceDetails(resIds);
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  Future<void> fetchDeviceDetails(List<String> deviceIds) async {
    // final String apiUrl = 'http://192.168.0.106:3000/api/device/bulk';
    final String apiUrl = 'http://192.168.0.106:3000/api/device/bulk';
    final accessToken = await getToken();
    final String deviceIdsParam = deviceIds.join(',');

    final response = await http.get(
      Uri.parse('$apiUrl/$deviceIdsParam'),
    );

    if (response.statusCode == 200) {
      final resBody = jsonDecode(response.body);
      final deviceDetails = resBody['result'] as List<dynamic>;

      setState(() {
        isLoading = false;
        devices = deviceDetails;
      });
    } else {
      print('Failed to fetch device details: ${response.reasonPhrase}');
    }
  }

  Future<void> _generateTemporaryPassword(String deviceId) async {
    // final String apiUrl =
    //     'http://192.168.0.106:3000/api/device/create_temp_password';
    final String apiUrl =
        'http://192.168.0.106:3000/api/device/create_temp_password';
    final accessToken = await getToken();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_id': deviceId,
        // Include any other parameters required by your API
      }),
    );

    if (response.statusCode == 200) {
      final resBody = jsonDecode(response.body);
      final tempPassword = resBody['result']['password'];

      // Show the temporary password to the user
      _showTempPasswordDialog(tempPassword);
    } else {
      print('Failed to generate temporary password: ${response.reasonPhrase}');
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

  Future<void> _controlLock(String deviceId, bool lock) async {
    // final String apiUrl = lock
    //     ? 'http://192.168.0.106:3000/api/device/lock'
    //     : 'http://192.168.0.106:3000/api/device/unlock';
    final String apiUrl = lock
        ? 'http://192.168.0.106:3000/api/device/lock'
        : 'http://192.168.0.106:3000/api/device/unlock';
    final accessToken = await getToken();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_id': deviceId,
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful lock/unlock operation
      print(lock ? 'Locked' : 'Unlocked');
    } else {
      print('Failed to control lock: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Trifecta',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto', // You can use a custom font here
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _buildBottomSheet(context);
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.white30,
              ))
            : _buildDeviceList(),
      ),
    );
  }

  Widget _buildDeviceList() {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.device_unknown, size: 50, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'No devices found',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        print(device);
        return Card(
          margin: EdgeInsets.all(10),
          color: Colors.blueGrey[800],
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(device['name'], style: TextStyle(color: Colors.white)),
            subtitle: Text(
                '${device['category']} - ${device['is_online'] ? "Online" : "Offline"}',
                style: TextStyle(color: Colors.white70)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.lock, color: Colors.white),
                  onPressed: () => _controlLock(device['uuid'], true),
                ),
                IconButton(
                  icon: Icon(Icons.lock_open, color: Colors.white),
                  onPressed: () => _controlLock(device['uuid'], false),
                ),
                IconButton(
                  icon: Icon(Icons.password, color: Colors.white),
                  // onPressed: () => _generateTemporaryPassword(device['uuid']),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TemporaryPasswordScreen(deviceId: device['uuid']),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.bluetooth, color: Colors.blue, size: 30),
            title:
                Text('Discover Devices', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showDiscoveryDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.qr_code, color: Colors.blue, size: 30),
            title: Text('Scan QR Code', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRCodeScannerScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDiscoveryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title:
              Text('Device Discovery', style: TextStyle(color: Colors.white)),
          content: Text('Discover devices feature will be implemented here.',
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
}
