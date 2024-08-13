import 'dart:ffi';

class UserModel {
  final String userId;
  final String userName;
  final String space;
  final String countryCode;

  UserModel(
      {required this.userId,
      required this.userName,
      required this.countryCode,
      required this.space});
}
