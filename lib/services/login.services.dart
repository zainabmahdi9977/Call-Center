// login.services.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'varHttp.dart';
import 'package:invo_models/invo_models.dart';

class LoginServices {
  Future<bool> checkLogin(String email, String password) async {
    String token = "";
    String myHTTP = await getServerURL();
    try {
      final response = await http
          .post(
            Uri.parse('${myHTTP}login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(<String, String>{
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        if (map['success']) {
          token = map['data']['accessToken'];

          Employee employee = Employee(
            id: map['data']['employee']['id'],
            name: map['data']['employee']['name'],
            email: email,
            passCode: "",
            MSR: "",
          );

          await setEmployee(employee);
          await setToken(token);

          return true;
        } else {
          return false;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setToken(String value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString('token', value);
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  Future<bool> setEmployee(Employee employee) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        'employee',
        json.encode(employee.toMap()),
      );
    } catch (e) {
      return false;
    }
  }

  Future<Employee?> getEmployee() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString('employee');
      if (data == null) return null;
      return Employee.fromJson(json.decode(data));
    } catch (e) {
      return null;
    }
  }
}
