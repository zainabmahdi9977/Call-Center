import 'package:flutter/material.dart';
import 'package:invo_models/invo_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/login.services.dart';

class LoginPageBloc {
  Property<String> errorMsg = Property("");

  String email = "";
  String password = "";

  dynamic focusNode = FocusNode();

  Future<bool> login() async {
    bool res = await LoginServices().checkLogin(email, password);
    if (res) {
      await setLoggedIn(true);
      return true;
    } else {
      errorMsg.sink("Invalid email and password!");
      return false;
    }
  }

  Future<bool> isTokenValid() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await getToken();
    if (token != null) {
      return true;
    }
    return false;
  }

  Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  Future<String?> getToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }
}
