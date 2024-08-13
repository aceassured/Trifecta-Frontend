import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

final storage = FlutterSecureStorage();

// Store token with expiry time
Future<void> storeToken(String token, String refreshToken, int expiryDuration,
    String userId) async {
  await storage.write(key: 'accessToken', value: token);
  await storage.write(key: 'refreshToken', value: refreshToken);
  await storage.write(key: 'userId', value: userId);
  final expiryTime =
      DateTime.now().add(Duration(hours: expiryDuration)).toIso8601String();
  await storage.write(key: 'tokenExpiry', value: expiryTime);
}

// Retrieve token
Future<String?> getToken() async {
  return await storage.read(key: 'accessToken');
}

Future<String?> getUserId() async {
  return await storage.read(key: 'userId');
}

// Retrieve token expiry time
Future<DateTime?> getTokenExpiryTime() async {
  final expiryTimeString = await storage.read(key: 'tokenExpiry');
  return expiryTimeString != null ? DateTime.parse(expiryTimeString) : null;
}

// Check token validity and refresh if needed
Future<String> getValidToken() async {
  String? token = await getToken();
  DateTime? expiryTime = await getTokenExpiryTime();

  if (token == null ||
      expiryTime == null ||
      DateTime.now().isAfter(expiryTime)) {
    token = await fetchNewToken();
  }

  return token!;
}

// Fetch new token from backend
Future<String> fetchNewToken() async {
  String? refreshToken = await storage.read(key: 'refreshToken');
  final response = await http
      .get(Uri.parse('http://192.168.0.106:3000/api/token/${refreshToken}'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final result = data['result'];
    final accessToken = result['access_token'];
    final refreshToken = result['refresh_token'];
    final userID = result['uid'];
    // final newToken = response.body; // Assuming the token is in the body
    await storeToken(
        accessToken, refreshToken, 2, userID); // Store token with 2-hour expiry
    return accessToken;
  } else {
    throw Exception('Failed to fetch token');
  }
}

// Schedule token refresh every 2 hours
void scheduleTokenRefresh() {
  Timer.periodic(Duration(hours: 2), (Timer timer) async {
    await fetchNewToken();
  });
}
