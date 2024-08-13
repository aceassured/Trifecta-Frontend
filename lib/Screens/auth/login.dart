// import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:ui';

// import 'package:trifecta/Screens/auth/register.dart';
// import 'package:trifecta/Screens/home/home.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   Future<void> _login() async {
//     // try {
//     //   await FirebaseAuth.instance.signInWithEmailAndPassword(
//     //     email: _emailController.text,
//     //     password: _passwordController.text,
//     //   );
//     //   // Navigate to home page or another page
//     // } catch (e) {
//     //   // Handle error
//     //   print(e);
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text('Login', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.black.withOpacity(0.4),
//                       Colors.blue.withOpacity(0.4)
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//               BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: Colors.white.withOpacity(0.1)),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(
//                       height: 100,
//                     ),
//                     TextField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Email',
//                         labelStyle: TextStyle(color: Colors.white),
//                         border: OutlineInputBorder(),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blue),
//                         ),
//                       ),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     SizedBox(height: 10),
//                     TextField(
//                       controller: _passwordController,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         labelStyle: TextStyle(color: Colors.white),
//                         border: OutlineInputBorder(),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blue),
//                         ),
//                       ),
//                       obscureText: true,
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       // onPressed: _login,
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => HomePage()),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                       ),
//                       child:
//                           Text('Login', style: TextStyle(color: Colors.white)),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => RegisterPage()),
//                         );
//                       },
//                       child: Text(
//                         'Don\'t have an account? Register',
//                         style: TextStyle(color: Colors.blue),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trifecta/Screens/auth/register.dart';
import 'package:trifecta/Screens/auth/token_manager.dart';
import 'package:trifecta/Screens/home/home.dart';
import 'package:trifecta/UserModel/user.dart';
import 'package:trifecta/UserModel/user_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert the password to bytes
    final digest = md5.convert(bytes); // Hash the password
    return digest.toString(); // Convert the hash to a string
  }

  // Future<void> _login() async {
  //   final email = _emailController.text;
  //   final password = _passwordController.text;
  //   final hashedPassword = _hashPassword(password);

  //   final url = Uri.parse('http://192.168.0.106:3000/api/login');
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'username': email, 'password': hashedPassword}),
  //     );
  //     print(response);
  //     final data = jsonDecode(response.body);
  //     final accessToken = data['result'];
  //     final accessss = accessToken['access_token'];
  //     final refreshToken = accessToken['refresh_token'];
  //     final userID = accessToken['uid'];
  //     print(accessToken);
  //     if (data['success']) {
  //       final userDoc = await FirebaseFirestore.instance.collection('users').doc(userID).get();
  //       storeToken(accessss, refreshToken, 2);
  //       // final user = UserModel(
  //       //   userId: userID,
  //       //   userName: email,
  //       // );
  //       // Store user information in the provider
  //       Provider.of<UserProvider>(context, listen: false).setUser(user);
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => HomePage()),
  //       );
  //       print("line 191");
  //     } else {
  //       _showErrorDialog('Incorrect email or password.');
  //     }
  //   } catch (e) {
  //     _showErrorDialog('An error occurred. Please try again.');
  //   }
  // }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final hashedPassword = _hashPassword(password);

    // final url = Uri.parse('http://192.168.0.106:3000/api/login');
    final url = Uri.parse('http://192.168.0.106:3000/api/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': hashedPassword}),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        final accessToken = data['result'];
        final accessss = accessToken['access_token'];
        final refreshToken = accessToken['refresh_token'];
        final userID = accessToken['uid'];

        // Store tokens locally
        storeToken(accessss, refreshToken, 2, userID);
        print(accessToken);
        // Fetch user data from Firebase
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where("userId", isEqualTo: userID)
            .get();
        print(userDoc.docs.isNotEmpty);
        if (userDoc.docs.isNotEmpty) {
          final userData = userDoc.docs[0].data();
          print(userData['userId']);
          print(userData['username']);
          print(userData['country_code']);
          print(userData['space']);
          if (userData != null) {
            // Create a user model
            final user = UserModel(
              userId: userData['userId'],
              userName: userData['username'],
              countryCode: userData['country_code'],
              space: userData['space'].toString(),
            );
            print(user);
            // Store user information in the provider
            Provider.of<UserProvider>(context, listen: false).setUser(user);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            _showErrorDialog('Failed to fetch user data.');
          }
        } else {
          _showErrorDialog('User not found in Firebase.');
        }
      } else {
        _showErrorDialog('Incorrect email or password.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    }
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[_]).{6,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one number, and one underscore';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.blue.withOpacity(0.4)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: _validateEmail,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          validator: _validatePassword,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() == true) {
                              _login();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text('Login',
                              style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()),
                            );
                          },
                          child: Text(
                            'Don\'t have an account? Register',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
