import 'dart:convert';

import 'package:attendance_log/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  AppUser? user;

  void assignUser({required DocumentSnapshot userDoc}) {
    try {
      user = AppUser.fromDoc(userDoc);
      print("assigned user $user");
    } on Exception catch (e) {
      print("assign user exception $e");
    }
    setUser();
  }

  void setUser() {
    try {
      SharedPreferences.getInstance()
          .then((pref) => pref.setString("user", jsonEncode(user!.toJson())));
    } on Exception catch (e) {
      print("set user exception $e");
    }
  }

  Future<AppUser?> getUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      user = AppUser.fromJson(jsonDecode(prefs.getString("user")!));
    } on Exception catch (e) {
      print("get user exception $e");
    }
    return user;
  }
}
