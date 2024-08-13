import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:trifecta/Screens/auth/login.dart';
import 'package:trifecta/UserModel/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the current user from the provider
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Center(
          child: Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto', // You can use a custom font here
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text(
                user?.userName ??
                    'Unknown User', // Display username from UserModel
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text(
                user?.countryCode ??
                    'Unknown Country', // Display country code from UserModel
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.space_bar,
                  color: Colors.blue), // Placeholder icon for space ID
              title: Text(
                user?.space?.toString() ??
                    'Unknown Space', // Display space ID from UserModel
                style: TextStyle(color: Colors.white),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                // Clear tokens from storage
                final storage = FlutterSecureStorage();
                await storage.deleteAll();

                // Clear user data from provider
                Provider.of<UserProvider>(context, listen: false).clearUser();

                // Navigate to login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey[900],
    );
  }
}
