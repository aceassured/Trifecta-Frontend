// import 'dart:convert';
// import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:crypto/crypto.dart';
// import 'dart:ui';

// class RegisterPage extends StatefulWidget {
//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _countryCodeController = TextEditingController();

//   // String _hashPassword(String password) {
//   //   return md5.convert(utf8.encode(password)).toString();
//   // }

//   Future<void> _register() async {
//     // try {
//     //   UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//     //     email: _emailController.text,
//     //     password: _passwordController.text,
//     //   );

//     //   String hashedPassword = _hashPassword(_passwordController.text);

//     //   await FirebaseFirestore.instance.collection('users').doc(userCredential.user.uid).set({
//     //     'email': _emailController.text,
//     //     'password': hashedPassword,
//     //     'countryCode': _countryCodeController.text,
//     //   });

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
//         foregroundColor: Colors.white,
//         title: Text(
//           'Register',
//           style: TextStyle(color: Colors.white),
//         ),
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
//                     SizedBox(height: 10),
//                     TextField(
//                       controller: _countryCodeController,
//                       decoration: InputDecoration(
//                         labelText: 'Country Code',
//                         labelStyle: TextStyle(color: Colors.white),
//                         border: OutlineInputBorder(),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blue),
//                         ),
//                       ),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _register,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                       ),
//                       child: Text('Register',
//                           style: TextStyle(color: Colors.white)),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(
//                         'Already have an account? Login',
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
import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:ui';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _countryCodeController = TextEditingController();

  final List<String> _countryCodes = [
    '1', '44', '91', '33', '49', // Add more country codes here
  ];

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
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*_).{6,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one number, and one underscore';
    }
    return null;
  }

  String? _validateCountryCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a country code';
    }
    final countryCodeRegex = RegExp(r'^\d+$');
    if (!countryCodeRegex.hasMatch(value)) {
      return 'Country code must be numeric';
    }
    return null;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = md5.convert(bytes);
    return digest.toString();
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

  Future<void> _register() async {
    print("COming inside register");
    final email = _emailController.text;
    final password = _passwordController.text;
    final countryCode = _countryCodeController.text;

    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);
    final countryCodeError = _validateCountryCode(countryCode);

    if (emailError != null ||
        passwordError != null ||
        countryCodeError != null) {
      _showErrorDialog(emailError ??
          passwordError ??
          countryCodeError ??
          'An error occurred.');
      return;
    }

    final hashedPassword = _hashPassword(password);
    print("Calling api");
    // final url = Uri.parse(
    //     'http://192.168.0.106:3000/api/register'); // Use the appropriate address
    final url = Uri.parse(
        'http://192.168.0.106:3000/api/register'); // Use the appropriate address
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'password': hashedPassword,
          'country_code': countryCode
        }),
      );
      print(response.body);
      final data = jsonDecode(response.body);
      final space = data['space'];
      final user = data['user'];
      final user_id = user['user_id'];
      if (response.statusCode == 201) {
        await FirebaseFirestore.instance.collection('users').add({
          'userId': user_id,
          'username': email,
          'password': hashedPassword,
          'country_code': countryCode,
          'space': space
        });
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        final errorMessage =
            data['error'] ?? 'An error occurred. Please try again.';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewInsets.bottom,
            ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 100),
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
                        keyboardType: TextInputType.emailAddress,
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
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _countryCodeController.text.isNotEmpty
                            ? _countryCodeController.text
                            : null,
                        items: _countryCodes.map((code) {
                          return DropdownMenuItem(
                            value: code,
                            child: Text(
                              code,
                              style: TextStyle(color: Colors.blue),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _countryCodeController.text = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Country Code',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: _validateCountryCode,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('Register',
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
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
